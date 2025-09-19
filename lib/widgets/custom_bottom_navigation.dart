import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: BottomAppBar(
        elevation: 0,
        height: 66,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Dashboard tab
            _buildNavItem(
              context,
              index: 0,
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard,
              label: 'Dashboard',
            ),

            // History tab
            _buildNavItem(
              context,
              index: 1,
              icon: Icons.history_outlined,
              selectedIcon: Icons.history,
              label: 'History',
            ),

            // AI Mentor tab
            _buildNavItem(
              context,
              index: 2,
              icon: Icons.psychology_outlined,
              selectedIcon: Icons.psychology,
              label: 'AI Mentor',
            ),

            // Tips tab
            _buildNavItem(
              context,
              index: 3,
              icon: Icons.lightbulb_outline,
              selectedIcon: Icons.lightbulb,
              label: 'Learn',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentIndex == index;
    
    return Expanded(
      child: InkWell(
        splashColor: theme.colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(50),
        onTap: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}