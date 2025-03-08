import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionType {
  final String id;
  final DateTime date;
  final double amount;
  final String? attachmentUrl;
  final String description;
  final String category;
  final String userId;

  TransactionType({
    required this.id,
    required this.date,
    required this.amount,
    this.attachmentUrl,
    required this.description,
    required this.category,
    required this.userId,
  });

  /// Construtor para usar quando estiver convertendo de um Map local (pouco usado).
  factory TransactionType.fromMap(Map<String, dynamic> map) {
    return TransactionType(
      id: map['id'] as String,
      date: (map['date'] as Timestamp).toDate(),
      amount: (map['amount'] as num).toDouble(),
      attachmentUrl: map['attachmentUrl'] as String?,
      description: map['description'] as String,
      category: map['category'] as String,
      userId: map['userId'] as String,
    );
  }

  /// Construtor principal para receber dados do Firestore (Json + docId).
  factory TransactionType.fromJson(Map<String, dynamic> json, String docId) {
    return TransactionType(
      id: docId, // ID do documento no Firestore
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      attachmentUrl: json['attachmentUrl'] as String?,
    );
  }

  /// Converte de volta para Map (caso precise salvar localmente, etc.)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'attachmentUrl': attachmentUrl,
      'description': description,
      'category': category,
      'userId': userId,
    };
  }
}
