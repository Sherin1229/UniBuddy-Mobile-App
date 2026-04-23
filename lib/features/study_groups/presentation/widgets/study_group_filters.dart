import 'package:flutter/material.dart';
import 'package:unibuddy/core/theme/app_colors.dart';

class StudyGroupFilters extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onSelectedFilter;

  const StudyGroupFilters({
    super.key,
    required this.selectedFilter,
    required this.onSelectedFilter,
  });

  final List<String> _filters = const [
    'All Subjects',
    'Mathematics',
    'Physics',
    'Computer Science',
    'Biology',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _filters.map((filter) {
        final isSelected = selectedFilter == filter;
        return ChoiceChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (_) => onSelectedFilter(filter),
          backgroundColor: isSelected
              ? AppColors.primaryBrand
              : AppColors.cardBackground,
          selectedColor: AppColors.primaryBrand,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
        );
      }).toList(),
    );
  }
}
