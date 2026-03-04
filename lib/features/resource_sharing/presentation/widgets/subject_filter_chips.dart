import 'package:flutter/material.dart';

const _teal = Color(0xFF3D9E8C);

class SubjectFilterChips extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  const SubjectFilterChips({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = filters[i] == selected;
          return ChoiceChip(
            label: Text(filters[i]),
            selected: isSelected,
            onSelected: (_) => onSelected(filters[i]),
            selectedColor: _teal,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 12,
            ),
            backgroundColor: Colors.grey[200],
            shape: const StadiumBorder(),
          );
        },
      ),
    );
  }
}
