import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color color;

  const LinkRow({
    super.key,
    required this.icon,
    required this.label,
    required this.url,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 34.sp,
              color: color,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: color,
            ),
          ),
        ],
      ),
    );
  }
}
