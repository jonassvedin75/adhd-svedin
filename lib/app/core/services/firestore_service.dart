import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's ID
  String? get _uid => _auth.currentUser?.uid;

  /// Adds a new item to a specified collection for the current user.
  ///
  /// The [collectionPath] is the name of the collection (e.g., 'inbox', 'tasks').
  /// The [data] is a map representing the document to be added.
  /// It automatically adds the user's UID and a timestamp.
  Future<void> addItem({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('User is not authenticated.');

    final collectionRef = _db.collection('users').doc(uid).collection(collectionPath);
    
    // Add user ID and timestamp to the data
    data['userId'] = uid;
    data['createdAt'] = FieldValue.serverTimestamp();

    await collectionRef.add(data);
  }

  /// Retrieves a real-time stream of items from a specified collection for the current user.
  ///
  /// The [collectionPath] is the name of the collection.
  /// It returns a stream of query snapshots, ordered by creation time.
  Stream<QuerySnapshot> getItemsStream({required String collectionPath}) {
    final uid = _uid;
    if (uid == null) {
      // Return an empty stream if the user is not authenticated.
      return const Stream.empty();
    }
    
    return _db
        .collection('users')
        .doc(uid)
        .collection(collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Updates an existing item in a specified collection.
  ///
  /// The [collectionPath] is the name of the collection.
  /// The [docId] is the ID of the document to update.
  /// The [data] is a map of the fields to update.
  Future<void> updateItem({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('User is not authenticated.');

    await _db
        .collection('users')
        .doc(uid)
        .collection(collectionPath)
        .doc(docId)
        .update(data);
  }

  /// Deletes an item from a specified collection.
  ///
  /// The [collectionPath] is the name of the collection.
  /// The [docId] is the ID of the document to delete.
  Future<void> deleteItem({
    required String collectionPath,
    required String docId,
  }) async {
    final uid = _uid;
    if (uid == null) throw Exception('User is not authenticated.');
    
    await _db
        .collection('users')
        .doc(uid)
        .collection(collectionPath)
        .doc(docId)
        .delete();
  }
}
