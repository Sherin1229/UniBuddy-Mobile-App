
import 'package:flutter/material.dart';
import 'package:unibuddy/core/theme/app_colors.dart';

class StudyGroupSearchBar extends StatefulWidget {
  final String query;
  final bool availableOnly;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<bool> onAvailableOnlyChanged;

  const StudyGroupSearchBar({
    super.key,
    required this.query,
    required this.availableOnly,
    required this.onQueryChanged,
    required this.onAvailableOnlyChanged,
  });

  @override
  State<StudyGroupSearchBar> createState() => _StudyGroupSearchBarState();
}

class _StudyGroupSearchBarState extends State<StudyGroupSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant StudyGroupSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search groups or subjects...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textDisabled),
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            onChanged: widget.onQueryChanged,
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Checkbox(
              value: widget.availableOnly,
              onChanged: (value) {
                if (value == null) return;
                widget.onAvailableOnlyChanged(value);
              },
            ),
            const Text('Available Only'),
          ],
        ),
      ],
    );
  }
}
