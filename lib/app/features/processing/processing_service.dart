import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data model för tasks
class Task {
  final String id;
  final String content;
  final DateTime createdAt;
  final String userId;
  final bool isCompleted;
  final DateTime? dueDate;
  final String? projectId;

  Task({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.userId,
    this.isCompleted = false,
    this.dueDate,
    this.projectId,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      dueDate: data['dueDate'] != null ? (data['dueDate'] as Timestamp).toDate() : null,
      projectId: data['projectId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'isCompleted': isCompleted,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'projectId': projectId,
    };
  }
}

// Data model för projects
class Project {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final String userId;
  final bool isCompleted;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.userId,
    this.isCompleted = false,
  });

  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'isCompleted': isCompleted,
    };
  }
}

// Data model för someday/maybe items
class SomedayItem {
  final String id;
  final String content;
  final DateTime createdAt;
  final String userId;

  SomedayItem({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.userId,
  });

  factory SomedayItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SomedayItem(
      id: doc.id,
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }
}

// Data model för reference items
class ReferenceItem {
  final String id;
  final String content;
  final DateTime createdAt;
  final String userId;
  final String? category;

  ReferenceItem({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.userId,
    this.category,
  });

  factory ReferenceItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReferenceItem(
      id: doc.id,
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      category: data['category'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'category': category,
    };
  }
}

// Service för att hantera all processing logic
class ProcessingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Debug-metod för att kontrollera Firebase-status
  Future<void> checkFirebaseStatus() async {
    developer.log('🔍 === FIREBASE STATUS CHECK ===');
    developer.log('🔐 Auth current user: ${_auth.currentUser?.email ?? 'INGEN'}');
    developer.log('🆔 User ID: $_userId');
    
    try {
      // Testa Firestore-anslutning
      developer.log('📡 Testar Firestore-anslutning...');
      final testDoc = await _firestore.collection('_test').doc('test').get();
      developer.log('✅ Firestore funkar (test doc exists: ${testDoc.exists})');
    } catch (e, s) {
      developer.log('❌ Firestore ERROR', error: e, stackTrace: s);
    }
  }

  // Konvertera inbox item till task
  Future<void> convertToTask(String inboxItemId, String content) async {
    try {
      developer.log('🚀 Startar konvertering till task...');
      developer.log('📧 Current user: ${_auth.currentUser?.email ?? 'Ingen användare'}');
      developer.log('🆔 User ID: $_userId');
      developer.log('📝 Content: $content');
      developer.log('🔗 Inbox Item ID: $inboxItemId');
      
      // Kontrollera att användaren är inloggad
      if (_userId.isEmpty) {
        developer.log('❌ ERROR: Användaren är inte inloggad');
        throw Exception('Du måste vara inloggad för att skapa uppgifter');
      }

      developer.log('📦 Skapar Firestore batch...');
      final batch = _firestore.batch();

      // STEG 1: KOPIERA - Skapa ny task
      final taskRef = _firestore.collection('tasks').doc();
      final task = Task(
        id: taskRef.id,
        content: content,
        createdAt: DateTime.now(),
        userId: _userId,
      );
      
      developer.log('✅ Task objekt skapat: ${task.toFirestore()}');
      batch.set(taskRef, task.toFirestore());

      // STEG 2: RADERA - Ta bort från inbox (inte bara markera som processed)
      final inboxRef = _firestore.collection('inbox_items').doc(inboxItemId);
      developer.log('🗑️ Tar bort inbox item...');
      batch.delete(inboxRef);

      developer.log('💾 Commitar batch till Firestore...');
      await batch.commit();
      developer.log('🎉 Task skapad och inbox item borttaget!');
      
    } catch (e, stackTrace) {
      developer.log('💥 ERROR i convertToTask', error: e, stackTrace: stackTrace);
      rethrow; // Kasta om felet så UI:t kan hantera det
    }
  }

  // Konvertera inbox item till projekt
  Future<void> convertToProject(String inboxItemId, String content) async {
    // Kontrollera att användaren är inloggad
    if (_userId.isEmpty) {
      throw Exception('Du måste vara inloggad för att skapa projekt');
    }

    final batch = _firestore.batch();

    // STEG 1: KOPIERA - Skapa nytt projekt
    final projectRef = _firestore.collection('projects').doc();
    final project = Project(
      id: projectRef.id,
      name: content,
      createdAt: DateTime.now(),
      userId: _userId,
    );
    
    batch.set(projectRef, project.toFirestore());

    // STEG 2: RADERA - Ta bort från inbox
    final inboxRef = _firestore.collection('inbox_items').doc(inboxItemId);
    batch.delete(inboxRef);

    await batch.commit();
  }

  // Flytta till someday/maybe
  Future<void> moveToSomeday(String inboxItemId, String content) async {
    // Kontrollera att användaren är inloggad
    if (_userId.isEmpty) {
      throw Exception('Du måste vara inloggad');
    }

    final batch = _firestore.batch();

    // STEG 1: KOPIERA - Skapa someday item
    final somedayRef = _firestore.collection('someday_maybe').doc();
    final somedayItem = SomedayItem(
      id: somedayRef.id,
      content: content,
      createdAt: DateTime.now(),
      userId: _userId,
    );
    
    batch.set(somedayRef, somedayItem.toFirestore());

    // STEG 2: RADERA - Ta bort från inbox
    final inboxRef = _firestore.collection('inbox_items').doc(inboxItemId);
    batch.delete(inboxRef);

    await batch.commit();
  }

  // Flytta till referens
  Future<void> moveToReference(String inboxItemId, String content, {String? category}) async {
    // Kontrollera att användaren är inloggad
    if (_userId.isEmpty) {
      throw Exception('Du måste vara inloggad');
    }

    final batch = _firestore.batch();

    // STEG 1: KOPIERA - Skapa reference item
    final referenceRef = _firestore.collection('reference').doc();
    final referenceItem = ReferenceItem(
      id: referenceRef.id,
      content: content,
      createdAt: DateTime.now(),
      userId: _userId,
      category: category,
    );
    
    batch.set(referenceRef, referenceItem.toFirestore());

    // STEG 2: RADERA - Ta bort från inbox
    final inboxRef = _firestore.collection('inbox_items').doc(inboxItemId);
    batch.delete(inboxRef);

    await batch.commit();
  }

  // Ta bort item helt
  Future<void> deleteItem(String inboxItemId) async {
    await _firestore.collection('inbox_items').doc(inboxItemId).delete();
  }

  // Markera uppgift som slutförd
  Future<void> completeTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'isCompleted': true,
    });
  }

  // Hämta tasks
  Stream<List<Task>> getTasksStream() {
    if (_userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: _userId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromFirestore(doc))
          .toList();
    });
  }

  // Hämta projects
  Stream<List<Project>> getProjectsStream() {
    if (_userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('projects')
        .where('userId', isEqualTo: _userId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Project.fromFirestore(doc))
          .toList();
    });
  }

  // Hämta someday items
  Stream<List<SomedayItem>> getSomedayStream() {
    if (_userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('someday_maybe')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SomedayItem.fromFirestore(doc))
          .toList();
    });
  }

  // Hämta reference items
  Stream<List<ReferenceItem>> getReferenceStream() {
    if (_userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('reference')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReferenceItem.fromFirestore(doc))
          .toList();
    });
  }
}

// Providers
final processingServiceProvider = Provider<ProcessingService>((ref) {
  return ProcessingService();
});

final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final service = ref.watch(processingServiceProvider);
  return service.getTasksStream();
});

final projectsStreamProvider = StreamProvider<List<Project>>((ref) {
  final service = ref.watch(processingServiceProvider);
  return service.getProjectsStream();
});

final somedayStreamProvider = StreamProvider<List<SomedayItem>>((ref) {
  final service = ref.watch(processingServiceProvider);
  return service.getSomedayStream();
});

final referenceStreamProvider = StreamProvider<List<ReferenceItem>>((ref) {
  final service = ref.watch(processingServiceProvider);
  return service.getReferenceStream();
});
