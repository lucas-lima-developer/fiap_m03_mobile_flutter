import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/transaction_provider.dart';
import '../types/transaction.dart';
import '../types/category.dart';

class TransactionScreen extends StatefulWidget {
  final TransactionType? transaction;

  const TransactionScreen({super.key, this.transaction});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedCategory;
  DateTime? _selectedDate;
  bool _isLoading = false;

  /// Arquivo local que o usuário eventualmente selecione (antes do upload).
  File? _selectedFile;

  /// URL do anexo que já existe na base de dados (usada para edição).
  String? _attachmentUrl;

  @override
  void initState() {
    super.initState();

    // Se estiver em modo de EDIÇÃO, preencher os campos com os valores da transação
    if (widget.transaction != null) {
      _descriptionController.text = widget.transaction!.description;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedCategory = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
      _attachmentUrl = widget.transaction!.attachmentUrl;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Exibe o DatePicker para selecionar a data
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Abre o seletor de arquivos (FilePicker) para escolher um anexo
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  /// Verifica se uma string (caminho/URL) representa uma imagem
  /// ignorando query params de URLs do Firebase
  bool _isImage(String pathOrUrl) {
    final uri = Uri.parse(pathOrUrl);
    final fileName = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last.toLowerCase()
        : pathOrUrl.toLowerCase();

    return fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif');
  }

  /// Abre o anexo local (OpenFile) ou remoto (url_launcher)
  Future<void> _openAttachment() async {
    try {
      if (_selectedFile != null) {
        // Arquivo local, ainda não fez upload
        await OpenFile.open(_selectedFile!.path);
      } else if (_attachmentUrl != null) {
        // URL do Firebase
        final uri = Uri.parse(_attachmentUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o arquivo.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao abrir o arquivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao abrir o arquivo.')),
      );
    }
  }

  /// Salvar (ou atualizar) a transação no Firestore
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    final description = _descriptionController.text.trim();

    // Converte texto R$ para double
    final amountText = _amountController.text
        .replaceAll(RegExp(r'[^0-9,]'), '')
        .replaceAll(',', '.');
    final amount = double.tryParse(amountText) ?? 0.0;

    final category = _selectedCategory ?? '';
    final date = _selectedDate ?? DateTime.now();

    // Se for depósito, mantém valor positivo;
    // caso contrário, torna-o negativo (depende da lógica do seu app).
    double sanitizedAmount;
    if (category.toLowerCase() == 'depósito') {
      sanitizedAmount = amount.abs();
    } else {
      sanitizedAmount = -amount.abs();
    }

    // Se o usuário selecionou arquivo, faz upload e obtém nova URL
    String? uploadedUrl;
    if (_selectedFile != null) {
      uploadedUrl =
          await transactionProvider.uploadAttachment(_selectedFile!.path);
    }

    String? error;
    // Criando nova transação
    if (widget.transaction == null) {
      error = await transactionProvider.addTransaction(
        description: description,
        amount: sanitizedAmount,
        date: date,
        category: category,
        attachmentUrl: uploadedUrl,
      );
    }
    // Editando transação existente
    else {
      error = await transactionProvider.editTransaction(
        transactionId: widget.transaction!.id,
        description: description,
        amount: sanitizedAmount,
        date: date,
        category: category,
        attachmentUrl: uploadedUrl ?? _attachmentUrl,
      );
    }

    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar transação')),
      );
    } else {
      // Se tudo certo, recarrega lista e fecha tela
      await transactionProvider.loadTransactions(reset: true);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Apenas para exibir nome do arquivo
    final fileName = _selectedFile != null
        ? _selectedFile!.path.split('/').last
        : _attachmentUrl != null
            ? Uri.parse(_attachmentUrl!).pathSegments.last
            : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            widget.transaction == null ? 'Nova Transação' : 'Editar Transação'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // DESCRIÇÃO
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Insira uma descrição'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // VALOR
                  TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RealInputFormatter(moeda: true),
                    ],
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Insira um valor'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // CATEGORIA
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: getTransactionDropdownItems(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Selecione uma categoria'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // DATA
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Selecione a data'
                              : 'Data: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectDate(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // BOTÃO DE SELECIONAR ANEXO
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text('Selecionar Anexo'),
                  ),
                  const SizedBox(height: 16),

                  // PRÉ-VISUALIZAÇÃO DO ANEXO (local ou remoto)
                  if (fileName != null)
                    InkWell(
                      onTap: _openAttachment,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Verifica se é imagem
                            if (_isImage(
                              _selectedFile != null
                                  ? _selectedFile!.path
                                  : _attachmentUrl!,
                            ))
                              _selectedFile != null
                                  ? Image.file(_selectedFile!, height: 100)
                                  : Image.network(_attachmentUrl!, height: 100)
                            else
                              // Qualquer outro formato
                              Column(
                                children: [
                                  const Icon(Icons.attach_file, size: 40),
                                  Text(fileName),
                                ],
                              ),
                            const SizedBox(height: 8),
                            const Text(
                              'Clique para abrir o anexo',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // BOTÃO DE SALVAR / ATUALIZAR
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveTransaction,
                    child: Text(
                      widget.transaction == null
                          ? 'Salvar Transação'
                          : 'Atualizar Transação',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // LOADING (overlay)
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
