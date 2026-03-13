import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class IconSelector extends StatelessWidget {
  final String? selectedIcon;
  final ValueChanged<String?> onIconSelected;

  const IconSelector({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
  });

  static const List<Map<String, dynamic>> _icons = [
    {'icon': Icons.sports_soccer, 'label': 'Général', 'value': 'sports_soccer'},
    {'icon': Icons.directions_run, 'label': 'Physique', 'value': 'directions_run'},
    {'icon': Icons.fitness_center, 'label': 'Musculation', 'value': 'fitness_center'},
    {'icon': Icons.timer, 'label': 'Vitesse', 'value': 'timer'},
    {'icon': Icons.group, 'label': 'Collectif', 'value': 'group'},
    {'icon': Icons.person, 'label': 'Individuel', 'value': 'person'},
    {'icon': Icons.shield, 'label': 'Défense', 'value': 'shield'},
    {'icon': Icons.bolt, 'label': 'Attaque', 'value': 'bolt'},
    {'icon': Icons.sports_score, 'label': 'Finition', 'value': 'sports_score'},
    {'icon': Icons.psychology, 'label': 'Tactique', 'value': 'psychology'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Icône de l\'atelier',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _icons.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = _icons[index];
              final isSelected = selectedIcon == item['value'];

              return GestureDetector(
                onTap: () => onIconSelected(item['value']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? Colors.white12 : Colors.black12),
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'],
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black54),
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white38 : Colors.black38),
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
