import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart'; // Raderad oanvänd import
import 'package:ai_kodhjalp/app/core/theme/app_theme.dart';

// --- DATAMODELL FÖR EN UPPGIFT ---
class Task {
  String id;
  String userId;
  String taskName;
  String priority; // 'A', 'B', eller 'C'
  bool completed;
  Timestamp timestamp;
  int order;

  Task({
    required this.id,
    required this.userId,
    required this.taskName,
    required this.priority,
    this.completed = false,
    required this.timestamp,
    required this.order,
  });

  // Konvertera ett Firestore-dokument till ett Task-objekt
  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      userId: data['userId'] ?? '',
      taskName: data['taskName'] ?? '',
      priority: data['priority'] ?? 'B',
      completed: data['completed'] ?? false,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      order: data['order'] ?? 0,
    );
  }

  // Konvertera ett Task-objekt till en Map för Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'taskName': taskName,
      'priority': priority,
      'completed': completed,
      'timestamp': timestamp,
      'order': order,
    };
  }
}

// --- HUVUDWIDGET FÖR TODO-SKÄRMEN ---
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
  }

  // --- FIRESTORE-TJÄNSTER ---

  Stream<List<Task>> _getTasksStream() {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: _currentUser.uid)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      var tasks = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      // Sortera lokalt för att visa slutförda sist
      tasks.sort((a, b) {
        if (a.completed != b.completed) {
          return a.completed ? 1 : -1;
        }
        return a.order.compareTo(b.order);
      });
      return tasks;
    });
  }

  Future<void> _addTask(String taskName, String priority, int highestOrder) async {
    await _firestore.collection('tasks').add({
      'userId': _currentUser.uid,
      'taskName': taskName,
      'priority': priority,
      'completed': false,
      'timestamp': Timestamp.now(),
      'order': highestOrder + 1, // Lägg till sist
    });
  }

  Future<void> _updateTaskCompletion(String taskId, bool completed) async {
    await _firestore.collection('tasks').doc(taskId).update({'completed': completed});
  }

  Future<void> _deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }
  
  Future<void> _updateTaskOrder(List<Task> tasks) async {
    WriteBatch batch = _firestore.batch();
    for (int i = 0; i < tasks.length; i++) {
      DocumentReference ref = _firestore.collection('tasks').doc(tasks[i].id);
      batch.update(ref, {'order': i});
    }
    await batch.commit();
  }

  // --- UI-METODER ---

  void _showAddTaskDialog(int currentTaskCount) {
    final textController = TextEditingController();
    String selectedPriority = 'B'; // Standardprioritet

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              title: const Text('Ny uppgift', style: TextStyle(color: AppColors.text)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Vad behöver göras?',
                      labelStyle: TextStyle(color: AppColors.text),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Prioritet', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    style: SegmentedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor: AppColors.primary,
                    ),
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(value: 'A', label: Text('A'), tooltip: 'Högst'),
                      ButtonSegment<String>(value: 'B', label: Text('B'), tooltip: 'Mellan'),
                      ButtonSegment<String>(value: 'C', label: Text('C'), tooltip: 'Lågst'),
                    ],
                    selected: <String>{selectedPriority},
                    onSelectionChanged: (Set<String> newSelection) {
                      setDialogState(() {
                        selectedPriority = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Avbryt', style: TextStyle(color: AppColors.primary)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Lägg till'),
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      _addTask(textController.text, selectedPriority, currentTaskCount);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daglig ToDo-lista'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Task>>(
        stream: _getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Något gick fel: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                '''Du har inga uppgifter.
Tryck på + för att lägga till en!''',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          List<Task> tasks = snapshot.data!;

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Dismissible(
                key: ValueKey(task.id),
                background: Container(
                  color: Colors.red.shade700,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteTask(task.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${task.taskName} raderad')),
                  );
                },
                child: Card(
                  key: ValueKey(task.id),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: task.completed ? AppColors.lightGrey : Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    leading: Checkbox(
                      value: task.completed,
                      onChanged: (bool? value) {
                        _updateTaskCompletion(task.id, value ?? false);
                      },
                      activeColor: AppColors.primary,
                    ),
                    title: Text(
                      task.taskName,
                      style: TextStyle(
                        decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
                        color: task.completed ? Colors.grey[600] : AppColors.text,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    trailing: Chip(
                      label: Text(task.priority, style: const TextStyle(fontWeight: FontWeight.bold)),
                       backgroundColor: task.priority == 'A' ? Colors.red.shade100
                               : task.priority == 'B' ? Colors.orange.shade100
                               : Colors.blue.shade100,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
              );
            },
            onReorder: (int oldIndex, int newIndex) {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final Task item = tasks.removeAt(oldIndex);
              tasks.insert(newIndex, item);
              
              // Uppdatera ordningen i Firestore
              _updateTaskOrder(tasks);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(0), // Passar ett startvärde, justeras i streamen
        tooltip: 'Lägg till uppgift',
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
