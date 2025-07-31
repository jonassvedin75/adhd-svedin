import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'inbox_service.dart';
import '../../core/presentation/views/process_item_view.dart';

class InboxView extends ConsumerWidget {
  const InboxView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    final inboxAsyncValue = ref.watch(inboxStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Inkorg',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/tasks'),
                        icon: const Icon(FontAwesomeIcons.listCheck, size: 20),
                        tooltip: 'Uppgifter',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                          foregroundColor: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => context.go('/projects'),
                        icon: const Icon(FontAwesomeIcons.layerGroup, size: 20),
                        tooltip: 'Projekt',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          foregroundColor: const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => context.go('/someday'),
                        icon: const Icon(FontAwesomeIcons.lightbulb, size: 20),
                        tooltip: 'Idéer',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFFBBF24).withValues(alpha: 0.1),
                          foregroundColor: const Color(0xFFFBBF24),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => context.go('/reference'),
                        icon: const Icon(FontAwesomeIcons.bookBookmark, size: 20),
                        tooltip: 'Referens',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                          foregroundColor: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Input Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Vad tänker du på?',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onSubmitted: (value) => _addItem(ref, textController),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _addItem(ref, textController),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Fånga tanken',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: inboxAsyncValue.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Fel: $err')),
                  data: (items) {
                    if (items.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildListItem(context, item);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem(WidgetRef ref, TextEditingController controller) {
    if (controller.text.isNotEmpty) {
      ref.read(firestoreServiceProvider).addItem(controller.text);
      controller.clear();
      FocusManager.instance.primaryFocus?.unfocus(); // Dölj tangentbordet
    }
  }

  Widget _buildListItem(BuildContext context, InboxItem item) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigera till sorteringsskärmen när ett objekt trycks
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProcessItemView(item: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            item.content,
            style: TextStyle(fontSize: 16, color: Color(0xFF374151)),
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
          Text(
            '🧘',
            style: TextStyle(fontSize: 48),
          ),
          SizedBox(height: 16),
          Text(
            'Huvudet är tomt.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Skriv något ovan för att fånga en tanke!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
