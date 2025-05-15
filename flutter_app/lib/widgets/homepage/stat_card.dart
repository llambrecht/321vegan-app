import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildStatCard(String title, int unit, String unitName, IconData icon,
    Color iconColor, Color cardColor) {
  return Container(
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
                  color: Colors.black.withOpacity(0.2),
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
                      const SizedBox(height: 8),
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
