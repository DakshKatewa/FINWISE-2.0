import 'package:budgettraker/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home, 0),
          _buildNavItem(context, Icons.explore, 1),
          const SizedBox(width: 40), // Space for FAB
          _buildNavItem(context, Icons.pie_chart, 2),
          _buildNavItem(context, Icons.analytics_rounded, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    final isSelected = selectedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.iconback : Colors.transparent,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected ? AppColors.iconColor : AppColors.iconColor,
          size: isSelected ? 28 : 24,
        ),
        onPressed: () => onDestinationSelected(index),
      ),
    );
  }
}
