import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_kodhjalp/app/core/theme/app_theme.dart';

// --- FÖRBÄTTRAD ADHD-OPTIMERAD DATAMODELL ---
class Task {
  String id;
  String userId;
  String taskName;
  String description; // Detaljerad beskrivning
  String priority; // 'low', 'medium', 'high'
  int energyLevel; // 1-10, vilken energinivå krävs
  bool completed;
  Timestamp createdAt;
  DateTime? dueDate; // Valfritt datum
  String? dueTime; // Valfri tid som string (ex: "14:30")
  String context; // @hemma, @jobbet, @telefon, etc.
  String project; // #projekt-namn
  List<String> tags; // Extra taggar
  int estimatedMinutes; // Tidsuppskattning
  int order;
  bool isDeferred; // Uppskjuten till senare
  DateTime? deferUntil; // Uppskjuten tills datum

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

  // Konvertera ett Firestore-dokument till ett Task-objekt
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

  // Konvertera ett Task-objekt till en Map för Firestore
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
}

// --- FÖRBÄTTRAD ADHD-OPTIMERAD TODO-SKÄRM ---
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _currentUser;
  
  // Filter och sortering
  String _currentFilter = 'all'; // all, today, high_energy, low_energy
  String _currentContext = 'all'; // all, @hemma, @jobbet, etc.
  
  // Animation controllers
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    super.dispose();
  }

  // --- STREAM FÖR UPPGIFTER MED FILTER ---
  Stream<List<Task>> _getFilteredTasksStream() {
    var query = _firestore
        .collection('tasks')
        .where('userId', isEqualTo: _currentUser.uid)
        .where('completed', isEqualTo: false); // Visa bara icke-slutförda

    // Lägg till filter för uppskjutna uppgifter
    if (_currentFilter != 'deferred') {
      query = query.where('isDeferred', isEqualTo: false);
    }

    return query.snapshots().map((snapshot) {
      var tasks = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      
      // Applicera filter
      tasks = _applyFilters(tasks);
      
      // Sortera uppgifter intelligent
      tasks.sort((a, b) {
        // Prioritet först
        final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
        int priorityComparison = (priorityOrder[a.priority] ?? 1).compareTo(priorityOrder[b.priority] ?? 1);
        if (priorityComparison != 0) return priorityComparison;
        
        // Sedan datum om satt
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        } else if (a.dueDate != null) {
          return -1;
        } else if (b.dueDate != null) {
          return 1;
        }
        
        // Slutligen skapande-ordning
        return a.order.compareTo(b.order);
      });
      
      return tasks;
    });
  }

  List<Task> _applyFilters(List<Task> tasks) {
    // Grundfilter
    switch (_currentFilter) {
      case 'today':
        final today = DateTime.now();
        tasks = tasks.where((task) {
          if (task.dueDate == null) return false;
          return task.dueDate!.year == today.year && 
                 task.dueDate!.month == today.month && 
                 task.dueDate!.day == today.day;
        }).toList();
        break;
      case 'high_energy':
        tasks = tasks.where((task) => task.energyLevel >= 7).toList();
        break;
      case 'low_energy':
        tasks = tasks.where((task) => task.energyLevel <= 4).toList();
        break;
      case 'deferred':
        tasks = tasks.where((task) => task.isDeferred).toList();
        break;
    }

    // Kontextfilter
    if (_currentContext != 'all') {
      tasks = tasks.where((task) => task.context == _currentContext).toList();
    }

    return tasks;
  }

  // --- FÖRBÄTTRADE FIRESTORE-METODER ---
  
  Future<void> _addTask(Task task) async {
    await _firestore.collection('tasks').add(task.toFirestore());
  }

  Future<void> _updateTask(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toFirestore());
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    task.completed = !task.completed;
    await _updateTask(task);
  }

  Future<void> _deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  Future<void> _deferTask(Task task, DateTime until) async {
    task.isDeferred = true;
    task.deferUntil = until;
    await _updateTask(task);
  }

  Future<void> _undeferTask(Task task) async {
    task.isDeferred = false;
    task.deferUntil = null;
    await _updateTask(task);
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

  // --- UI KOMPONENTER ---
  
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
      onSelected: (selected) {
        setState(() {
          _currentFilter = filter;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Inga uppgifter här!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tryck på + för att lägga till en ny uppgift',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _getPriorityColor(task.priority).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showTaskDetails(task),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Huvudrad med checkbox och titel
                Row(
                  children: [
                    // Stor, tydlig checkbox
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: Checkbox(
                        value: task.completed,
                        onChanged: (value) => _toggleTaskCompletion(task),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Uppgiftstitel
                    Expanded(
                      child: Text(
                        task.taskName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: task.completed ? Colors.grey : AppColors.text,
                          decoration: task.completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    
                    // Prioritetsindikator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.priority.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getPriorityColor(task.priority),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Beskrivning (om den finns)
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                // Metadata-rad
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Energinivå
                    Icon(
                      _getEnergyIcon(task.energyLevel),
                      size: 16,
                      color: _getEnergyColor(task.energyLevel),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.energyLevel}/10',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Tidsuppskattning
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.estimatedMinutes}min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Datum (om satt)
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.event,
                        size: 16,
                        color: _isOverdue(task.dueDate!) ? Colors.red : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(task.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: _isOverdue(task.dueDate!) ? Colors.red : Colors.grey.shade600,
                          fontWeight: _isOverdue(task.dueDate!) ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
                
                // Kontext och projekt taggar
                if (task.context.isNotEmpty || task.project.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (task.context.isNotEmpty)
                        _buildTag(task.context, Colors.blue),
                      if (task.project.isNotEmpty)
                        _buildTag(task.project, Colors.green),
                      ...task.tags.map((tag) => _buildTag('#$tag', Colors.purple)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  // --- ÖVRIGA METODER ---
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('Filtrera uppgifter', style: TextStyle(color: AppColors.text)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filter för energinivå
                _buildEnergyFilter(),
                
                const SizedBox(height: 16),
                
                // Filter för datum
                _buildDateFilter(),
                
                const SizedBox(height: 16),
                
                // Filter för kontext och projekt
                _buildContextProjectFilter(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Avbryt', style: TextStyle(color: AppColors.primary)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Tillämpa filter'),
              onPressed: () {
                setState(() {
                  // Tillämpa valda filter
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnergyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Energinivå', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _energyFilterValue.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _energyFilterValue = value.toInt();
                  });
                },
                min: 1,
                max: 10,
                divisions: 9,
                label: '$_energyFilterValue',
                activeColor: AppColors.primary,
                inactiveColor: Colors.grey.shade300,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '$_energyFilterValue/10',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Datum', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: AppColors.primary,
                    accentColor: AppColors.primary,
                    colorScheme: ColorScheme.light(primary: AppColors.primary),
                    buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                  ),
                  child: child!,
                );
              },
            );
            
            if (selectedDate != null) {
              setState(() {
                _selectedDate = selectedDate;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null ? _formatDate(_selectedDate!) : 'Välj datum',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDate != null ? AppColors.text : Colors.grey.shade500,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContextProjectFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kontext och projekt', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildContextProjectChip('Alla', 'all'),
            _buildContextProjectChip('Hem', 'home'),
            _buildContextProjectChip('Jobb', 'work'),
            _buildContextProjectChip('Skola', 'school'),
            _buildContextProjectChip('Privat', 'private'),
          ],
        ),
      ],
    );
  }

  Widget _buildContextProjectChip(String label, String value) {
    final isSelected = _selectedContextProject == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedContextProject = selected ? value : null;
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.text,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
          width: 2,
        ),
      ),
    );
  }

  // --- HJÄLPMETODER ---
  
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getEnergyIcon(int energyLevel) {
    if (energyLevel >= 8) return Icons.battery_full;
    if (energyLevel >= 6) return Icons.battery_5_bar;
    if (energyLevel >= 4) return Icons.battery_3_bar;
    if (energyLevel >= 2) return Icons.battery_2_bar;
    return Icons.battery_1_bar;
  }

  Color _getEnergyColor(int energyLevel) {
    if (energyLevel >= 8) return Colors.green;
    if (energyLevel >= 6) return Colors.lightGreen;
    if (energyLevel >= 4) return Colors.orange;
    return Colors.red;
  }

  bool _isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(today);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Idag';
    if (dateOnly == tomorrow) return 'Imorgon';
    
    final weekdays = ['Mån', 'Tis', 'Ons', 'Tor', 'Fre', 'Lör', 'Sön'];
    if (dateOnly.difference(today).inDays < 7) {
      return weekdays[dateOnly.weekday - 1];
    }
    
    return '${date.day}/${date.month}';
  }

  // --- UI-METODER FÖR DETALJERAD VISNING AV UPPGIFTER ---
  
  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stäng-knapp
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: AppColors.text),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                
                // Uppgiftstitel
                Text(
                  task.taskName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Beskrivning
                if (task.description.isNotEmpty) ...[
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Detaljerad metadata-rad
                Row(
                  children: [
                    // Energinivå
                    Row(
                      children: [
                        Icon(
                          _getEnergyIcon(task.energyLevel),
                          size: 18,
                          color: _getEnergyColor(task.energyLevel),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task.energyLevel}/10',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Tidsuppskattning
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task.estimatedMinutes} min',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Datum
                    if (task.dueDate != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 18,
                            color: _isOverdue(task.dueDate!) ? Colors.red : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(task.dueDate!),
                            style: TextStyle(
                              fontSize: 14,
                              color: _isOverdue(task.dueDate!) ? Colors.red : AppColors.text,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Kontext och projekt taggar
                if (task.context.isNotEmpty || task.project.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (task.context.isNotEmpty)
                        _buildTag(task.context, Colors.blue),
                      if (task.project.isNotEmpty)
                        _buildTag(task.project, Colors.green),
                      ...task.tags.map((tag) => _buildTag('#$tag', Colors.purple)),
                    ],
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Knapp för att redigera uppgift
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Redigera uppgift',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showEditTaskDialog(task);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditTaskDialog(Task task) {
    final textController = TextEditingController(text: task.taskName);
    final descriptionController = TextEditingController(text: task.description);
    String selectedPriority = task.priority;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              title: const Text('Redigera uppgift', style: TextStyle(color: AppColors.text)),
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Beskrivning (valfritt)',
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
                  child: const Text('Spara ändringar'),
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      _updateTask(task.copyWith(
                        taskName: textController.text,
                        description: descriptionController.text,
                        priority: selectedPriority,
                      ));
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
  
  // --- DIALOGER ---
  
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        onTaskCreated: (task) async {
          await _addTask(task);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Uppgift skapad! 🎉'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
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
        onTaskUpdated: (updatedTask) async {
          await _updateTask(updatedTask);
        },
        onTaskDeleted: () async {
          await _deleteTask(task.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Uppgift borttagen'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        onTaskDeferred: (until) async {
          await _deferTask(task, until);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Uppgift uppskjuten till ${_formatDate(until)}'),
                backgroundColor: Colors.blue,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrera uppgifter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Alla uppgifter'),
              leading: Radio<String>(
                value: 'all',
                groupValue: _currentFilter,
                onChanged: (value) {
                  setState(() {
                    _currentFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Dagens uppgifter'),
              leading: Radio<String>(
                value: 'today',
                groupValue: _currentFilter,
                onChanged: (value) {
                  setState(() {
                    _currentFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Hög energi (7-10)'),
              leading: Radio<String>(
                value: 'high_energy',
                groupValue: _currentFilter,
                onChanged: (value) {
                  setState(() {
                    _currentFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Låg energi (1-4)'),
              leading: Radio<String>(
                value: 'low_energy',
                groupValue: _currentFilter,
                onChanged: (value) {
                  setState(() {
                    _currentFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stäng'),
          ),
        ],
      ),
    );
  }
}

// --- DIALOG FÖR ATT LÄGGA TILL NY UPPGIFT ---
class AddTaskDialog extends StatefulWidget {
  final Function(Task) onTaskCreated;
  final User currentUser;

  const AddTaskDialog({
    super.key,
    required this.onTaskCreated,
    required this.currentUser,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contextController = TextEditingController();
  final _projectController = TextEditingController();
  
  String _priority = 'medium';
  int _energyLevel = 5;
  int _estimatedMinutes = 30;
  DateTime? _dueDate;
  String? _dueTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contextController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titel
              const Text(
                'Ny uppgift',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 24),

              // Uppgiftens namn (obligatorisk)
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Vad behöver göras? *',
                  labelStyle: TextStyle(color: AppColors.text),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Beskrivning (valfri)
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Beskrivning (valfritt)',
                  labelStyle: TextStyle(color: AppColors.text),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  hintText: 'Lägg till detaljer här...',
                ),
              ),
              const SizedBox(height: 20),

              // Prioritet
              const Text(
                'Prioritet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                selected: {_priority},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _priority = selection.first;
                  });
                },
                segments: const [
                  ButtonSegment(value: 'low', label: Text('Låg'), icon: Icon(Icons.low_priority)),
                  ButtonSegment(value: 'medium', label: Text('Medium'), icon: Icon(Icons.flag)),
                  ButtonSegment(value: 'high', label: Text('Hög'), icon: Icon(Icons.priority_high)),
                ],
              ),
              const SizedBox(height: 20),

              // Energinivå som krävs
              const Text(
                'Energi som krävs',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Låg '),
                  Expanded(
                    child: Slider(
                      value: _energyLevel.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _energyLevel.toString(),
                      onChanged: (value) {
                        setState(() {
                          _energyLevel = value.round();
                        });
                      },
                    ),
                  ),
                  const Text(' Hög'),
                ],
              ),
              Text(
                'Energinivå: $_energyLevel/10',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              // Tidsuppskattning
              const Text(
                'Tidsuppskattning',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _estimatedMinutes,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [15, 30, 45, 60, 90, 120, 180].map((minutes) {
                  return DropdownMenuItem(
                    value: minutes,
                    child: Text('$minutes minuter'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _estimatedMinutes = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Datum (valfritt)
              const Text(
                'Datum (valfritt)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        _dueDate != null 
                          ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                          : 'Välj datum',
                      ),
                      const Spacer(),
                      if (_dueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _dueDate = null;
                              _dueTime = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kontext och projekt
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _contextController,
                      decoration: const InputDecoration(
                        labelText: '@kontext',
                        border: OutlineInputBorder(),
                        hintText: '@hemma, @jobbet...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _projectController,
                      decoration: const InputDecoration(
                        labelText: '#projekt',
                        border: OutlineInputBorder(),
                        hintText: '#app, #hus...',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Knappar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Avbryt'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _titleController.text.trim().isEmpty ? null : _createTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Skapa uppgift'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _createTask() {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task(
      id: '', // Firestore will generate
      userId: widget.currentUser.uid,
      taskName: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      energyLevel: _energyLevel,
      completed: false,
      createdAt: Timestamp.now(),
      dueDate: _dueDate,
      dueTime: _dueTime,
      context: _contextController.text.trim(),
      project: _projectController.text.trim(),
      estimatedMinutes: _estimatedMinutes,
      order: DateTime.now().millisecondsSinceEpoch, // Simple ordering
    );

    widget.onTaskCreated(task);
    Navigator.pop(context);
  }
}

// --- ENKEL TASKDETAILS DIALOG ---
class TaskDetailsDialog extends StatelessWidget {
  final Task task;
  final Function(Task) onTaskUpdated;
  final VoidCallback onTaskDeleted;
  final Function(DateTime) onTaskDeferred;

  const TaskDetailsDialog({
    super.key,
    required this.task,
    required this.onTaskUpdated,
    required this.onTaskDeleted,
    required this.onTaskDeferred,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.taskName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            const SizedBox(height: 20),
            
            // Metadata
            _buildDetailRow('Prioritet', task.priority),
            _buildDetailRow('Energi', '${task.energyLevel}/10'),
            _buildDetailRow('Tid', '${task.estimatedMinutes} min'),
            if (task.context.isNotEmpty) _buildDetailRow('Kontext', task.context),
            if (task.project.isNotEmpty) _buildDetailRow('Projekt', task.project),
            
            const SizedBox(height: 24),
            
            // Åtgärdsknappar
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final updatedTask = Task(
                      id: task.id,
                      userId: task.userId,
                      taskName: task.taskName,
                      description: task.description,
                      priority: task.priority,
                      energyLevel: task.energyLevel,
                      completed: !task.completed,
                      createdAt: task.createdAt,
                      dueDate: task.dueDate,
                      dueTime: task.dueTime,
                      context: task.context,
                      project: task.project,
                      tags: task.tags,
                      estimatedMinutes: task.estimatedMinutes,
                      order: task.order,
                      isDeferred: task.isDeferred,
                      deferUntil: task.deferUntil,
                    );
                    onTaskUpdated(updatedTask);
                    Navigator.pop(context);
                  },
                  icon: Icon(task.completed ? Icons.undo : Icons.check),
                  label: Text(task.completed ? 'Ångra' : 'Slutför'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeferDialog(context);
                  },
                  icon: const Icon(Icons.schedule),
                  label: const Text('Skjut upp'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Ta bort'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Stäng'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showDeferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skjut upp till när?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Imorgon'),
              onTap: () {
                final tomorrow = DateTime.now().add(const Duration(days: 1));
                onTaskDeferred(tomorrow);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Nästa vecka'),
              onTap: () {
                final nextWeek = DateTime.now().add(const Duration(days: 7));
                onTaskDeferred(nextWeek);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Välj datum'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  onTaskDeferred(picked);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ta bort uppgift?'),
        content: const Text('Denna åtgärd kan inte ångras.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Avbryt'),
          ),
          ElevatedButton(
            onPressed: () {
              onTaskDeleted();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ta bort', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
