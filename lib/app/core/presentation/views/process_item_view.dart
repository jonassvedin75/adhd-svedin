import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../features/inbox/inbox_service.dart';
import '../../../features/processing/processing_service.dart';

class ProcessItemView extends ConsumerWidget {
  final InboxItem item;

  const ProcessItemView({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processingService = ref.read(processingServiceProvider);
    
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
          'Sortera tanke',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // Item to Process
            Container(
              margin: const EdgeInsets.only(top: 24, bottom: 32),
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                item.content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),

            // Action List
            _buildActionButton(
              icon: FontAwesomeIcons.circleCheck,
              text: 'Gör till en uppgift',
              onTap: () async {
                try {
                  developer.log('Försöker skapa uppgift: ${item.content}');
                  await processingService.convertToTask(item.id, item.content);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Skapade uppgift!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                } catch (e, s) {
                  developer.log('Fel vid skapande av uppgift', error: e, stackTrace: s);
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
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              icon: FontAwesomeIcons.layerGroup,
              text: 'Starta ett projekt',
              onTap: () async {
                try {
                  await processingService.convertToProject(item.id, item.content);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Skapade projekt!')),
                    );
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fel: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              icon: FontAwesomeIcons.lightbulb,
              text: 'Spara som idé/framtid',
              onTap: () async {
                try {
                  await processingService.moveToSomeday(item.id, item.content);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sparade som idé!')),
                    );
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fel: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              icon: FontAwesomeIcons.bookBookmark,
              text: 'Spara som referens',
              onTap: () async {
                try {
                  await processingService.moveToReference(item.id, item.content);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sparade som referens!')),
                    );
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fel: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              icon: FontAwesomeIcons.trashCan,
              text: 'Radera',
              isDeleteButton: true,
              onTap: () async {
                // Visa bekräftelsedialog
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Radera tanke'),
                    content: const Text('Är du säker på att du vill radera denna tanke? Detta kan inte ångras.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Avbryt'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Radera'),
                      ),
                    ],
                  ),
                );

                if (shouldDelete == true) {
                  try {
                    await processingService.deleteItem(item.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tanke raderad')),
                      );
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fel: $e')),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isDeleteButton = false,
  }) {
    final Color backgroundColor = isDeleteButton ? const Color(0xFFFEE2E2) : Colors.white;
    final Color textColor = isDeleteButton ? const Color(0xFFEF4444) : const Color(0xFF374151);
    final Color iconColor = isDeleteButton ? const Color(0xFFEF4444) : const Color(0xFF6B7280);

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        shadowColor: Colors.transparent,
      ),
      child: Row(
        children: [
          FaIcon(icon, color: iconColor, size: 20),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
