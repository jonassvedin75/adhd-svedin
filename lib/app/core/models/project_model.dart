import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String status; // e.g., 'active', 'on_hold', 'completed'
  final Timestamp createdAt;

  Project({
    required this.id,
    required this.name,
    this.description = '',
    this.status = 'active',
    required this.createdAt,
  });

  // Factory constructor to create a Project from a Firestore document
  factory Project.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'active',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Method to convert a Project object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
