import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedAppBackground extends StatefulWidget {
  final int durationSeconds;
  final double motionScale;
  final double opacityScale;

  const AnimatedAppBackground({
    super.key,
    this.durationSeconds = 18,
    this.motionScale = 1,
    this.opacityScale = 1,
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
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final t = _controller.value * math.pi * 2;

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE6FFFB), Color(0xFFCCFBF1), Color(0xFFF0FDFA)],
            ),
          ),
          child: Stack(
            children: [
              _movingBlob(
                alignment: Alignment(
                  -0.9 + math.sin(t) * (0.2 * widget.motionScale),
                  -0.8,
                ),
                size: 260,
                color: _scaledOpacityColor(
                  const Color(0x3314B8A6),
                  widget.opacityScale,
                ),
              ),
              _movingBlob(
                alignment: Alignment(
                  0.85,
                  -0.2 + math.cos(t * 0.9) * (0.35 * widget.motionScale),
                ),
                size: 220,
                color: _scaledOpacityColor(
                  const Color(0x330F766E),
                  widget.opacityScale,
                ),
              ),
              _movingBlob(
                alignment: Alignment(
                  -0.1 + math.sin(t * 0.7) * (0.5 * widget.motionScale),
                  0.95,
                ),
                size: 300,
                color: _scaledOpacityColor(
                  const Color(0x332CC6B7),
                  widget.opacityScale,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _scaledOpacityColor(Color color, double factor) {
    final scaled = (color.opacity * factor).clamp(0.0, 1.0);
    return color.withOpacity(scaled);
  }

  Widget _movingBlob({
    required Alignment alignment,
    required double size,
    required Color color,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.7),
              blurRadius: 80,
              spreadRadius: 18,
            ),
          ],
        ),
      ),
    );
  }
}
