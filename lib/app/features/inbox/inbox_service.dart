import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InboxItem {
  final String id;
  final String content;
  final Timestamp createdAt;

  InboxItem({required this.id, required this.content, required this.createdAt});

  factory InboxItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return InboxItem(
      id: doc.id,
      content: data['content'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}

class InboxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'inbox'; 

  Stream<List<InboxItem>> getInboxItems() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => InboxItem.fromFirestore(doc)).toList());
  }

  Future<void> addInboxItem(String content) {
    return _firestore.collection(_collectionPath).add({
      'content': content,
      'createdAt': Timestamp.now(),
    });
  }
}

final inboxServiceProvider = Provider((ref) => InboxService());

final inboxItemsProvider = StreamProvider<List<InboxItem>>((ref) {
  final inboxService = ref.watch(inboxServiceProvider);
  return inboxService.getInboxItems();
});
