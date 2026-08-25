import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Mapper pour les icônes d'atelier disponibles.
/// Chaque valeur est associée à une icône Material, un label et une couleur.
class AtelierIconeMapper {
  static const List<Map<String, dynamic>> _icons = [
    {
      'icon': Icons.build_rounded,
      'label': 'Technique',
      'value': 'technique',
      'color': Color(0xFF3B82F6),
    },
    {
      'icon': Icons.fitness_center_rounded,
      'label': 'Physique',
      'value': 'physique',
      'color': Color(0xFFF59E0B),
    },
    {
      'icon': Icons.map_rounded,
      'label': 'Tactique',
      'value': 'tactique',
      'color': Color(0xFF6366F1),
    },
    {
      'icon': Icons.psychology_rounded,
      'label': 'Mental',
      'value': 'mental',
      'color': Color(0xFF8B5CF6),
    },
    {
      'icon': Icons.rule_rounded,
      'label': 'Discipline',
      'value': 'discipline',
      'color': Color(0xFF10B981),
    },
    {
      'icon': Icons.lightbulb_rounded,
      'label': 'Cognitif',
      'value': 'cognitif',
      'color': Color(0xFFEC4899),
    },
  ];

  static List<Map<String, dynamic>> get icons => List.unmodifiable(_icons);

  static Map<String, dynamic>? _find(String? value) {
    if (value == null || value.isEmpty) return null;
    return _icons.firstWhere(
      (item) => item['value'] == value,
      orElse: () => <String, dynamic>{},
    );
  }

  static IconData getIcon(String? value) {
    final item = _find(value);
    return item != null && item.isNotEmpty
        ? item['icon'] as IconData
        : Icons.sports_soccer_rounded;
  }

  static String getLabel(String? value) {
    final item = _find(value);
    return item != null && item.isNotEmpty
        ? item['label'] as String
        : 'Atelier';
  }

  static Color getColor(String? value) {
    final item = _find(value);
    return item != null && item.isNotEmpty
        ? item['color'] as Color
        : AppColors.primary;
  }
}

class IconSelector extends StatelessWidget {
  final String? selectedIcon;
  final ValueChanged<String?> onIconSelected;

  const IconSelector({
    super.key,
    this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textMainDark : AppColors.textMainLight;
    final icons = AtelierIconeMapper.icons;

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
            itemCount: icons.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = icons[index];
              final isSelected = selectedIcon == item['value'];
              final color = item['color'] as Color;

              return GestureDetector(
                onTap: () => onIconSelected(item['value']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color
                        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : (isDark ? Colors.white12 : Colors.black12),
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
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
                        item['icon'] as IconData,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black54),
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'] as String,
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
