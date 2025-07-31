import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai_kodhjalp/app/core/responsive/responsive_layout.dart';
import 'package:ai_kodhjalp/app/core/ios/ios_security.dart';
import 'package:ai_kodhjalp/app/core/theme/app_theme.dart';
import 'package:ai_kodhjalp/app/shared/widgets/universal_inbox.dart';
import 'package:ai_kodhjalp/app/shared/widgets/visual_timer.dart';
import 'package:go_router/go_router.dart';

/// ADHD-optimized dashboard with minimal cognitive load
/// Features: Universal inbox, visual timer, quick actions, energy awareness
class ADHDDashboard extends StatefulWidget {
  const ADHDDashboard({super.key});

  @override
  State<ADHDDashboard> createState() => _ADHDDashboardState();
}

class _ADHDDashboardState extends State<ADHDDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int _currentEnergyLevel = 5; // 1-10 scale
  String _currentMood = 'neutral';
  bool _isTimerExpanded = false;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    
    return IOSResponsiveWrapper(
      child: ResponsiveLayout(
        mobile: _buildMobileLayout(context, user),
        tablet: _buildTabletLayout(context, user),
        desktop: _buildDesktopLayout(context, user),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, User? user) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Gentle header without overwhelming content
            _buildGentleHeader(context, user),
            
            // Universal inbox - always accessible
            SliverToBoxAdapter(
              child: UniversalInbox(
                onItemCaptured: (content, tag) {
                  // Optional: Show gentle feedback
                },
              ),
            ),
            
            // Energy & mood check-in
            SliverToBoxAdapter(
              child: _buildEnergyMoodCard(),
            ),
            
            // Visual timer section
            SliverToBoxAdapter(
              child: _buildTimerCard(),
            ),
            
            // Quick actions based on current energy
            SliverToBoxAdapter(
              child: _buildAdaptiveQuickActions(),
            ),
            
            // Today's focus (simplified)
            SliverToBoxAdapter(
              child: _buildTodaysFocus(),
            ),
            
            // Recent captures from inbox
            SliverToBoxAdapter(
              child: _buildRecentCaptures(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, User? user) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Capture & Timer
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildGentleHeaderTablet(context, user),
                    const SizedBox(height: 24),
                    UniversalInbox(),
                    const SizedBox(height: 24),
                    _buildTimerCard(),
                  ],
                ),
              ),
              
              const SizedBox(width: 24),
              
              // Right column - Actions & Status
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildEnergyMoodCard(),
                    const SizedBox(height: 24),
                    _buildAdaptiveQuickActions(),
                    const SizedBox(height: 24),
                    _buildTodaysFocus(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, User? user) {
    return _buildTabletLayout(context, user); // Similar layout for desktop
  }

  Widget _buildGentleHeader(BuildContext context, User? user) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting = hour < 12 ? 'God morgon' : hour < 17 ? 'God dag' : 'God kväll';
    
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey,
                    ),
                  ),
                  if (user?.displayName != null)
                    Text(
                      user!.displayName!,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                ],
              ),
            ),
            // Gentle settings access
            IconButton(
              onPressed: () => context.go('/settings'),
              icon: const Icon(Icons.settings_outlined),
              iconSize: 28,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGentleHeaderTablet(BuildContext context, User? user) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting = hour < 12 ? 'God morgon' : hour < 17 ? 'God dag' : 'God kväll';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            greeting,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.grey,
            ),
          ),
          if (user?.displayName != null)
            Text(
              user!.displayName!,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnergyMoodCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Row(
            children: [
              Icon(Icons.battery_charging_full, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Hur mår du just nu?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Energy level slider
          Text(
            'Energinivå: $_currentEnergyLevel/10',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Slider(
            value: _currentEnergyLevel.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: _getEnergyColor(_currentEnergyLevel),
            onChanged: (value) {
              setState(() {
                _currentEnergyLevel = value.round();
              });
              _saveEnergyMood();
            },
          ),
          
          const SizedBox(height: 16),
          
          // Simple mood selection
          const Text(
            'Humör:',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              {'id': 'happy', 'emoji': '😊', 'label': 'Glad'},
              {'id': 'neutral', 'emoji': '😐', 'label': 'Neutral'},
              {'id': 'tired', 'emoji': '😴', 'label': 'Trött'},
              {'id': 'stressed', 'emoji': '😰', 'label': 'Stressad'},
              {'id': 'focused', 'emoji': '🎯', 'label': 'Fokuserad'},
            ].map((mood) {
              final isSelected = _currentMood == mood['id'];
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(mood['emoji']!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 4),
                    Text(mood['label']!),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _currentMood = mood['id']!;
                  });
                  _saveEnergyMood();
                },
                selectedColor: Colors.blue[100],
                backgroundColor: Colors.grey[100],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isTimerExpanded ? 400 : 120,
          child: Column(
            children: [
              // Timer header
              ListTile(
                leading: const Icon(Icons.timer_outlined, color: AppColors.primary),
                title: const Text(
                  'Fokustimer',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Använd för fokuserade arbetspass'),
                trailing: IconButton(
                  icon: Icon(_isTimerExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isTimerExpanded = !_isTimerExpanded;
                    });
                  },
                ),
              ),
              
              // Timer content (expandable)
              if (_isTimerExpanded)
                Expanded(
                  child: VisualTimer(
                    onComplete: () {
                      // Timer completed - show gentle notification
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fokussession klar! Bra jobbat! 🎉'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdaptiveQuickActions() {
    // Adapt actions based on energy level
    List<Map<String, dynamic>> actions = [];
    
    if (_currentEnergyLevel >= 7) {
      // High energy - challenging tasks
      actions = [
        {'icon': Icons.assignment, 'label': 'Planera projekt', 'route': '/planning'},
        {'icon': Icons.code, 'label': 'Kreativt arbete', 'route': '/creative'},
        {'icon': Icons.call, 'label': 'Samtal & möten', 'route': '/meetings'},
      ];
    } else if (_currentEnergyLevel >= 4) {
      // Medium energy - routine tasks  
      actions = [
        {'icon': Icons.checklist, 'label': 'Att-göra lista', 'route': '/todo'},
        {'icon': Icons.email, 'label': 'E-post & admin', 'route': '/admin'},
        {'icon': Icons.book, 'label': 'Läsa & lära', 'route': '/learning'},
      ];
    } else {
      // Low energy - gentle activities
      actions = [
        {'icon': Icons.self_improvement, 'label': 'Andning & vila', 'route': '/breathe'},
        {'icon': Icons.music_note, 'label': 'Lugn musik', 'route': '/music'},
        {'icon': Icons.nature, 'label': 'Enkel reflektion', 'route': '/reflect'},
      ];
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getEnergyIcon(_currentEnergyLevel), 
                       color: _getEnergyColor(_currentEnergyLevel), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Anpassade aktiviteter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...actions.map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(action['icon'], color: AppColors.primary),
                  title: Text(action['label']),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Colors.grey[50],
                  onTap: () => context.go(action['route']),
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysFocus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.today, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Dagens fokus',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Vad är det viktigaste att få gjort idag?',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tryck för att sätta dagens fokus',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCaptures() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.inbox, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Senaste från inkorgen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('inbox')
                    .where('userId', isEqualTo: _auth.currentUser?.uid)
                    .where('processed', isEqualTo: false)
                    .orderBy('timestamp', descending: true)
                    .limit(3)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text(
                      'Inga nya objekt i inkorgen',
                      style: TextStyle(color: Colors.grey[600]),
                    );
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(_getTagIcon(data['tag'] ?? 'note'), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                data['content'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  Color _getEnergyColor(int level) {
    if (level >= 8) return Colors.green;
    if (level >= 6) return Colors.orange;
    if (level >= 4) return Colors.yellow;
    return Colors.red;
  }

  IconData _getEnergyIcon(int level) {
    if (level >= 8) return Icons.battery_full;
    if (level >= 6) return Icons.battery_5_bar;
    if (level >= 4) return Icons.battery_3_bar;
    return Icons.battery_1_bar;
  }

  IconData _getTagIcon(String tag) {
    switch (tag) {
      case 'task': return Icons.task_alt;
      case 'idea': return Icons.lightbulb;
      case 'note': return Icons.note;
      case 'reminder': return Icons.alarm;
      case 'question': return Icons.help;
      default: return Icons.note;
    }
  }

  Future<void> _saveEnergyMood() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('energy_logs').add({
        'userId': user.uid,
        'energyLevel': _currentEnergyLevel,
        'mood': _currentMood,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error saving energy/mood: $e');
    }
  }
}
