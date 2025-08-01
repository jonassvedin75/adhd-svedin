import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ai_kodhjalp/app/core/models/idea_model.dart';
import 'package:ai_kodhjalp/app/core/services/firestore_service.dart';

class IdeasView extends StatefulWidget {
  const IdeasView({super.key});

  @override
  State<IdeasView> createState() => _IdeasViewState();
}

class _IdeasViewState extends State<IdeasView> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getItemsStream(collectionPath: 'ideas'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Fel: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            final ideas = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              itemCount: ideas.length,
              itemBuilder: (context, index) {
                final ideaDoc = ideas[index];
                final idea = Idea.fromFirestore(ideaDoc);
                return _buildIdeaItem(idea);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildIdeaItem(Idea idea) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                idea.content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('💡', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text(
            'Inga idéer än.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
          SizedBox(height: 8),
          Text(
            'Bearbeta tankar från inkorgen för att spara idéer!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
