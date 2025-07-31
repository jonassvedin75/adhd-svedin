import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Universal inbox for quick capture of thoughts and tasks
/// ADHD-optimized for minimal friction and cognitive load
class UniversalInbox extends StatefulWidget {
  final Function(String, String)? onItemCaptured;
  
  const UniversalInbox({
    super.key,
    this.onItemCaptured,
  });

  @override
  State<UniversalInbox> createState() => _UniversalInboxState();
}

class _UniversalInboxState extends State<UniversalInbox> 
    with SingleTickerProviderStateMixin {
  
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isExpanded = false;
  String _selectedTag = 'task'; // Default context
  
  // Quick capture tags for GTD-style processing
  final List<Map<String, dynamic>> _quickTags = [
    {'id': 'task', 'label': 'Uppgift', 'icon': Icons.task_alt, 'color': Colors.blue},
    {'id': 'idea', 'label': 'Idé', 'icon': Icons.lightbulb, 'color': Colors.amber},
    {'id': 'note', 'label': 'Anteckning', 'icon': Icons.note, 'color': Colors.green},
    {'id': 'reminder', 'label': 'Påminnelse', 'icon': Icons.alarm, 'color': Colors.orange},
    {'id': 'question', 'label': 'Fråga', 'icon': Icons.help, 'color': Colors.purple},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Capture item to Firestore inbox collection
  Future<void> _captureItem() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Add to inbox collection for later processing
      await _firestore.collection('inbox').add({
        'userId': user.uid,
        'content': text,
        'tag': _selectedTag,
        'timestamp': Timestamp.now(),
        'processed': false,
      });

      // Provide haptic feedback
      HapticFeedback.lightImpact();
      
      // Animate success
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // Clear and refocus for next capture
      _textController.clear();
      _focusNode.requestFocus();

      // Notify parent if callback provided
      widget.onItemCaptured?.call(text, _selectedTag);

      // Show subtle confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(_getTagIcon(_selectedTag), size: 16),
                const SizedBox(width: 8),
                const Text('Sparat i inkorgen'),
              ],
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 100),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error capturing item: $e');
    }
  }

  IconData _getTagIcon(String tag) {
    return _quickTags.firstWhere(
      (t) => t['id'] == tag,
      orElse: () => {'icon': Icons.note},
    )['icon'];
  }

  Color _getTagColor(String tag) {
    return _quickTags.firstWhere(
      (t) => t['id'] == tag,
      orElse: () => {'color': Colors.blue},
    )['color'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Quick capture field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Animated capture button
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getTagColor(_selectedTag),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _getTagIcon(_selectedTag),
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _captureItem,
                      tooltip: 'Spara snabbt',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Text input field
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Vad kommer du ihåg?',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _captureItem(),
                    onTap: () {
                      if (!_isExpanded) {
                        setState(() {
                          _isExpanded = true;
                        });
                      }
                    },
                    autofocus: false, // Avoid keyboard pop-up issues
                  ),
                ),
                
                // Expand/collapse button
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                    if (_isExpanded) {
                      _focusNode.requestFocus();
                    } else {
                      _focusNode.unfocus();
                    }
                  },
                ),
              ],
            ),
          ),
          
          // Quick tag selection (expandable)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? 80 : 0,
            child: _isExpanded
                ? Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: _quickTags.map((tag) {
                            final isSelected = tag['id'] == _selectedTag;
                            return FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    tag['icon'],
                                    size: 16,
                                    color: isSelected 
                                        ? Colors.white 
                                        : tag['color'],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tag['label'],
                                    style: TextStyle(
                                      color: isSelected 
                                          ? Colors.white 
                                          : Colors.grey[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedTag = tag['id'];
                                });
                                HapticFeedback.selectionClick();
                              },
                              selectedColor: tag['color'],
                              backgroundColor: Colors.grey[100],
                              checkmarkColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
