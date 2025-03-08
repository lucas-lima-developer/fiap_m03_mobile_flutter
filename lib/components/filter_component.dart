import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterComponent extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterApply;

  const FilterComponent({Key? key, required this.onFilterApply})
      : super(key: key);

  @override
  _FilterComponentState createState() => _FilterComponentState();
}

class _FilterComponentState extends State<FilterComponent> {
  String? _selectedCategory;
  DateTimeRange? _dataRange;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  final TextEditingController _descriptionController = TextEditingController();

  /// Aplica o filtro chamando o callback com os valores selecionados.
  void _applyFilter() {
    widget.onFilterApply({
      'category': _selectedCategory,
      'startDate': _dataRange?.start,
      'endDate': _dataRange?.end,
      'description': _descriptionController.text.trim(),
      'reset': false,
    });
  }

  /// Limpa todos os filtros (categoria, intervalo e descrição).
  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _dataRange = null;
      _descriptionController.clear();
    });
    widget.onFilterApply({'reset': true});
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se algum filtro está ativo para decidir se mostra o botão "Limpar"
    final bool anyFilterActive = (_selectedCategory != null) ||
        (_dataRange != null) ||
        (_descriptionController.text.isNotEmpty);

    return Container(
      color: Colors.white, // Fundo branco
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // FILTRO POR DESCRIÇÃO
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // FILTRO POR CATEGORIA
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Categoria',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => _selectedCategory = value);
            },
            items: const [
              DropdownMenuItem(
                value: 'Depósito',
                child: Text('Depósito'),
              ),
              DropdownMenuItem(
                value: 'Saque',
                child: Text('Saque'),
              ),
              DropdownMenuItem(
                value: 'Pagamento',
                child: Text('Pagamento'),
              ),
              DropdownMenuItem(
                value: 'Transferência',
                child: Text('Transferência'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // FILTRO POR INTERVALO DE DATAS
          GestureDetector(
            onTap: () async {
              final result = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDateRange: _dataRange,
              );
              if (result != null) {
                setState(() => _dataRange = result);
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Intervalo de Datas',
                border: OutlineInputBorder(),
              ),
              child: Text(
                _dataRange == null
                    ? 'Selecione um período'
                    : '${_dateFormat.format(_dataRange!.start)} - '
                        '${_dateFormat.format(_dataRange!.end)}',
              ),
            ),
          ),
          const SizedBox(height: 24),

          // BOTÕES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: _applyFilter,
                child: const Text('Aplicar Filtro'),
              ),
              if (anyFilterActive)
                OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Limpar Filtros'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
