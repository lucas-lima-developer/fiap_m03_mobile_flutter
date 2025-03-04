import 'package:flutter/material.dart';

enum TransactionType {
  deposito,
  saque,
  pagamento,
  transferencia,
}

String transactionTypeToString(TransactionType type) {
  switch (type) {
    case TransactionType.deposito:
      return 'Depósito';
    case TransactionType.saque:
      return 'Saque';
    case TransactionType.pagamento:
      return 'Pagamento';
    case TransactionType.transferencia:
      return 'Transferência';
  }
}

TransactionType stringToTransactionType(String value) {
  switch (value.toLowerCase()) {
    case 'depósito':
      return TransactionType.deposito;
    case 'saque':
      return TransactionType.saque;
    case 'pagamento':
      return TransactionType.pagamento;
    case 'transferência':
      return TransactionType.transferencia;
    default:
      throw Exception('Tipo de transação desconhecido: $value');
  }
}

List<DropdownMenuItem<String>> getTransactionDropdownItems() {
  return TransactionType.values.map((type) {
    return DropdownMenuItem<String>(
      value: transactionTypeToString(type),
      child: Text(transactionTypeToString(type)),
    );
  }).toList();
}

List<Map<String, String>> getTransactionTypes() {
  return TransactionType.values.map((type) {
    return {
      'value': type.toString(),
      'description': transactionTypeToString(type),
    };
  }).toList();
}
