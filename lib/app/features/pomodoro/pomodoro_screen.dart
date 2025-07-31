import 'package:flutter/material.dart';
import 'package:ai_kodhjalp/app/shared/widgets/visual_timer.dart';
import 'package:ai_kodhjalp/app/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ADHD-optimized Pomodoro implementation
/// Features flexible intervals, calm design, and session tracking
class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int _completedPomodoros = 0;
  bool _isBreakTime = false;
  String _currentTaskName = '';
  
  // ADHD-friendly: Flexible intervals instead of rigid 25min
  final List<Duration> _workIntervals = [
    Duration(minutes: 15),   // Short focus for low energy
    Duration(minutes: 20),   // Medium focus
    Duration(minutes: 25),   // Traditional Pomodoro
    Duration(minutes: 30),   // Extended focus for flow states
    Duration(minutes: 45),   // Deep work session
  ];
  
  final List<Duration> _breakIntervals = [
    Duration(minutes: 5),    // Short break
    Duration(minutes: 10),   // Medium break
    Duration(minutes: 15),   // Long break
    Duration(minutes: 30),   // Extended break
  ];
  
  Duration _selectedWorkInterval = Duration(minutes: 25);
  Duration _selectedBreakInterval = Duration(minutes: 5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isBreakTime ? 'Paus' : 'Fokus'),
        centerTitle: true,
        backgroundColor: _isBreakTime ? Colors.green[100] : AppColors.primary.withOpacity(0.1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showSessionHistory,
            tooltip: 'Sessionshistorik',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isBreakTime 
                ? [Colors.green[50]!, Colors.green[100]!]
                : [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 600;
              
              if (isWideScreen) {
                return _buildWideLayout();
              } else {
                return _buildNarrowLayout();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left side - Timer
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSessionInfo(),
                Expanded(
                  child: VisualTimer(
                    initialDuration: _isBreakTime ? _selectedBreakInterval : _selectedWorkInterval,
                    primaryColor: _isBreakTime ? Colors.green : AppColors.primary,
                    onComplete: _onSessionComplete,
                    onStart: _onSessionStart,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - Controls
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIntervalSelection(),
                const SizedBox(height: 16),
                if (!_isBreakTime) _buildTaskInput(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 
                     AppBar().preferredSize.height - 
                     MediaQuery.of(context).padding.top - 
                     MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          children: [
            // Session info
            _buildSessionInfo(),
            
            // Main timer - constrained height
            Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: VisualTimer(
                initialDuration: _isBreakTime ? _selectedBreakInterval : _selectedWorkInterval,
                primaryColor: _isBreakTime ? Colors.green : AppColors.primary,
                onComplete: _onSessionComplete,
                onStart: _onSessionStart,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Interval selection
            _buildIntervalSelection(),
            
            // Task input
            if (!_isBreakTime) _buildTaskInput(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isBreakTime ? Icons.coffee : Icons.work,
                color: _isBreakTime ? Colors.green : AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  _isBreakTime ? 'Vila och återhämta' : 'Fokuserad arbetstid',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          
          if (_completedPomodoros > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Genomförda sessioner idag: $_completedPomodoros',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          
          if (_currentTaskName.isNotEmpty && !_isBreakTime) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arbetar med:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentTaskName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIntervalSelection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isBreakTime ? 'Pauslängd:' : 'Fokustid:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 400) {
                // Wide layout - use Row with spacing
                return Row(
                  children: (_isBreakTime ? _breakIntervals : _workIntervals)
                      .map((duration) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildIntervalChip(duration),
                            ),
                          ))
                      .toList(),
                );
              } else {
                // Narrow layout - use Wrap
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_isBreakTime ? _breakIntervals : _workIntervals)
                      .map((duration) => _buildIntervalChip(duration))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalChip(Duration duration) {
    final isSelected = duration == (_isBreakTime ? _selectedBreakInterval : _selectedWorkInterval);
    return FilterChip(
      label: Text('${duration.inMinutes}m'),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          if (_isBreakTime) {
            _selectedBreakInterval = duration;
          } else {
            _selectedWorkInterval = duration;
          }
        });
      },
      selectedColor: (_isBreakTime ? Colors.green : AppColors.primary).withOpacity(0.2),
      backgroundColor: Colors.grey[100],
      showCheckmark: false,
    );
  }

  Widget _buildTaskInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vad ska du fokusera på?',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Skriv vad du ska jobba med...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            maxLines: 2,
            onChanged: (value) {
              setState(() {
                _currentTaskName = value;
              });
            },
          ),
        ],
      ),
    );
  }

  void _onSessionStart() {
    // Optional: Save session start to analytics
  }

  void _onSessionComplete() {
    setState(() {
      if (!_isBreakTime) {
        _completedPomodoros++;
      }
      _isBreakTime = !_isBreakTime;
    });
    
    _saveSessionData();
    
    // Show completion message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isBreakTime ? '🎉 Session klar!' : '☕ Paus slut!'),
        content: Text(
          _isBreakTime 
              ? 'Bra jobbat! Dags för en välförtjänt paus.'
              : 'Pausen är över. Redo för nästa fokussession?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSessionData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('pomodoro_sessions').add({
        'userId': user.uid,
        'sessionType': _isBreakTime ? 'work' : 'break', // What we just completed
        'duration': (_isBreakTime ? _selectedWorkInterval : _selectedBreakInterval).inMinutes,
        'taskName': _currentTaskName,
        'completedAt': Timestamp.now(),
        'date': DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD
      });
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  void _showSessionHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sessionshistorik',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('pomodoro_sessions')
                    .where('userId', isEqualTo: _auth.currentUser?.uid)
                    .orderBy('completedAt', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Inga sessioner genomförda än'),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final timestamp = (data['completedAt'] as Timestamp).toDate();
                      
                      return ListTile(
                        leading: Icon(
                          data['sessionType'] == 'work' ? Icons.work : Icons.coffee,
                          color: data['sessionType'] == 'work' ? AppColors.primary : Colors.green,
                        ),
                        title: Text(
                          data['sessionType'] == 'work' 
                              ? 'Arbete (${data['duration']}m)'
                              : 'Paus (${data['duration']}m)',
                        ),
                        subtitle: Text(
                          data['taskName']?.isNotEmpty == true 
                              ? data['taskName']
                              : '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: Text(
                          '${timestamp.day}/${timestamp.month}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
