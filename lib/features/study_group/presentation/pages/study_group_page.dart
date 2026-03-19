import 'package:flutter/material.dart';

class StudyGroupPage extends StatelessWidget {
  const StudyGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Study Group Creation\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
