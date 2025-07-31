import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProcessingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> convertToTask(String itemId, String content) async {
    // Implement task conversion logic
  }

  Future<void> convertToProject(String itemId, String content) async {
    // Implement project conversion logic
  }

  Future<void> moveToSomeday(String itemId, String content) async {
    // Implement move to someday logic
  }

  Future<void> moveToReference(String itemId, String content) async {
    // Implement move to reference logic
  }

  Future<void> deleteItem(String itemId) async {
    // Implement delete logic
  }
}

final processingServiceProvider = Provider((ref) => ProcessingService());
