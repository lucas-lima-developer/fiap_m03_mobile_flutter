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

  void _applyFilter() {
    widget.onFilterApply({
      'category': _selectedCategory,
      'startDate': _dataRange?.start,
      'endDate': _dataRange?.end,
      'reset': false,
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _dataRange = null;
    });
    widget.onFilterApply({'reset': true});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Categoria',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => _selectedCategory = value);
            },
            items: [
              DropdownMenuItem(
                  value: 'Categoria 1', child: Text('Categoria 1')),
              DropdownMenuItem(
                  value: 'Categoria 2', child: Text('Categoria 2')),
            ],
          ),
          const SizedBox(height: 16),
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
                    : '${_dateFormat.format(_dataRange!.start)} - ${_dateFormat.format(_dataRange!.end)}',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: _applyFilter,
                child: const Text('Aplicar Filtro'),
              ),
              if (_selectedCategory != null || _dataRange != null)
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
