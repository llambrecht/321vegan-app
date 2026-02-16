import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../helpers/preference_helper.dart';

class DraggableProfileBubble extends StatefulWidget {
  final String? avatar;
  final VoidCallback onTap;

  const DraggableProfileBubble({
    super.key,
    this.avatar,
    required this.onTap,
  });

  @override
  State<DraggableProfileBubble> createState() => _DraggableProfileBubbleState();
}

class _DraggableProfileBubbleState extends State<DraggableProfileBubble>
    with SingleTickerProviderStateMixin {
  Offset _position = Offset(800.w, 200.h);
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedPosition();

    // Setup pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPosition() async {
    final position = await PreferencesHelper.getProfileBubblePosition();
    if (position != null && mounted) {
      setState(() {
        _position = position;
      });
    }
  }

  Future<void> _savePosition() async {
    await PreferencesHelper.saveProfileBubblePosition(_position);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Draggable(
        feedback: _buildBubble(isDragging: true),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildBubble(),
        ),
        onDragEnd: (details) {
          setState(() {
            // Get screen boundaries
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            final bubbleSize = 300.w;

            // Calculate new position with boundaries
            double newX = details.offset.dx;
            double newY = details.offset.dy;

            // Ensure bubble stays within screen bounds
            newX = newX.clamp(0, screenWidth - bubbleSize);
            newY = newY.clamp(0, screenHeight - bubbleSize);

            _position = Offset(newX, newY);
          });
          _savePosition();
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: _buildBubble(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBubble({bool isDragging = false}) {
    return Container(
      width: 300.w,
      height: 300.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDragging ? 0.3 : 0.15),
            blurRadius: isDragging ? 20 : 10,
            spreadRadius: isDragging ? 2 : 1,
            offset: Offset(0, isDragging ? 8 : 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 8.w,
        ),
      ),
      child: ClipOval(
        child: widget.avatar != null
            ? Padding(
                padding: EdgeInsets.all(20.w),
                child: Image.asset(
                  'lib/assets/avatars/${widget.avatar}',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 100.sp,
                      color: Theme.of(context).colorScheme.primary,
                    );
                  },
                ),
              )
            : Padding(
                padding: EdgeInsets.all(20.w),
                child: Image.asset(
                  'lib/assets/avatars/cochon.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 100.sp,
                      color: Theme.of(context).colorScheme.primary,
                    );
                  },
                ),
              ),
      ),
    );
  }
}
