import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data model för inbox items
class InboxItem {
  final String id;
  final String content;
  final DateTime createdAt;
  final String userId;
  final bool isProcessed;

  InboxItem({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.userId,
    this.isProcessed = false,
  });

  factory InboxItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InboxItem(
      id: doc.id,
      content: data['content'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      userId: data['userId'] ?? '',
      isProcessed: data['isProcessed'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'isProcessed': isProcessed,
    };
  }

  InboxItem copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    String? userId,
    bool? isProcessed,
  }) {
    return InboxItem(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }
}

// Service för att hantera Firestore operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Lägg till nytt item
  Future<void> addItem(String content) async {
    if (content.trim().isEmpty || _userId.isEmpty) {
      throw Exception('Ogiltig inmatning eller användare inte inloggad');
    }

    try {
      final item = InboxItem(
        id: '', // Firestore genererar ID
        content: content.trim(),
        createdAt: DateTime.now(),
        userId: _userId,
      );

      await _firestore
          .collection('inbox_items')
          .add(item.toFirestore());
    } catch (e) {
      print('Error adding item to Firestore: $e');
      throw Exception('Kunde inte spara i databasen: $e');
    }
  }

  // Hämta alla items för användaren
  Stream<List<InboxItem>> getItemsStream() {
    if (_userId.isEmpty) return Stream.value([]);

    try {
      return _firestore
          .collection('inbox_items')
          .where('userId', isEqualTo: _userId)
          .where('isProcessed', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => InboxItem.fromFirestore(doc))
            .toList();
      }).handleError((error) {
        print('Error in getItemsStream: $error');
        
        // Check if it's an index error and provide helpful message
        if (error.toString().contains('failed-precondition') && 
            error.toString().contains('index')) {
          print('⚠️ Firestore index missing. Please create the required index.');
          print('📋 Index needed for: inbox_items collection with fields: isProcessed, userId, createdAt');
          print('🔗 Check the create_firestore_index.md file for instructions');
        }
        
        // Return empty list as fallback
        return <InboxItem>[];
      });
    } catch (e) {
      print('Error setting up items stream: $e');
      return Stream.value([]);
    }
  }

  // Markera item som bearbetat
  Future<void> markAsProcessed(String itemId) async {
    try {
      await _firestore
          .collection('inbox_items')
          .doc(itemId)
          .update({'isProcessed': true});
    } catch (e) {
      print('Error marking item as processed: $e');
      throw Exception('Kunde inte uppdatera item: $e');
    }
  }

  // Ta bort item
  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore
          .collection('inbox_items')
          .doc(itemId)
          .delete();
    } catch (e) {
      print('Error deleting item: $e');
      throw Exception('Kunde inte ta bort item: $e');
    }
  }

  // Uppdatera item content
  Future<void> updateItem(String itemId, String content) async {
    try {
      await _firestore
          .collection('inbox_items')
          .doc(itemId)
          .update({'content': content.trim()});
    } catch (e) {
      print('Error updating item: $e');
      throw Exception('Kunde inte uppdatera item: $e');
    }
  }
}

// Providers för Riverpod
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final inboxStreamProvider = StreamProvider<List<InboxItem>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getItemsStream();
});
