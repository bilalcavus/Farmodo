import 'package:cloud_firestore/cloud_firestore.dart';

class GamificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<T>> fetchCollection<T>({
    required String path,
    required T Function(DocumentSnapshot doc) fromFirestore,
  }) async {
    try {
      final snapshot = await _firestore.collection(path).get();
      return snapshot.docs.map(fromFirestore).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<T>> fetchSubCollection<T>({
  required String parentCollection,
  required String parentId,
  required String subCollection,
  required T Function(DocumentSnapshot doc) fromFirestore,
}) async {
  final snapshot = await _firestore
      .collection(parentCollection)
      .doc(parentId)
      .collection(subCollection)
      .get();

  return snapshot.docs.map(fromFirestore).toList();
}

Future<bool> documentExists({
    required String collectionPath,
    required String docId,
  }) async {
    final doc = await _firestore.collection(collectionPath).doc(docId).get();
    return doc.exists;
  }

  Future<void> setDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).set(data);
  }

  

    Future<void> updateDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionPath).doc(docId).update(data);
  }

  /// Tek bir doküman getirme
  Future<DocumentSnapshot?> getDocument(String path) async {
    try {
      return await _firestore.doc(path).get();
    } catch (e) {
      print("Firestore getDocument error ($path): $e");
      return null;
    }
  }

  /// Transaction ile doküman güncelleme
  Future<void> runTransaction(
    String path,
    Future<void> Function(DocumentSnapshot doc, Transaction transaction) action,
  ) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.doc(path);
        final snapshot = await transaction.get(docRef);
        await action(snapshot, transaction);
      });
    } catch (e) {
      print("Firestore runTransaction error ($path): $e");
    }
  }
}
