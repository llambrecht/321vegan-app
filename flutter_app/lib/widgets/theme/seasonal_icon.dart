import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/seasonal_theme.dart';

class SeasonalIcon extends StatefulWidget {
  final SeasonalTheme theme;

  const SeasonalIcon({
    super.key,
    required this.theme,
  });

  @override
  State<SeasonalIcon> createState() => _SeasonalIconState();
}

class _SeasonalIconState extends State<SeasonalIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _setupAnimations();
    _animationController.repeat(reverse: true);
  }

  void _setupAnimations() {
    // Different animations based on season
    switch (widget.theme.season) {
      case Season.defaultTheme:
        // Gentle pulsing for default theme (like original)
        _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.linear,
          ),
        );
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        break;
      case Season.spring:
        // Gentle rotation and pulsing for spring (flower blooming)
        _rotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        break;
      case Season.summer:
        // Continuous rotation and slight pulsing for summer sun
        _rotationAnimation = Tween<double>(begin: 0.0, end: 6.28).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.linear,
          ),
        );
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        break;
      case Season.autumn:
        // Gentle swaying for autumn leaves
        _rotationAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        break;
      case Season.winter:
        // Slow rotation and shimmer for snowflake
        _rotationAnimation = Tween<double>(begin: 0.0, end: 6.28).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        break;
    }
  }

  @override
  void didUpdateWidget(SeasonalIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme.season != widget.theme.season) {
      _animationController.reset();
      _setupAnimations();
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              widget.theme.seasonalIcon,
              size: 889.r,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
