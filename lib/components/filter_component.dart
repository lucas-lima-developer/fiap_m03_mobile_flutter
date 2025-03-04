import 'package:fiap_m03_mobile_flutter/types/category.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

class FilterComponent extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterApply;

  const FilterComponent({
    Key? key,
    required this.onFilterApply,
  }) : super(key: key);

  @override
  _FilterComponentState createState() => _FilterComponentState();
}

class _FilterComponentState extends State<FilterComponent> {
  String? _selectedCategory;
  DateTimeRange? _dataRange;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  void _applyFilter() {
    if (_selectedCategory != null || _dataRange != null) {
      widget.onFilterApply({
        'category': _selectedCategory,
        'startDate': _dataRange?.start,
        'endDate': _dataRange?.end,
        'reset': false,
      });
    }
  }

  void _limparFiltros() {
    setState(() {
      _selectedCategory = null;
      _dataRange = null;
    });

    widget.onFilterApply({
      'category': _selectedCategory,
      'startDate': _dataRange?.start,
      'endDate': _dataRange?.end,
      'reset': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: _selectedCategory,
          hint: Text('Selecione uma categoria'),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          items: getTransactionDropdownItems(),
        ),
        GestureDetector(
          onTap: () async {
            final DateTimeRange? result = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              initialDateRange: _dataRange,
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: Colors.blue,
                    buttonTheme:
                        ButtonThemeData(textTheme: ButtonTextTheme.primary),
                  ),
                  child: child!,
                );
              },
              locale: const Locale("pt", "BR"),
            );
            if (result != null) {
              setState(() {
                _dataRange = result;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black45),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              _dataRange == null
                  ? 'Selecione o intervalo de datas'
                  : '${_dateFormat.format(_dataRange!.start)} - ${_dateFormat.format(_dataRange!.end)}',
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _applyFilter,
              child: Text('Aplicar Filtro'),
            ),
            if (_selectedCategory != null || _dataRange != null)
              ElevatedButton(
                onPressed: _limparFiltros,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white),
                child: Text('Limpar Filtros'),
              ),
          ],
        ),
      ],
    );
  }
}
