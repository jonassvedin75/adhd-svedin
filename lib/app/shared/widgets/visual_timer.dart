import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

/// ADHD-optimized visual timer with calm, non-stressful design
/// Features timstock-inspired shrinking circles for gentle time awareness
class VisualTimer extends StatefulWidget {
  final Duration initialDuration;
  final VoidCallback? onComplete;
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final Color? primaryColor;
  final Color? backgroundColor;
  final bool enableHapticFeedback;
  
  const VisualTimer({
    super.key,
    this.initialDuration = const Duration(minutes: 25),
    this.onComplete,
    this.onStart,
    this.onPause,
    this.primaryColor,
    this.backgroundColor,
    this.enableHapticFeedback = true,
  });

  @override
  State<VisualTimer> createState() => _VisualTimerState();
}

class _VisualTimerState extends State<VisualTimer>
    with TickerProviderStateMixin {
  
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isRunning = false;
  bool _isPaused = false;
  
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  // Calming color scheme
  late Color _primaryColor;
  late Color _backgroundColor;
  late Color _accentColor;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialDuration;
    _totalDuration = widget.initialDuration;
    
    // Initialize colors
    _primaryColor = widget.primaryColor ?? const Color(0xFF6B73FF);
    _backgroundColor = widget.backgroundColor ?? Colors.grey[100]!;
    _accentColor = _primaryColor.withOpacity(0.2);
    
    // Setup animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: widget.initialDuration,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingTime <= Duration.zero) {
      _resetTimer();
    }
    
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    
    // Start progress animation
    _progressController.duration = _remainingTime;
    _progressController.forward();
    
    // Start gentle pulse
    _pulseController.repeat(reverse: true);
    
    // Haptic feedback
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    
    widget.onStart?.call();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = _remainingTime - const Duration(seconds: 1);
      });
      
      // Gentle haptic feedback at quarter intervals
      if (widget.enableHapticFeedback) {
        final progress = _remainingTime.inSeconds / _totalDuration.inSeconds;
        if (progress == 0.75 || progress == 0.5 || progress == 0.25) {
          HapticFeedback.selectionClick();
        }
      }
      
      if (_remainingTime <= Duration.zero) {
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _progressController.stop();
    _pulseController.stop();
    
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    
    widget.onPause?.call();
  }

  void _resetTimer() {
    _timer?.cancel();
    _progressController.reset();
    _pulseController.stop();
    
    setState(() {
      _remainingTime = _totalDuration;
      _isRunning = false;
      _isPaused = false;
    });
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _progressController.stop();
    _pulseController.stop();
    
    setState(() {
      _remainingTime = Duration.zero;
      _isRunning = false;
      _isPaused = false;
    });
    
    // Gentle completion feedback
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    
    widget.onComplete?.call();
  }

  void _adjustDuration(int minutes) {
    if (_isRunning) return; // Can't adjust while running
    
    final newDuration = Duration(minutes: minutes);
    setState(() {
      _totalDuration = newDuration;
      _remainingTime = newDuration;
    });
    
    _progressController.duration = newDuration;
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remainingTime.inSeconds / _totalDuration.inSeconds;
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Timer duration presets (only when not running)
          if (!_isRunning && !_isPaused) ...[
            const Text(
              'Välj fokustid',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [5, 10, 15, 25, 30, 45].map((minutes) {
                final isSelected = _totalDuration.inMinutes == minutes;
                return FilterChip(
                  label: Text('${minutes}m'),
                  selected: isSelected,
                  onSelected: (_) => _adjustDuration(minutes),
                  selectedColor: _accentColor,
                  backgroundColor: Colors.grey[100],
                  labelStyle: TextStyle(
                    color: isSelected ? _primaryColor : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],
          
          // Main timer circle
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isRunning ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 280,
                  height: 280,
                  child: CustomPaint(
                    painter: TimerCirclePainter(
                      progress: progress,
                      primaryColor: _primaryColor,
                      backgroundColor: _backgroundColor,
                      strokeWidth: 8,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTime(_remainingTime),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w300,
                              color: _primaryColor,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          if (_isRunning || _isPaused) ...[
                            const SizedBox(height: 8),
                            Text(
                              _isRunning ? 'Fokuserar...' : 'Pausad',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset button
              if (_isPaused || (_remainingTime != _totalDuration && !_isRunning))
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh),
                    iconSize: 32,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.grey[600],
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              
              // Main play/pause button
              Container(
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  icon: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    size: 36,
                  ),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(20),
                  ),
                ),
              ),
            ],
          ),
          
          // Progress indicator
          if (_isRunning || _isPaused) ...[
            const SizedBox(height: 24),
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 1 - progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom painter for the timer circle with calming design
class TimerCirclePainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;
  final double strokeWidth;

  TimerCirclePainter({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
    this.strokeWidth = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress circle with gradient effect
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.6),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
