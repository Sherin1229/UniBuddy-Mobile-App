import 'package:flutter/material.dart';

class EmptyResourcesView extends StatelessWidget {
  const EmptyResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No resources found.'),
    );
  }
}
