import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routine_models.dart';

class RoutineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // ===== RUTINMALLAR =====

  // Skapa ny rutinmall
  Future<void> createRoutineTemplate(String name, String icon, List<String> steps) async {
    if (name.trim().isEmpty || _userId.isEmpty) {
      throw Exception('Ogiltig inmatning eller användare inte inloggad');
    }

    try {
      final template = RoutineTemplate(
        id: '',
        name: name.trim(),
        icon: icon,
        steps: steps.where((step) => step.trim().isNotEmpty).toList(),
        userId: _userId,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('routine_templates').add(template.toFirestore());
    } catch (e) {
      print('Error creating routine template: $e');
      throw Exception('Kunde inte skapa rutinmall: $e');
    }
  }

  // Uppdatera rutinmall
  Future<void> updateRoutineTemplate(String templateId, String name, String icon, List<String> steps) async {
    if (name.trim().isEmpty || _userId.isEmpty) {
      throw Exception('Ogiltig inmatning eller användare inte inloggad');
    }

    try {
      await _firestore.collection('routine_templates').doc(templateId).update({
        'name': name.trim(),
        'icon': icon,
        'steps': steps.where((step) => step.trim().isNotEmpty).toList(),
      });
    } catch (e) {
      print('Error updating routine template: $e');
      throw Exception('Kunde inte uppdatera rutinmall: $e');
    }
  }

  // Ta bort rutinmall
  Future<void> deleteRoutineTemplate(String templateId) async {
    try {
      await _firestore.collection('routine_templates').doc(templateId).delete();
    } catch (e) {
      print('Error deleting routine template: $e');
      throw Exception('Kunde inte ta bort rutinmall: $e');
    }
  }

  // Hämta alla rutinmallar för användaren
  Stream<List<RoutineTemplate>> getRoutineTemplatesStream() {
    if (_userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('routine_templates')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RoutineTemplate.fromFirestore(doc))
          .toList();
    });
  }

  // ===== RUTININSTANSER =====

  // Skapa ny rutininstans från mall
  Future<String> createRoutineInstance(String templateId, String name, List<String> steps) async {
    if (_userId.isEmpty) {
      throw Exception('Användare inte inloggad');
    }

    try {
      // Skapa RoutineStep-objekt från strängar
      final routineSteps = steps.map((step) => RoutineStep(text: step)).toList();

      final instance = RoutineInstance(
        id: '',
        templateId: templateId,
        name: name,
        steps: routineSteps,
        userId: _userId,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('routine_instances').add(instance.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating routine instance: $e');
      throw Exception('Kunde inte skapa rutininstans: $e');
    }
  }

  // Uppdatera steg i rutininstans
  Future<void> updateRoutineStep(String instanceId, int stepIndex, bool isDone) async {
    try {
      await _firestore.collection('routine_instances').doc(instanceId).update({
        'steps.$stepIndex.isDone': isDone,
      });
    } catch (e) {
      print('Error updating routine step: $e');
      throw Exception('Kunde inte uppdatera rutinsteg: $e');
    }
  }

  // Ta bort rutininstans
  Future<void> deleteRoutineInstance(String instanceId) async {
    try {
      await _firestore.collection('routine_instances').doc(instanceId).delete();
    } catch (e) {
      print('Error deleting routine instance: $e');
      throw Exception('Kunde inte ta bort rutininstans: $e');
    }
  }

  // Hämta rutininstanser för idag
  Stream<List<RoutineInstance>> getTodayRoutineInstancesStream() {
    if (_userId.isEmpty) return Stream.value([]);

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('routine_instances')
        .where('userId', isEqualTo: _userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RoutineInstance.fromFirestore(doc))
          .toList();
    });
  }

  // Hämta specifik rutininstans
  Future<RoutineInstance?> getRoutineInstance(String instanceId) async {
    try {
      final doc = await _firestore.collection('routine_instances').doc(instanceId).get();
      if (doc.exists) {
        return RoutineInstance.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting routine instance: $e');
      throw Exception('Kunde inte hämta rutininstans: $e');
    }
  }

  // Kontrollera om rutininstans redan finns för idag
  Future<bool> hasRoutineInstanceToday(String templateId) async {
    if (_userId.isEmpty) return false;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final querySnapshot = await _firestore
          .collection('routine_instances')
          .where('userId', isEqualTo: _userId)
          .where('templateId', isEqualTo: templateId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking routine instance: $e');
      return false;
    }
  }

  // Hämta rutininstans för idag baserat på mall
  Future<RoutineInstance?> getTodayRoutineInstance(String templateId) async {
    if (_userId.isEmpty) return null;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final querySnapshot = await _firestore
          .collection('routine_instances')
          .where('userId', isEqualTo: _userId)
          .where('templateId', isEqualTo: templateId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return RoutineInstance.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting today routine instance: $e');
      return null;
    }
  }
} 