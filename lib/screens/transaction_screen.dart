import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class TransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction;

  const TransactionScreen({super.key, this.transaction});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _descriptionController.text = widget.transaction!['description'];
      _amountController.text = widget.transaction!['amount'].toString();
      _categoryController.text = widget.transaction!['category'] ?? '';
      _selectedDate = widget.transaction!['date'].toDate();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    try {
      if (_formKey.currentState!.validate()) {
        final description = _descriptionController.text;
        final amount = double.parse(_amountController.text);
        final category =
            _categoryController.text.isEmpty ? null : _categoryController.text;
        final date = _selectedDate ?? DateTime.now();

        if (widget.transaction == null) {
          // Adicionar nova transação
          final error = await transactionProvider.addTransaction(
            description: description,
            amount: amount,
            date: date,
            category: category,
          );
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao adicionar transação')),
            );
          } else {
            await transactionProvider.loadTransactions();
            Navigator.pop(context);
          }
        } else {
          // Editar transação existente
          final error = await transactionProvider.editTransaction(
            transactionId: widget.transaction!['id'],
            description: description,
            amount: amount,
            date: date,
            category: category,
          );
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao editar transação')),
            );
          } else {
            await transactionProvider.loadTransactions();
            Navigator.pop(context);
          }
        }
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.transaction == null ? 'Nova Transação' : 'Editar Transação',
          style: TextStyle(color: Colors.black87),
        ),
        iconTheme: IconThemeData(color: Colors.black54),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um valor';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: 'Categoria (opcional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    _selectedDate == null
                        ? 'Selecione a data'
                        : 'Data: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today,
                        color: Colors.blueAccent),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.transaction == null
                      ? 'Salvar Transação'
                      : 'Atualizar Transação',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
