import 'package:flutter/material.dart';
import 'package:expense_manager/widgets/savings_tip_card.dart';
import 'package:expense_manager/utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';


class TipsTab extends StatelessWidget {
  const TipsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Sample tips data
    final tipsList = [
      {
        'title': '50/30/20 Budget Rule',
        'description': 'Allocate 50% of your income to needs, 30% to wants, and 20% to savings and debt repayment.',
        'icon': Icons.pie_chart,
        'color': AppColors.primaryLight,
        'url': 'https://www.youtube.com/watch?v=GSieSoXTtvo'
      },
      {
        'title': 'Track Every Expense',
        'description': 'No matter how small, tracking all expenses helps identify spending patterns and areas to cut back.',
        'icon': Icons.receipt_long,
        'color': AppColors.secondaryLight,
        'url': 'https://www.youtube.com/watch?v=GSieSoXTtvo'
      },
      {
        'title': 'Automate Your Savings',
        'description': 'Set up automatic transfers to your savings account on payday to ensure you save before spending.',
        'icon': Icons.repeat,
        'color': AppColors.accentLight,
        'url': 'https://www.youtube.com/watch?v=GSieSoXTtvo'
      },
      {
        'title': 'Use the 24-Hour Rule',
        'description': 'For non-essential purchases, wait 24 hours before buying to avoid impulse spending.',
        'icon': Icons.hourglass_empty,
        'color': Colors.purple,
        'url': 'https://www.youtube.com/watch?v=GSieSoXTtvo'
      },
      {
        'title': 'Meal Planning',
        'description': 'Plan your meals for the week and create a shopping list to avoid impulse food purchases.',
        'icon': Icons.restaurant,
        'color': Colors.orange,
        'url': 'https://www.youtube.com/watch?v=GSieSoXTtvo'
      },
      {
        'title': 'Reduce Subscriptions',
        'description': 'Review and cancel unused subscriptions and memberships to save monthly recurring costs.',
        'icon': Icons.subscriptions,
        'color': Colors.red,'url': 'https://www.youtube.com/watch?v=GSieSoXTtvo'
      },
      {
        'title': 'No-Spend Days',
        'description': 'Challenge yourself to have at least one day a week where you don\'t spend any money.',
        'icon': Icons.money_off,
        'color': Colors.green,
        'url': 'https://www.youtube.com/watch?v=GSieSoXTtvo'
      },
      {
        'title': 'Emergency Fund',
        'description': 'Build an emergency fund that covers 3-6 months of expenses for financial security.',
        'icon': Icons.account_balance,
        'color': Colors.teal,
        'url': 'https://www.youtube.com/watch?v=GSieSoXTtvo'
      },
    ];
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Wisdom',
              style: theme.textTheme.headlineMedium,
            ),
            Text(
              'Smart tips to help you save money and develop better financial habits',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Tips list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tipsList.length,
              itemBuilder: (context, index) {
                final tip = tipsList[index];
                return TextButton(
                  onPressed: () async {
                    final url = Uri.parse(tip['url'] as String);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: SavingsTipCard(
                    title: tip['title'] as String,
                    description: tip['description'] as String,
                    icon: tip['icon'] as IconData,
                    color: tip['color'] as Color,
                  ),
                );
              },
            ),
            
            // Extra space for FAB
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}