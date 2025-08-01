import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routine_models.dart';
import 'routine_service.dart';
import 'routine_instance_view.dart';

// Providers
final routineServiceProvider = Provider<RoutineService>((ref) {
  return RoutineService();
});

final routineTemplatesStreamProvider = StreamProvider<List<RoutineTemplate>>((ref) {
  final service = ref.watch(routineServiceProvider);
  return service.getRoutineTemplatesStream();
});

class RoutinesView extends ConsumerWidget {
  const RoutinesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsyncValue = ref.watch(routineTemplatesStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF3B82F6), size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Rutiner',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF8B5CF6)),
            onPressed: () => _showCreateRoutineDialog(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: routinesAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Fel: $err')),
          data: (routines) {
            if (routines.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final routine = routines[index];
                return _buildRoutineCard(context, ref, routine);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoutineCard(BuildContext context, WidgetRef ref, RoutineTemplate routine) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRoutineOptionsDialog(context, ref, routine),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Ikon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    routine.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Innehåll
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${routine.steps.length} steg',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              // Play-knapp
              IconButton(
                onPressed: () => _startRoutine(context, ref, routine),
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '📋',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Inga rutiner än.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Skapa rutiner för att automatisera dina dagliga uppgifter!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  void _showCreateRoutineDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final iconController = TextEditingController(text: '📋');
    final stepsController = TextEditingController();
    final routineService = ref.read(routineServiceProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skapa ny rutin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Rutinens namn',
                  hintText: 't.ex. Morgonrutin',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'Ikon (emoji)',
                  hintText: '☀️',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stepsController,
                decoration: const InputDecoration(
                  labelText: 'Steg (en per rad)',
                  hintText: 'Bädda sängen\nDrick vatten\nTa medicin',
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Avbryt'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final icon = iconController.text.trim();
              final stepsText = stepsController.text.trim();
              
              if (name.isNotEmpty && stepsText.isNotEmpty) {
                final steps = stepsText.split('\n').where((step) => step.trim().isNotEmpty).toList();
                
                try {
                  await routineService.createRoutineTemplate(name, icon, steps);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rutin skapad!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fel: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Skapa'),
          ),
        ],
      ),
    );
  }

  void _showRoutineOptionsDialog(BuildContext context, WidgetRef ref, RoutineTemplate routine) {
    final routineService = ref.read(routineServiceProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(routine.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${routine.steps.length} steg:'),
            const SizedBox(height: 8),
            ...routine.steps.map((step) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $step'),
            )),
            const SizedBox(height: 16),
            const Text('Vad vill du göra?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Avbryt'),
          ),
          TextButton(
            onPressed: () => _showEditRoutineDialog(context, ref, routine),
            child: const Text('Redigera'),
          ),
          TextButton(
            onPressed: () => _startRoutine(context, ref, routine),
            child: const Text('Starta'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => _showDeleteRoutineDialog(context, ref, routine),
            child: const Text('Ta bort'),
          ),
        ],
      ),
    );
  }

  void _showEditRoutineDialog(BuildContext context, WidgetRef ref, RoutineTemplate routine) {
    final nameController = TextEditingController(text: routine.name);
    final iconController = TextEditingController(text: routine.icon);
    final stepsController = TextEditingController(text: routine.steps.join('\n'));
    final routineService = ref.read(routineServiceProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redigera rutin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Rutinens namn',
                  hintText: 't.ex. Morgonrutin',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'Ikon (emoji)',
                  hintText: '☀️',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stepsController,
                decoration: const InputDecoration(
                  labelText: 'Steg (en per rad)',
                  hintText: 'Bädda sängen\nDrick vatten\nTa medicin',
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Avbryt'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final icon = iconController.text.trim();
              final stepsText = stepsController.text.trim();
              
              if (name.isNotEmpty && stepsText.isNotEmpty) {
                final steps = stepsText.split('\n').where((step) => step.trim().isNotEmpty).toList();
                
                try {
                  await routineService.updateRoutineTemplate(routine.id, name, icon, steps);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Close options dialog too
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rutin uppdaterad!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fel: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Spara'),
          ),
        ],
      ),
    );
  }

  void _showDeleteRoutineDialog(BuildContext context, WidgetRef ref, RoutineTemplate routine) {
    final routineService = ref.read(routineServiceProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ta bort rutin'),
        content: Text('Är du säker på att du vill ta bort "${routine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Avbryt'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await routineService.deleteRoutineTemplate(routine.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Close options dialog too
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rutin borttagen!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fel: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Ta bort'),
          ),
        ],
      ),
    );
  }

  void _startRoutine(BuildContext context, WidgetRef ref, RoutineTemplate routine) async {
    final routineService = ref.read(routineServiceProvider);
    
    try {
      // Kontrollera om rutininstans redan finns för idag
      final hasInstance = await routineService.hasRoutineInstanceToday(routine.id);
      
      if (hasInstance) {
        // Hämta befintlig instans
        final instance = await routineService.getTodayRoutineInstance(routine.id);
        if (instance != null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RoutineInstanceView(instance: instance),
            ),
          );
        }
      } else {
        // Skapa ny instans
        final instanceId = await routineService.createRoutineInstance(
          routine.id,
          routine.name,
          routine.steps,
        );
        
        if (context.mounted) {
          final instance = await routineService.getRoutineInstance(instanceId);
          if (instance != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RoutineInstanceView(instance: instance),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
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