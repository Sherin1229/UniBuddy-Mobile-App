import 'package:flutter/material.dart';

const _teal = Color(0xFF3D9E8C);

class LoadingResourcesView extends StatelessWidget {
  const LoadingResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: _teal),
    );
  }
}
