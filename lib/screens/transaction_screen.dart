import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:brasil_fields/brasil_fields.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _descriptionController.text = widget.transaction!.description;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedCategory = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

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

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    final description = _descriptionController.text.trim();
    final amountText = _amountController.text
        .replaceAll(RegExp(r'[^0-9,]'), '')
        .replaceAll(',', '.');
    final amount = double.tryParse(amountText) ?? 0.0;
    final category = _selectedCategory;
    final date = _selectedDate ?? DateTime.now();

    final sanitizedAmount =
        category == TransactionCategory.deposito ? amount.abs() : -amount.abs();
    final error = widget.transaction == null
        ? await transactionProvider.addTransaction(
            description: description,
            amount: sanitizedAmount,
            date: date,
            category: category)
        : await transactionProvider.editTransaction(
            transactionId: widget.transaction!.id,
            description: description,
            amount: sanitizedAmount,
            date: date,
            category: category);

    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar transação')));
    } else {
      await transactionProvider.loadTransactions();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                        labelText: 'Descrição', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Insira uma descrição'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RealInputFormatter(moeda: true)
                    ],
                    controller: _amountController,
                    decoration: const InputDecoration(
                        labelText: 'Valor', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Insira um valor'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                        labelText: 'Categoria', border: OutlineInputBorder()),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value),
                    items: getTransactionDropdownItems(),
                  ),
                  const SizedBox(height: 24),
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
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveTransaction,
                    child: Text(widget.transaction == null
                        ? 'Salvar Transação'
                        : 'Atualizar Transação'),
                  ),
                ],
              ),
            ),
          ),
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
