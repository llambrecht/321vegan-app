import 'package:draw_on_path/draw_on_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.75);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height * 0.75);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * (3 / 4), size.height * 0.5);
    var secondEndPoint = Offset(size.width, size.height * 0.75);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class WaveTextPainter extends CustomPainter {
  final String text;

  WaveTextPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    const double leftPadding = 90.0;

    // Use ScreenUtil to adjust the height proportionally
    double startY = 365.h;

    path.moveTo(leftPadding.w, startY);

    path.lineTo(leftPadding.w, size.height * 0.75);

    var firstControlPoint = Offset(size.width / 4, size.height * 0.9);
    var firstEndPoint = Offset(size.width / 2, size.height * 0.70);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * (3 / 4), size.height * 0.42);
    var secondEndPoint = Offset(size.width, size.height * 0.65);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    // Ensure drawTextOnPath aligns text correctly
    canvas.drawTextOnPath(
      text,
      path,
      textStyle: TextStyle(
        fontSize: 60.sp,
        color: Colors.white,
        fontFamily: "Baloo",
      ),
      autoSpacing: false,
      letterSpacing: 2.0.w,
      isClosed: false,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
