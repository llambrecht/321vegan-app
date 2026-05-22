import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildReviewCard({required Widget child, Color? backgroundColor}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(24.w),
    decoration: BoxDecoration(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: Colors.grey[200]!, width: 1),
    ),
    child: child,
  );
}
