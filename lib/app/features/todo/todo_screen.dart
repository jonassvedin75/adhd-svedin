import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_kodhjalp/app/core/models/task_model.dart';
import 'package:ai_kodhjalp/app/core/services/firestore_service.dart';
import 'package:ai_kodhjalp/app/core/theme/app_theme.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late User _currentUser;

  String _currentFilter = 'all';
  String _currentContext = 'all';

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
  }

  Stream<List<Task>> _getFilteredTasksStream() {
    return _firestoreService.getItemsStream(collectionPath: 'tasks').map((snapshot) {
      var tasks = snapshot.docs
          .map((doc) => Task.fromFirestore(doc))
          .where((task) => !task.completed)
          .toList();

      if (_currentFilter != 'deferred') {
        tasks = tasks.where((task) => !task.isDeferred).toList();
      }

      tasks = _applyFilters(tasks);

      tasks.sort((a, b) {
        final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
        int priorityComparison = (priorityOrder[a.priority] ?? 1).compareTo(priorityOrder[b.priority] ?? 1);
        if (priorityComparison != 0) return priorityComparison;
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        } else if (a.dueDate != null) {
          return -1;
        } else if (b.dueDate != null) {
          return 1;
        }
        return a.order.compareTo(b.order);
      });
      
      return tasks;
    });
  }

  List<Task> _applyFilters(List<Task> tasks) {
    switch (_currentFilter) {
      case 'today':
        final today = DateTime.now();
        return tasks.where((task) {
          if (task.dueDate == null) return false;
          return task.dueDate!.year == today.year && 
                 task.dueDate!.month == today.month && 
                 task.dueDate!.day == today.day;
        }).toList();
      case 'high_energy':
        return tasks.where((task) => task.energyLevel >= 7).toList();
      case 'low_energy':
        return tasks.where((task) => task.energyLevel <= 4).toList();
      case 'deferred':
         return tasks.where((task) => task.isDeferred).toList();
    }

    if (_currentContext != 'all') {
      return tasks.where((task) => task.context == _currentContext).toList();
    }

    return tasks;
  }

  Future<void> _addTask(Task task) async {
    await _firestoreService.addItem(collectionPath: 'tasks', data: task.toFirestore());
  }

  Future<void> _updateTask(Task task) async {
    await _firestoreService.updateItem(collectionPath: 'tasks', docId: task.id, data: task.toFirestore());
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(completed: !task.completed);
    await _updateTask(updatedTask);
  }

  Future<void> _deleteTask(String taskId) async {
    await _firestoreService.deleteItem(collectionPath: 'tasks', docId: taskId);
  }

  Future<void> _deferTask(Task task, DateTime until) async {
    final updatedTask = task.copyWith(isDeferred: true, deferUntil: until);
    await _updateTask(updatedTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uppgifter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {}, // TODO: Implement filter dialog
            tooltip: 'Filtrera uppgifter',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickFilters(),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _getFilteredTasksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Fel: ${snapshot.error}'));
                }
                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return _buildTaskCard(tasks[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        onTaskCreated: (task) async {
          await _addTask(task);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Uppgift skapad! 🎉'), backgroundColor: AppColors.success),
            );
          }
        },
        currentUser: _currentUser,
      ),
    );
  }

  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskDetailsDialog(
        task: task,
        onTaskUpdated: (updatedTask) async => await _updateTask(updatedTask),
        onTaskDeleted: () async {
          await _deleteTask(task.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Uppgift borttagen'), backgroundColor: AppColors.warning),
            );
          }
        },
        onTaskDeferred: (until) async {
           await _deferTask(task, until);
            if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Uppgift uppskjuten till ${_formatDate(until)}'), backgroundColor: AppColors.primary),
            );
          }
        },
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('Alla', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Idag', 'today'),
          const SizedBox(width: 8),
          _buildFilterChip('Hög energi', 'high_energy'),
          const SizedBox(width: 8),
          _buildFilterChip('Låg energi', 'low_energy'),
          const SizedBox(width: 8),
          _buildFilterChip('Uppskjutna', 'deferred'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter) {
    final isSelected = _currentFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => setState(() => _currentFilter = filter),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: AppColors.bordersAndIcons),
          const SizedBox(height: 16),
          Text('Inga uppgifter här!', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Tryck på + för att lägga till en ny uppgift', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTaskDetails(task),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: task.completed,
                    onChanged: (value) => _toggleTaskCompletion(task),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.taskName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        decoration: task.completed ? TextDecoration.lineThrough : null,
                        color: task.completed ? AppColors.bordersAndIcons : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class AddTaskDialog extends StatefulWidget {
  final Function(Task) onTaskCreated;
  final User currentUser;

  const AddTaskDialog({super.key, required this.onTaskCreated, required this.currentUser});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ny uppgift'),
      content: TextField(
        controller: _titleController,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Vad behöver göras?'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Avbryt')),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) return;
            final task = Task(
              id: '',
              userId: widget.currentUser.uid,
              taskName: _titleController.text.trim(),
              createdAt: Timestamp.now(),
              priority: 'medium', // Default value
              order: 0, // Default value
            );
            widget.onTaskCreated(task);
            Navigator.pop(context);
          },
          child: const Text('Skapa'),
        ),
      ],
    );
  }
}

class TaskDetailsDialog extends StatelessWidget {
  final Task task;
  final Function(Task) onTaskUpdated;
  final VoidCallback onTaskDeleted;
  final Function(DateTime) onTaskDeferred;

  const TaskDetailsDialog({super.key, required this.task, required this.onTaskUpdated, required this.onTaskDeleted, required this.onTaskDeferred});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(task.taskName),
      content: Text(task.description),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Stäng')),
        TextButton(
          onPressed: () {
            onTaskUpdated(task.copyWith(completed: !task.completed));
            Navigator.pop(context);
          },
          child: Text(task.completed ? 'Ångra' : 'Slutför'),
        ),
        TextButton(
          onPressed: () {
            onTaskDeleted();
            Navigator.pop(context);
          },
          child: const Text('Radera', style: TextStyle(color: AppColors.danger)),
        ),
      ],
    );
  }
}
