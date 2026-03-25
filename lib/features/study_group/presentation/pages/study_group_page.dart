import 'package:flutter/material.dart';
import '../../../../shared/widgets/animated_app_background.dart';

class StudyGroupPage extends StatelessWidget {
  const StudyGroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedAppBackground(
              durationSeconds: 20,
              motionScale: 0.9,
              opacityScale: 1,
            ),
          ),
          Center(
            child: Card(
              elevation: 8,
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 26),
                child: Text(
                  'Study Group Creation\n(Coming Soon)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
