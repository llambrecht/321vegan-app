import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:confetti/confetti.dart';
import '../../models/badge.dart' as app_badge;

class BadgeUnlockModal extends StatefulWidget {
  final app_badge.Badge badge;
  final VoidCallback? onClose;

  const BadgeUnlockModal({
    super.key,
    required this.badge,
    this.onClose,
  });

  @override
  State<BadgeUnlockModal> createState() => _BadgeUnlockModalState();
}

class _BadgeUnlockModalState extends State<BadgeUnlockModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Start animations
    _controller.forward();
    _confettiController.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark overlay
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            color: Colors.black.withValues(alpha: 0.7),
          ),
        ),

        // Modal content
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 40.w),
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "New Badge Unlocked" text
                  Text(
                    'Nouveau badge débloqué !',
                    style: TextStyle(
                      fontSize: 52.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 32.h),

                  // Badge icon with glow effect
                  Container(
                    width: 240.w,
                    height: 240.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.green[700]!,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: EdgeInsets.all(28.w),
                        child: Image.asset(
                          widget.badge.iconPath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.emoji_events,
                              size: 120.sp,
                              color: Colors.green[700],
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Badge name
                  Text(
                    widget.badge.name,
                    style: TextStyle(
                      fontSize: 60.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 12.h),

                  // Badge description
                  Text(
                    widget.badge.description,
                    style: TextStyle(
                      fontSize: 46.sp,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40.h),

                  // Close button
                  ElevatedButton(
                    onPressed: () {
                      widget.onClose?.call();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 48.w,
                        vertical: 20.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'Super !',
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14 / 2, // downward
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.3,
            shouldLoop: false,
            colors: [
              Colors.amber,
              Colors.orange,
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.purple,
            ],
          ),
        ),
      ],
    );
  }

  static Future<void> show(BuildContext context, app_badge.Badge badge) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => BadgeUnlockModal(badge: badge),
    );
  }
}
