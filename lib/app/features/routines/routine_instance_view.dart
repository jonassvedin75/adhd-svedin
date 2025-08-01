import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routine_models.dart';
import 'routine_service.dart';
import 'routines_view.dart';

class RoutineInstanceView extends ConsumerStatefulWidget {
  final RoutineInstance instance;

  const RoutineInstanceView({super.key, required this.instance});

  @override
  ConsumerState<RoutineInstanceView> createState() => _RoutineInstanceViewState();
}

class _RoutineInstanceViewState extends ConsumerState<RoutineInstanceView> {
  late RoutineInstance _instance;
  late RoutineService _routineService;

  @override
  void initState() {
    super.initState();
    _instance = widget.instance;
    _routineService = ref.read(routineServiceProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF3B82F6), size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _instance.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Progress Bar
            _buildProgressSection(),
            const SizedBox(height: 32),
            // Steps List
            Expanded(
              child: _buildStepsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: _instance.progress,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          // Progress Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Framsteg',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${_instance.completedSteps} av ${_instance.totalSteps}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Percentage
          Text(
            '${(_instance.progress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    return ListView.builder(
      itemCount: _instance.steps.length,
      itemBuilder: (context, index) {
        final step = _instance.steps[index];
        return _buildStepCard(index, step);
      },
    );
  }

  Widget _buildStepCard(int index, RoutineStep step) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _toggleStep(index, step),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: step.isDone ? const Color(0xFF10B981) : Colors.transparent,
                  border: Border.all(
                    color: step.isDone ? const Color(0xFF10B981) : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: step.isDone
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Step Text
              Expanded(
                child: Text(
                  step.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: step.isDone ? const Color(0xFF9CA3AF) : const Color(0xFF374151),
                    decoration: step.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleStep(int index, RoutineStep step) async {
    try {
      await _routineService.updateRoutineStep(_instance.id, index, !step.isDone);
      
      // Uppdatera lokalt state
      setState(() {
        final updatedSteps = List<RoutineStep>.from(_instance.steps);
        updatedSteps[index] = step.copyWith(isDone: !step.isDone);
        _instance = _instance.copyWith(steps: updatedSteps);
      });

      // Visa feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(step.isDone ? 'Steg ångrat' : 'Steg avklarat!'),
            backgroundColor: step.isDone ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 