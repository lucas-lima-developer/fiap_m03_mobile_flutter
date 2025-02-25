import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> get transactions => _transactions;

  // Carregar transações do usuário atual
  Future<void> loadTransactions() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final querySnapshot = await _firestore
        .collection('transação')
        .where('userId', isEqualTo: user.uid)
        .get();

    _transactions = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();

    notifyListeners();
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

  // Filtrar transações por categoria
  Future<void> filterTransactionsByCategory(String category) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final querySnapshot = await _firestore
        .collection('transação')
        .where('userId', isEqualTo: user.uid)
        .where('category', isEqualTo: category)
        .get();

    _transactions = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();

    notifyListeners();
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
