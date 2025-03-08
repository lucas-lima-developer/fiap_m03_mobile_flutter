import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../types/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<TransactionType> _transactions = [];
  List<TransactionType> get transactions => _transactions;

  bool isLoading = false;
  DocumentSnapshot? _lastDocument;
  bool hasMore = true;

  /// Carrega lista de transações do Firestore
  Future<List<TransactionType>> loadTransactions({
    int limit = 10,
    bool reset = false,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (isLoading) return [];

    isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      if (reset) {
        _lastDocument = null;
        _transactions.clear();
        hasMore = true;
      }

      Query query = _firestore
          .collection('transação')
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .limit(limit);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (startDate != null && endDate != null) {
        query = query
            .where('date', isGreaterThanOrEqualTo: startDate)
            .where('date', isLessThanOrEqualTo: endDate);
      }

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;

        final newTransactions = querySnapshot.docs.map((doc) {
          return TransactionType.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();

        _transactions.addAll(newTransactions);

        if (querySnapshot.docs.length < limit) {
          hasMore = false;
        }

        return newTransactions;
      } else {
        // Sem dados novos
        hasMore = false;
        return [];
      }
    } catch (e) {
      debugPrint('Erro ao carregar transações: $e');
      rethrow;
    } finally {
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Adiciona uma nova transação
  Future<String?> addTransaction({
    required String description,
    required double amount,
    required DateTime date,
    required String category,
    String? attachmentUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return "Usuário não autenticado";

    try {
      await _firestore.collection('transação').add({
        'userId': user.uid,
        'description': description,
        'amount': amount,
        'date': date,
        'category': category,
        'attachmentUrl': attachmentUrl,
      });

      // Recarrega a lista para exibir a nova transação
      await loadTransactions(reset: true);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Edita uma transação existente
  Future<String?> editTransaction({
    required String transactionId,
    required String description,
    required double amount,
    required DateTime date,
    required String category,
    String? attachmentUrl,
  }) async {
    try {
      await _firestore.collection('transação').doc(transactionId).update({
        'description': description,
        'amount': amount,
        'date': date,
        'category': category,
        'attachmentUrl': attachmentUrl,
      });

      // Recarrega a lista para exibir a edição
      await loadTransactions(reset: true);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Deleta uma transação
  Future<String?> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transação').doc(transactionId).delete();
      await loadTransactions(reset: true);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Faz upload de anexo (arquivo) no Firebase Storage
  Future<String?> uploadAttachment(String filePath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "Erro: Usuário não autenticado";

      File file = File(filePath);
      final storageRef = _storage.ref(
        'transactions/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}',
      );

      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      return e.toString();
    }
  }
}
