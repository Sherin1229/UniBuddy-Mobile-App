import 'package:flutter/material.dart';

class EmptyResourcesView extends StatelessWidget {
  const EmptyResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('No resources found', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
