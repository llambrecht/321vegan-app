import 'package:flutter/material.dart';
import './Profile/about_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.onDateSaved,
    this.onLoginSuccess,
  });
  final Function(DateTime) onDateSaved;
  final VoidCallback? onLoginSuccess;

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
            const Stack(
              children: [],
            ),
            AboutPage(
              onDateSaved: widget.onDateSaved,
              onLoginSuccess: widget.onLoginSuccess,
            ),
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
