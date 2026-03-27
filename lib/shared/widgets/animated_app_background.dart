import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedAppBackground extends StatefulWidget {
  final int durationSeconds;
  final double motionScale;
  final double opacityScale;

  const AnimatedAppBackground({
    super.key,
    this.durationSeconds = 20,
    this.motionScale = 1.0,
    this.opacityScale = 1.0,
  });

  @override
  State<AnimatedAppBackground> createState() => _AnimatedAppBackgroundState();
}

class _AnimatedAppBackgroundState extends State<AnimatedAppBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = (0.2 * widget.opacityScale).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final dx = (t - 0.5) * 140 * widget.motionScale;
        final dy = (0.5 - t) * 120 * widget.motionScale;

        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE6FFFB), Color(0xFFECFEFF)],
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(dx, dy),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF14B8A6).withOpacity(opacity),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(-dx * 0.8, -dy * 0.8),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0EA5E9).withOpacity(opacity * 0.8),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
