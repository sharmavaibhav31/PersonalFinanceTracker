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
    
    return BottomAppBar(
      height: 60,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
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
          
          // Empty space for FAB
          const SizedBox(width: 40),
          
          // Tips tab
          _buildNavItem(
            context,
            index: 2,
            icon: Icons.lightbulb_outline,
            selectedIcon: Icons.lightbulb,
            label: 'Tips',
          ),
        ],
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