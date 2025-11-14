import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildStatCard(
  BuildContext context,
  String title,
  int unit,
  String unitName,
  IconData icon,
  Color iconColor,
  Color cardColor, {
  String? info,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: () {
      // Show modal dialog with more info
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (info != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(info, style: TextStyle(fontSize: 40.sp)),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sources du calcul :",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Retrouvez toutes les sources en cliquant sur le lien ci-dessous.",
                    style: TextStyle(fontSize: 40.sp),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final url = Uri.parse('https://321vegan.fr/sources');
                      if (!await launchUrl(url,
                          mode: LaunchMode.externalApplication)) {}
                    },
                    child: Text(
                      'Lien vers les sources',
                      style: TextStyle(
                        fontSize: 40.sp,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Fermer"),
            ),
          ],
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: Stack(
        children: [
          ClipPath(
            clipper: BookDividerClipper(),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              padding: EdgeInsets.all(40.w),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title.toUpperCase(),
                          style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: 35.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.sp),
                        Row(
                          children: <Widget>[
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                '$unit',
                                key: ValueKey<int>(unit),
                                style: TextStyle(
                                  fontSize: 70.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                unitName,
                                key: ValueKey<String>(unitName),
                                style: TextStyle(
                                  fontSize: 50.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 90.dm,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class BookDividerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start with the top left corner rounded
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(0, 0, size.height / 2, 0);
    path.lineTo(size.width, 0); // Top edge
    path.lineTo(size.width,
        size.height - size.height / 2); // Right edge before rounding
    // Add rounding to the bottom right corner
    path.quadraticBezierTo(
        size.width, size.height, size.width - size.height / 2, size.height);
    path.lineTo(0, size.height); // Bottom edge
    path.close(); // Close the path for a complete shape
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
