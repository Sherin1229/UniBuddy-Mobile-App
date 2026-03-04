import 'package:flutter/material.dart';

const _teal = Color(0xFF3D9E8C);

class ResourceSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const ResourceSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search resources...',
          prefixIcon: const Icon(Icons.search, color: _teal),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
