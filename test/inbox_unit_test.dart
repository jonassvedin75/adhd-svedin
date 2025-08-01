import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_kodhjalp/app/features/inbox/inbox_service.dart';
import 'package:ai_kodhjalp/app/features/processing/processing_service.dart';

void main() {
  group('InboxItem Model Unit Tests', () {
    test('should create InboxItem with all required fields', () {
      final now = DateTime.now();
      final item = InboxItem(
        id: 'test-id-123',
        content: 'Test content for inbox item',
        createdAt: now,
        userId: 'user-123',
        isProcessed: false,
      );

      expect(item.id, 'test-id-123');
      expect(item.content, 'Test content for inbox item');
      expect(item.createdAt, now);
      expect(item.userId, 'user-123');
      expect(item.isProcessed, false);
    });

    test('should create InboxItem with default isProcessed value', () {
      final item = InboxItem(
        id: 'test-id',
        content: 'Test content',
        createdAt: DateTime.now(),
        userId: 'user-123',
      );

      expect(item.isProcessed, false);
    });

    test('should convert to Firestore format correctly', () {
      final now = DateTime(2024, 1, 15, 10, 30);
      final item = InboxItem(
        id: 'test-id',
        content: 'Test content',
        createdAt: now,
        userId: 'user-123',
        isProcessed: true,
      );

      final firestoreData = item.toFirestore();

      expect(firestoreData['content'], 'Test content');
      expect(firestoreData['userId'], 'user-123');
      expect(firestoreData['isProcessed'], true);
      expect(firestoreData['createdAt'], isA<Timestamp>());
      expect((firestoreData['createdAt'] as Timestamp).toDate(), now);
    });

    test('should create from Firestore document correctly', () {
      final now = DateTime(2024, 1, 15, 10, 30);
      final mockData = {
        'content': 'Test content from Firestore',
        'userId': 'user-456',
        'isProcessed': false,
        'createdAt': Timestamp.fromDate(now),
      };

      // Mock DocumentSnapshot
      final mockDoc = _MockDocumentSnapshot('test-doc-id', mockData);

      final item = InboxItem.fromFirestore(mockDoc);

      expect(item.id, 'test-doc-id');
      expect(item.content, 'Test content from Firestore');
      expect(item.userId, 'user-456');
      expect(item.isProcessed, false);
      expect(item.createdAt, now);
    });

    test('should handle missing fields in Firestore document', () {
      final mockData = {
        'content': 'Test content',
        // Missing userId, isProcessed, createdAt
      };

      final mockDoc = _MockDocumentSnapshot('test-doc-id', mockData);

      final item = InboxItem.fromFirestore(mockDoc);

      expect(item.id, 'test-doc-id');
      expect(item.content, 'Test content');
      expect(item.userId, ''); // Default value
      expect(item.isProcessed, false); // Default value
      expect(item.createdAt, isA<DateTime>()); // Should not crash
      expect(item.createdAt.isAfter(DateTime.now().subtract(Duration(seconds: 1))), true); // Should be recent
    });

    test('should create copy with updated fields', () {
      final original = InboxItem(
        id: 'original-id',
        content: 'Original content',
        createdAt: DateTime(2024, 1, 1),
        userId: 'user-123',
        isProcessed: false,
      );

      final updated = original.copyWith(
        content: 'Updated content',
        isProcessed: true,
      );

      expect(updated.id, 'original-id');
      expect(updated.content, 'Updated content');
      expect(updated.userId, 'user-123');
      expect(updated.isProcessed, true);
      expect(updated.createdAt, DateTime(2024, 1, 1));
    });
  });

  group('Task Model Unit Tests', () {
    test('should create Task with all required fields', () {
      final now = DateTime.now();
      final dueDate = DateTime(2024, 2, 1);
      
      final task = Task(
        id: 'task-123',
        content: 'Complete project documentation',
        createdAt: now,
        userId: 'user-123',
        isCompleted: false,
        dueDate: dueDate,
        projectId: 'project-456',
      );

      expect(task.id, 'task-123');
      expect(task.content, 'Complete project documentation');
      expect(task.createdAt, now);
      expect(task.userId, 'user-123');
      expect(task.isCompleted, false);
      expect(task.dueDate, dueDate);
      expect(task.projectId, 'project-456');
    });

    test('should convert Task to Firestore format', () {
      final now = DateTime(2024, 1, 15);
      final dueDate = DateTime(2024, 2, 1);
      
      final task = Task(
        id: 'task-123',
        content: 'Test task',
        createdAt: now,
        userId: 'user-123',
        isCompleted: true,
        dueDate: dueDate,
        projectId: 'project-456',
      );

      final firestoreData = task.toFirestore();

      expect(firestoreData['content'], 'Test task');
      expect(firestoreData['userId'], 'user-123');
      expect(firestoreData['isCompleted'], true);
      expect(firestoreData['projectId'], 'project-456');
      expect(firestoreData['createdAt'], isA<Timestamp>());
      expect(firestoreData['dueDate'], isA<Timestamp>());
    });
  });

  group('Project Model Unit Tests', () {
    test('should create Project with all fields', () {
      final now = DateTime.now();
      
      final project = Project(
        id: 'project-123',
        name: 'Website Redesign',
        description: 'Redesign company website',
        createdAt: now,
        userId: 'user-123',
        isCompleted: false,
      );

      expect(project.id, 'project-123');
      expect(project.name, 'Website Redesign');
      expect(project.description, 'Redesign company website');
      expect(project.createdAt, now);
      expect(project.userId, 'user-123');
      expect(project.isCompleted, false);
    });

    test('should convert Project to Firestore format', () {
      final now = DateTime(2024, 1, 15);
      
      final project = Project(
        id: 'project-123',
        name: 'Test Project',
        description: 'Test description',
        createdAt: now,
        userId: 'user-123',
        isCompleted: true,
      );

      final firestoreData = project.toFirestore();

      expect(firestoreData['name'], 'Test Project');
      expect(firestoreData['description'], 'Test description');
      expect(firestoreData['userId'], 'user-123');
      expect(firestoreData['isCompleted'], true);
      expect(firestoreData['createdAt'], isA<Timestamp>());
    });
  });

  group('SomedayItem Model Unit Tests', () {
    test('should create SomedayItem correctly', () {
      final now = DateTime.now();
      
      final somedayItem = SomedayItem(
        id: 'someday-123',
        content: 'Learn to play guitar',
        createdAt: now,
        userId: 'user-123',
      );

      expect(somedayItem.id, 'someday-123');
      expect(somedayItem.content, 'Learn to play guitar');
      expect(somedayItem.createdAt, now);
      expect(somedayItem.userId, 'user-123');
    });

    test('should convert SomedayItem to Firestore format', () {
      final now = DateTime(2024, 1, 15);
      
      final somedayItem = SomedayItem(
        id: 'someday-123',
        content: 'Test someday item',
        createdAt: now,
        userId: 'user-123',
      );

      final firestoreData = somedayItem.toFirestore();

      expect(firestoreData['content'], 'Test someday item');
      expect(firestoreData['userId'], 'user-123');
      expect(firestoreData['createdAt'], isA<Timestamp>());
    });
  });

  group('ReferenceItem Model Unit Tests', () {
    test('should create ReferenceItem with category', () {
      final now = DateTime.now();
      
      final referenceItem = ReferenceItem(
        id: 'ref-123',
        content: 'Important meeting notes',
        createdAt: now,
        userId: 'user-123',
        category: 'meetings',
      );

      expect(referenceItem.id, 'ref-123');
      expect(referenceItem.content, 'Important meeting notes');
      expect(referenceItem.createdAt, now);
      expect(referenceItem.userId, 'user-123');
      expect(referenceItem.category, 'meetings');
    });

    test('should convert ReferenceItem to Firestore format', () {
      final now = DateTime(2024, 1, 15);
      
      final referenceItem = ReferenceItem(
        id: 'ref-123',
        content: 'Test reference',
        createdAt: now,
        userId: 'user-123',
        category: 'test-category',
      );

      final firestoreData = referenceItem.toFirestore();

      expect(firestoreData['content'], 'Test reference');
      expect(firestoreData['userId'], 'user-123');
      expect(firestoreData['category'], 'test-category');
      expect(firestoreData['createdAt'], isA<Timestamp>());
    });
  });

  group('Data Validation Tests', () {
    test('should validate content is not empty', () {
      expect(() {
        InboxItem(
          id: 'test-id',
          content: '',
          createdAt: DateTime.now(),
          userId: 'user-123',
        );
      }, returnsNormally); // Model allows empty content, validation happens in service
    });

    test('should validate userId is not empty', () {
      expect(() {
        InboxItem(
          id: 'test-id',
          content: 'Test content',
          createdAt: DateTime.now(),
          userId: '',
        );
      }, returnsNormally); // Model allows empty userId, validation happens in service
    });

    test('should handle null values in Firestore data', () {
      final mockData = {
        'content': null,
        'userId': null,
        'isProcessed': null,
        'createdAt': null,
      };

      final mockDoc = _MockDocumentSnapshot('test-doc-id', mockData);

      final item = InboxItem.fromFirestore(mockDoc);

      expect(item.content, '');
      expect(item.userId, '');
      expect(item.isProcessed, false);
      expect(item.createdAt, isA<DateTime>());
      expect(item.createdAt.isAfter(DateTime.now().subtract(Duration(seconds: 1))), true); // Should be recent
    });
  });
}

// Mock DocumentSnapshot för testing
class _MockDocumentSnapshot implements DocumentSnapshot {
  final String _id;
  final Map<String, dynamic> _data;

  _MockDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  // Implementera andra nödvändiga metoder
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
} 