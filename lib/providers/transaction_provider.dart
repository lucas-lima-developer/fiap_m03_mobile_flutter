import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fiap_m03_mobile_flutter/types/transaction.dart';
import 'package:brasil_fields/brasil_fields.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<TransactionType> _transactions = [];
  List<TransactionType> get transactions => _transactions;
  bool isLoading = false;
  DocumentSnapshot? _lastDocument;
  bool hasMore = true;

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

      if (category != null)
        query = query.where('category', isEqualTo: category);
      if (startDate != null && endDate != null) {
        query = query
            .where('date', isGreaterThanOrEqualTo: startDate)
            .where('date', isLessThanOrEqualTo: endDate);
      }

      if (_lastDocument != null)
        query = query.startAfterDocument(_lastDocument!);

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;

        final newTransactions = querySnapshot.docs.map((doc) {
          return TransactionType.fromJson(
              doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        _transactions.addAll(newTransactions);

        if (querySnapshot.docs.length < limit) {
          hasMore = false;
        }

        return newTransactions;
      } else {
        hasMore = false;
        return [];
      }
    } catch (e) {
      print('Erro ao carregar transações: $e');
      rethrow;
    } finally {
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Adicionar uma nova transação
  Future<String?> addTransaction({
    required String description,
    required double amount,
    required DateTime date,
    String? category,
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
        'attachmentUrl': null, // Inicialmente sem anexo
      });
      await loadTransactions(); // Recarregar transações após adicionar
      return null; // Sem erro
    } catch (e) {
      return e.toString();
    }
  }

  // Editar uma transação existente
  Future<String?> editTransaction({
    required String transactionId,
    required String description,
    required double amount,
    required DateTime date,
    String? category,
  }) async {
    try {
      await _firestore.collection('transação').doc(transactionId).update({
        'description': description,
        'amount': amount,
        'date': date,
        'category': category,
      });
      await loadTransactions(); // Recarregar transações após editar
      return null; // Sem erro
    } catch (e) {
      return e.toString();
    }
  }

  // Excluir uma transação
  Future<String?> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transação').doc(transactionId).delete();
      await loadTransactions(); // Recarregar transações após excluir
      return null; // Sem erro
    } catch (e) {
      return e.toString();
    }
  }

  // Upload de anexo para uma transação
  Future<String?> uploadAttachment(
      String transactionId, String filePath) async {
    try {
      final ref = _storage.ref(
          'transactions/$transactionId/${DateTime.now().toIso8601String()}');
      await ref.putFile(filePath as File);
      final url = await ref.getDownloadURL();

      await _firestore.collection('transação').doc(transactionId).update({
        'attachmentUrl': url,
      });

      await loadTransactions(); // Recarregar transações após upload
      return url; // Retorna a URL do anexo
    } catch (e) {
      return e.toString();
    }
  }
}
