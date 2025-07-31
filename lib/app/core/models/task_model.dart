import 'package:cloud_firestore/cloud_firestore.dart';

// --- ADHD-OPTIMIZED DATA MODEL FOR A TASK ---
class Task {
  String id;
  String userId;
  String taskName;
  String description;
  String priority; // 'low', 'medium', 'high'
  int energyLevel; // 1-10, required energy level
  bool completed;
  Timestamp createdAt;
  DateTime? dueDate;
  String? dueTime;
  String context; // @home, @work, @phone
  String project; // #project-name
  List<String> tags;
  int estimatedMinutes;
  int order;
  bool isDeferred;
  DateTime? deferUntil;

  Task({
    required this.id,
    required this.userId,
    required this.taskName,
    this.description = '',
    required this.priority,
    this.energyLevel = 5,
    this.completed = false,
    required this.createdAt,
    this.dueDate,
    this.dueTime,
    this.context = '',
    this.project = '',
    this.tags = const [],
    this.estimatedMinutes = 30,
    required this.order,
    this.isDeferred = false,
    this.deferUntil,
  });

  // Convert a Firestore document to a Task object
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      userId: data['userId'] ?? '',
      taskName: data['taskName'] ?? '',
      description: data['description'] ?? '',
      priority: data['priority'] ?? 'medium',
      energyLevel: data['energyLevel'] ?? 5,
      completed: data['completed'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      dueDate: data['dueDate'] != null ? (data['dueDate'] as Timestamp).toDate() : null,
      dueTime: data['dueTime'],
      context: data['context'] ?? '',
      project: data['project'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      estimatedMinutes: data['estimatedMinutes'] ?? 30,
      order: data['order'] ?? 0,
      isDeferred: data['isDeferred'] ?? false,
      deferUntil: data['deferUntil'] != null ? (data['deferUntil'] as Timestamp).toDate() : null,
    );
  }

  // Convert a Task object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'taskName': taskName,
      'description': description,
      'priority': priority,
      'energyLevel': energyLevel,
      'completed': completed,
      'createdAt': createdAt,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'dueTime': dueTime,
      'context': context,
      'project': project,
      'tags': tags,
      'estimatedMinutes': estimatedMinutes,
      'order': order,
      'isDeferred': isDeferred,
      'deferUntil': deferUntil != null ? Timestamp.fromDate(deferUntil!) : null,
    };
  }
  
  Task copyWith({
    String? id,
    String? userId,
    String? taskName,
    String? description,
    String? priority,
    int? energyLevel,
    bool? completed,
    Timestamp? createdAt,
    DateTime? dueDate,
    String? dueTime,
    String? context,
    String? project,
    List<String>? tags,
    int? estimatedMinutes,
    int? order,
    bool? isDeferred,
    DateTime? deferUntil,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskName: taskName ?? this.taskName,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      energyLevel: energyLevel ?? this.energyLevel,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      context: context ?? this.context,
      project: project ?? this.project,
      tags: tags ?? this.tags,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      order: order ?? this.order,
      isDeferred: isDeferred ?? this.isDeferred,
      deferUntil: deferUntil ?? this.deferUntil,
    );
  }
}
