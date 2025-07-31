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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titel på egen rad
                  Text(
                    'Inkorg',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Navigation chips på egen rad, responsiva
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Lika breda, nedtonade grå navigation chips
                        _buildNavChip(
                          context: context,
                          icon: FontAwesomeIcons.listCheck,
                          label: 'Uppgifter',
                          onTap: () => context.go('/tasks'),
                        ),
                        const SizedBox(width: 8),
                        _buildNavChip(
                          context: context,
                          icon: FontAwesomeIcons.layerGroup,
                          label: 'Projekt',
                          onTap: () => context.go('/projects'),
                        ),
                        const SizedBox(width: 8),
                        _buildNavChip(
                          context: context,
                          icon: FontAwesomeIcons.lightbulb,
                          label: 'Idéer',
                          onTap: () => context.go('/someday'),
                        ),
                        const SizedBox(width: 8),
                        _buildNavChip(
                          context: context,
                          icon: FontAwesomeIcons.bookBookmark,
                          label: 'Referens',
                          onTap: () => context.go('/reference'),
                        ),
                      ],
                    ),
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
                    maxLines: null, // Tillåt flera rader för längre tankar
                    decoration: InputDecoration(
                      hintText: 'Vad tänker du på?',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onSubmitted: (value) => _addItem(ref, textController),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _addItem(ref, textController),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF059669), // Lugn grön istället för blå
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56), // Material Design standard höjd
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Mindre radius för modernare look
                      ),
                      elevation: 1, // Mindre elevation för lugnare känsla
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.psychology, // Hjärn-ikon för "fånga tanken"
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Fånga tanken',
                          style: TextStyle(
                            fontSize: 16, // Mindre text för bättre läsbarhet
                            fontWeight: FontWeight.w500, // Normal weight istället för bold
                            letterSpacing: 0.5, // Bättre läsbarhet
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Instruktioner för användaren
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0EA5E9).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: const Color(0xFF0EA5E9),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Så här sorterar du dina tankar:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0EA5E9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Skriv din tanke eller idé ovan\n2. Tryck "Fånga tanken" för att spara\n3. Klicka på din skapade tanke för att välja kategori',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF374151),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: inboxAsyncValue.when(
                  loading: () => const Center(
                    child: Text(
                      'Laddar inkorgen...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
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
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFF0EA5E9).withOpacity(0.1),
          width: 1,
        ),
      ),
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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.content,
                  style: TextStyle(
                    fontSize: 16, 
                    color: Color(0xFF374151),
                    height: 1.4,
                  ),
                ),
              ),
              // Visuell indikation att objektet är klickbart
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF0EA5E9).withOpacity(0.6),
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
          Text(
            '🌱',
            style: TextStyle(fontSize: 48),
          ),
          SizedBox(height: 16),
          Text(
            'Rent bord, klart huvud',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF059669),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Alla dina tankar är sorterade!\n\nNär du får en ny tanke eller idé,\nskriv den ovan så slipper du komma ihåg den.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
          SizedBox(height: 24),
          // Påminnelse om navigationsknapparna
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Utforska dina sorterade tankar:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Använd knapparna ovan för att se Uppgifter, Projekt, Idéer och Referens',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method för att skapa Material Design 3 navigation chips
  Widget _buildNavChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF3F4F6), // Nedtonat grå istället för färgad
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: const Color(0xFF6B7280), // Grå ikon
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280), // Grå text
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
