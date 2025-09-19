import 'package:flutter/material.dart';
import 'package:expense_manager/widgets/custom_card.dart';
import 'package:expense_manager/widgets/progress_tracker.dart';

class LiteracyHubScreen extends StatelessWidget {
  const LiteracyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modules = [
      {'title': 'Budgeting Basics', 'duration': '5 min', 'progress': 0.8},
      {'title': 'Assets vs Liabilities', 'duration': '6 min', 'progress': 0.4},
      {'title': 'Smart Tax-Saving', 'duration': '7 min', 'progress': 0.2},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Literacy Hub'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weekly Progress', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        const LinearProgressWithLabel(
                          label: '2/5 modules completed',
                          value: 0.4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange),
                        const SizedBox(width: 12),
                        Text('Streak: 3 days 🎉', style: theme.textTheme.titleLarge),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Learn with bite-sized modules', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modules.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final item = modules[index];
                return CustomCard(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening ${item['title']} (demo)')),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] as String, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(item['duration'] as String),
                      const Spacer(),
                      LinearProgressWithLabel(
                        label: 'Progress',
                        value: item['progress'] as double,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            CustomCard(
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Badge unlocked: First 10 savings tips')),
                ],
              ),
            ),
            CustomCard(
              child: Row(
                children: [
                  const Icon(Icons.recommend, color: Colors.purple),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Next Recommendation: Emergency Fund Basics')),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}


