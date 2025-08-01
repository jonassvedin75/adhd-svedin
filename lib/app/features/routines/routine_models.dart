import 'package:cloud_firestore/cloud_firestore.dart';

// Rutinsteg för en instans
class RoutineStep {
  final String text;
  final bool isDone;

  RoutineStep({
    required this.text,
    this.isDone = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'isDone': isDone,
    };
  }

  factory RoutineStep.fromFirestore(Map<String, dynamic> data) {
    return RoutineStep(
      text: data['text'] ?? '',
      isDone: data['isDone'] ?? false,
    );
  }

  RoutineStep copyWith({
    String? text,
    bool? isDone,
  }) {
    return RoutineStep(
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }
}

// Rutinmall - template för rutiner
class RoutineTemplate {
  final String id;
  final String name;
  final String icon;
  final List<String> steps;
  final String userId;
  final DateTime createdAt;

  RoutineTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.steps,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'steps': steps,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RoutineTemplate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RoutineTemplate(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '📋',
      steps: List<String>.from(data['steps'] ?? []),
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  RoutineTemplate copyWith({
    String? id,
    String? name,
    String? icon,
    List<String>? steps,
    String? userId,
    DateTime? createdAt,
  }) {
    return RoutineTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      steps: steps ?? this.steps,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Rutininstans - aktiv rutin för en specifik dag
class RoutineInstance {
  final String id;
  final String templateId;
  final String name;
  final List<RoutineStep> steps;
  final String userId;
  final DateTime date;
  final DateTime createdAt;

  RoutineInstance({
    required this.id,
    required this.templateId,
    required this.name,
    required this.steps,
    required this.userId,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'templateId': templateId,
      'name': name,
      'steps': steps.map((step) => step.toFirestore()).toList(),
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RoutineInstance.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RoutineInstance(
      id: doc.id,
      templateId: data['templateId'] ?? '',
      name: data['name'] ?? '',
      steps: (data['steps'] as List<dynamic>? ?? [])
          .map((stepData) => RoutineStep.fromFirestore(Map<String, dynamic>.from(stepData)))
          .toList(),
      userId: data['userId'] ?? '',
      date: data['date'] != null 
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  RoutineInstance copyWith({
    String? id,
    String? templateId,
    String? name,
    List<RoutineStep>? steps,
    String? userId,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return RoutineInstance(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      steps: steps ?? this.steps,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Beräkna progress (0.0 till 1.0)
  double get progress {
    if (steps.isEmpty) return 0.0;
    final completedSteps = steps.where((step) => step.isDone).length;
    return completedSteps / steps.length;
  }

  // Antal avklarade steg
  int get completedSteps => steps.where((step) => step.isDone).length;

  // Totalt antal steg
  int get totalSteps => steps.length;
} 