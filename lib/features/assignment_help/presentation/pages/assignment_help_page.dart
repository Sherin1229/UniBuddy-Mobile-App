import 'package:flutter/material.dart';

class AssignmentHelpPage extends StatelessWidget {
  const AssignmentHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Assignment Help Seeking\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
