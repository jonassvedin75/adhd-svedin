import 'package:cloud_firestore/cloud_firestore.dart';

class Idea {
  final String id;
  final String content;
  final Timestamp createdAt;

  Idea({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  factory Idea.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Idea(
      id: doc.id,
      content: data['content'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'createdAt': createdAt,
    };
  }
}
