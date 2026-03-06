import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FallingLeaves extends StatefulWidget {
  final int leafCount;

  const FallingLeaves({
    super.key,
    this.leafCount = 20,
  });

  @override
  State<FallingLeaves> createState() => _FallingLeavesState();
}

class _FallingLeavesState extends State<FallingLeaves>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late List<_Leaf> _leaves;
  final Random _random = Random();
  double _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _leaves = List.generate(widget.leafCount, (i) => _generateLeaf(i));
    _ticker = createTicker((duration) {
      setState(() {
        _elapsed = duration.inMilliseconds / 1000.0;
      });
    })
      ..start();
  }

  _Leaf _generateLeaf(int index) {
    // Distribute leaves across the width with randomness
    final baseX =
        (index / widget.leafCount) + (_random.nextDouble() * 0.1 - 0.05);
    return _Leaf(
      x: baseX.clamp(0.02, 0.95),
      startY: -_random.nextDouble() * 2.0, // stagger starts over a wide range
      speed: 0.07 + _random.nextDouble() * 0.13, // moderate fall speed
      // Two sway frequencies for organic motion, kept subtle
      swayAmplitude1: 0.01 + _random.nextDouble() * 0.02,
      swaySpeed1: 0.3 + _random.nextDouble() * 0.4,
      swayAmplitude2: 0.005 + _random.nextDouble() * 0.01,
      swaySpeed2: 0.8 + _random.nextDouble() * 1.2,
      rotation: _random.nextDouble() * 2 * pi,
      rotationSpeed: 0.2 + _random.nextDouble() * 0.5,
      // Wobble: leaf tilts back and forth as it falls
      wobbleAmplitude: 0.3 + _random.nextDouble() * 0.6,
      wobbleSpeed: 0.5 + _random.nextDouble() * 1.0,
      size: 30.0 + _random.nextDouble() * 25.0,
      opacity: 0.35 + _random.nextDouble() * 0.45,
      // Drift: gradual horizontal movement over time
      driftSpeed: (_random.nextDouble() - 0.5) * 0.003,
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final areaHeight = 480.h;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: _leaves.map((leaf) {
        // Continuous Y with seamless wrapping
        final rawY = leaf.startY + leaf.speed * _elapsed;
        final normalizedY = (rawY % 1.5) - 0.3;

        // Layered sway: two sine waves at different frequencies for organic feel
        final sway1 =
            sin(_elapsed * leaf.swaySpeed1 * 2 * pi) * leaf.swayAmplitude1;
        final sway2 =
            sin(_elapsed * leaf.swaySpeed2 * 2 * pi) * leaf.swayAmplitude2;
        // Gradual horizontal drift
        final drift = leaf.driftSpeed * _elapsed;
        final swayX = leaf.x + sway1 + sway2 + drift;

        // Wobble rotation (tilting back and forth) layered on base rotation
        final wobble =
            sin(_elapsed * leaf.wobbleSpeed * 2 * pi) * leaf.wobbleAmplitude;
        final rotation =
            leaf.rotation + _elapsed * leaf.rotationSpeed * 0.3 + wobble;

        return Positioned(
          left: swayX * screenWidth,
          top: normalizedY * areaHeight,
          child: Opacity(
            opacity: leaf.opacity,
            child: Transform.rotate(
              angle: rotation,
              child: Icon(
                FontAwesomeIcons.canadianMapleLeaf,
                size: leaf.size.r,
                color: Colors.white,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Leaf {
  final double x;
  final double startY;
  final double speed;
  final double swayAmplitude1;
  final double swaySpeed1;
  final double swayAmplitude2;
  final double swaySpeed2;
  final double rotation;
  final double rotationSpeed;
  final double wobbleAmplitude;
  final double wobbleSpeed;
  final double size;
  final double opacity;
  final double driftSpeed;

  _Leaf({
    required this.x,
    required this.startY,
    required this.speed,
    required this.swayAmplitude1,
    required this.swaySpeed1,
    required this.swayAmplitude2,
    required this.swaySpeed2,
    required this.rotation,
    required this.rotationSpeed,
    required this.wobbleAmplitude,
    required this.wobbleSpeed,
    required this.size,
    required this.opacity,
    required this.driftSpeed,
  });
}
