import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ai_kodhjalp/app/core/services/firestore_service.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getItemsStream(collectionPath: 'tasks'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Fel: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            final tasks = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskItem(context, task);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, QueryDocumentSnapshot task) {
    final data = task.data() as Map<String, dynamic>;
    final content = data['content'] as String? ?? 'Namnlös uppgift';
    final isCompleted = data['isCompleted'] as bool? ?? false;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Checkbox(
              value: isCompleted,
              onChanged: (value) async {
                if (value != null) {
                  try {
                    await _firestoreService.updateItem(
                      collectionPath: 'tasks',
                      docId: task.id,
                      data: {'isCompleted': value},
                    );
                    if (value == true) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Uppgift slutförd! 🎉'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kunde inte uppdatera uppgiften: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              activeColor: const Color(0xFF10B981),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: isCompleted ? const Color(0xFF9CA3AF) : const Color(0xFF374151),
                  decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('✅', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text(
            'Inga uppgifter än.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
          SizedBox(height: 8),
          Text(
            'Bearbeta tankar från inkorgen för att skapa uppgifter!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
