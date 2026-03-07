import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/seasonal_theme.dart';

class SeasonalIcon extends StatefulWidget {
  final SeasonalTheme theme;
  final double? size;
  final double? top;
  final double? left;

  const SeasonalIcon({
    super.key,
    required this.theme,
    this.size,
    this.top,
    this.left,
  });

  @override
  State<SeasonalIcon> createState() => _SeasonalIconState();
}

class _SeasonalIconState extends State<SeasonalIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late String _pumpkinAsset;
  late String _tulipAsset;

  static const _pumpkinAssets = [
    'lib/assets/images/pumpkin.webp',
    'lib/assets/images/pumpkin-smile.webp',
  ];

  static const _tulipAssets = [
    'lib/assets/images/tulipe.webp',
    'lib/assets/images/tulipe-smile.webp',
  ];

  @override
  void initState() {
    super.initState();
    _pumpkinAsset = _pumpkinAssets[Random().nextInt(_pumpkinAssets.length)];
    _tulipAsset = _tulipAssets[Random().nextInt(_tulipAssets.length)];
    _animationController = AnimationController(vsync: this);
    _setupAnimations();
    _animationController.repeat(reverse: true);
  }

  void _setupAnimations() {
    // Different animations based on season
    switch (widget.theme.season) {
      case Season.defaultTheme:
        // Gentle pulsing for default theme (like original)
        _animationController.duration = const Duration(seconds: 4);
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
        //  Bouncy hop for spring
        _animationController.duration = const Duration(seconds: 3);
        _rotationAnimation = Tween<double>(begin: -0.08, end: 0.04).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        _scaleAnimation = Tween<double>(begin: 0.7, end: 0.72).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInBack,
          ),
        );
        break;
      case Season.summer:
        // Continuous rotation and slight pulsing for summer sun
        _animationController.duration = const Duration(seconds: 4);
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
        // Faster swaying for pumpkin
        _animationController.duration = const Duration(seconds: 2);
        _rotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        _scaleAnimation = Tween<double>(begin: 0.6, end: 0.6).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        break;
      case Season.winter:
        // Slow rotation and shimmer for snowflake
        _animationController.duration = const Duration(seconds: 5);
        _rotationAnimation = Tween<double>(begin: 0.0, end: 6.28).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
        _scaleAnimation = Tween<double>(begin: 0.85, end: 0.95).animate(
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
        final iconSize = widget.size ?? 889.r;
        final topOffset = widget.top ?? widget.theme.iconTopPosition.h;
        final leftOffset = widget.left ?? widget.theme.iconLeftPosition.w;
        return Transform.translate(
          offset: Offset(leftOffset, topOffset),
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.theme.season == Season.autumn
                  ? Image.asset(
                      _pumpkinAsset,
                      width: iconSize,
                      height: iconSize,
                    )
                  : widget.theme.season == Season.spring
                      ? Image.asset(
                          _tulipAsset,
                          width: iconSize,
                          height: iconSize,
                        )
                      : Icon(
                          widget.theme.seasonalIcon,
                          size: iconSize,
                          color: Colors.white,
                        ),
            ),
          ),
        );
      },
    );
  }
}
