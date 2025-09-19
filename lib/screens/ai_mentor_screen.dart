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
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Mentor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Your personal financial advisor',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Chat content
          Expanded(
            child: ListView.builder(
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
          ),
          // Bottom input area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
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
        ],
      ),
    );
  }
}


