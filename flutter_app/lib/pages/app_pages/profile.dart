import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vegan_app/widgets/wave_clipper.dart';
import './Profile/about_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.onDateSaved,
  });
  final Function(DateTime) onDateSaved;

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      color: Theme.of(context).colorScheme.primary,
                      height: 0.19.sh,
                    ),
                  ),
                ),
                CustomPaint(
                  size: Size.fromHeight(0.190.sh),
                  painter: WaveTextPainter("À propos"),
                ),
              ],
            ),
            const AboutPage(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
