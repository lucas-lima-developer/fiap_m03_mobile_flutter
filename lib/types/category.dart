import 'package:flutter/material.dart';

enum TransactionCategory {
  deposito,
  saque,
  pagamento,
  transferencia,
}

String transactionTypeToString(TransactionCategory type) {
  switch (type) {
    case TransactionCategory.deposito:
      return 'Depósito';
    case TransactionCategory.saque:
      return 'Saque';
    case TransactionCategory.pagamento:
      return 'Pagamento';
    case TransactionCategory.transferencia:
      return 'Transferência';
  }
}

TransactionCategory stringToTransactionType(String value) {
  switch (value.toLowerCase()) {
    case 'depósito':
      return TransactionCategory.deposito;
    case 'saque':
      return TransactionCategory.saque;
    case 'pagamento':
      return TransactionCategory.pagamento;
    case 'transferência':
      return TransactionCategory.transferencia;
    default:
      throw Exception('Tipo de transação desconhecido: $value');
  }
}

List<DropdownMenuItem<String>> getTransactionDropdownItems() {
  return TransactionCategory.values.map((type) {
    return DropdownMenuItem<String>(
      value: transactionTypeToString(type),
      child: Text(transactionTypeToString(type)),
    );
  }).toList();
}

List<Map<String, String>> getTransactionTypes() {
  return TransactionCategory.values.map((type) {
    return {
      'value': type.toString(),
      'description': transactionTypeToString(type),
    };
  }).toList();
}
