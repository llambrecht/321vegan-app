import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/api_service.dart';

class SubscriptionGoalWidget extends StatefulWidget {
  final int goal;
  final VoidCallback? onTap;

  const SubscriptionGoalWidget({
    super.key,
    this.goal = 1000,
    this.onTap,
  });

  @override
  State<SubscriptionGoalWidget> createState() => _SubscriptionGoalWidgetState();
}

class _SubscriptionGoalWidgetState extends State<SubscriptionGoalWidget>
    with SingleTickerProviderStateMixin {
  int? _count;
  bool _loaded = false;
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fetchCount();
  }

  Future<void> _fetchCount() async {
    final count = await ApiService.getSubscriptionCount();
    if (count != null && mounted) {
      final progress = (count / widget.goal).clamp(0.0, 1.0);
      setState(() {
        _count = count;
        _loaded = true;
        _progressAnim = Tween<double>(begin: 0, end: progress).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
      });
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    final count = _count!;
    final goal = widget.goal;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.white, size: 48.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Pour rémunérer un temps plein sur le projet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo',
                    ),
                  ),
                ),
                if (widget.onTap != null)
                  Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 36.sp),
              ],
            ),
            SizedBox(height: 14.h),
            AnimatedBuilder(
              animation: _progressAnim,
              builder: (context, _) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: LinearProgressIndicator(
                        value: _progressAnim.value,
                        minHeight: 14.h,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$count soutiens',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Baloo',
                          ),
                        ),
                        Text(
                          'Objectif : $goal',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 34.sp,
                            fontFamily: 'Baloo',
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 6.h),
            Text(
              count >= goal
                  ? 'Objectif atteint ! Merci !'
                  : 'Chaque abonnement compte, merci pour votre contribution ♡',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 32.sp,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
