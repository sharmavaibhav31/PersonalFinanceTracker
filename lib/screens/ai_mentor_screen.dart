import 'package:flutter/material.dart';
import 'package:expense_manager/utils/theme.dart';

class AIMentorScreen extends StatelessWidget {
  const AIMentorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final samples = [
      {
        'q': 'How much did I spend on food last month?',
        'a': 'You spent ₹4,250 on Food last month across 12 transactions.'
      },
      {
        'q': 'Give me 3 ways to save money this month.',
        'a': '1) Set a weekly food budget and stick to it. 2) Use public transport three times a week. 3) Move unused subscriptions to a quarterly plan.'
      },
      {
        'q': 'Am I overspending on shopping?',
        'a': 'Your shopping spend is 18% over your monthly average. Consider setting a cap of ₹2,000.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Mentor'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: samples.length,
        itemBuilder: (context, index) {
          final item = samples[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    item['q']!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.secondaryLight,
                      child: const Icon(Icons.psychology, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item['a']!),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Ask a money question... (demo)',
                  fillColor: theme.colorScheme.surface,
                  filled: true,
                ),
                enabled: false,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI responses coming soon')),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}


