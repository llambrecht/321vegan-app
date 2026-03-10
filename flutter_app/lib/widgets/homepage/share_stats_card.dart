import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vegan_app/helpers/time_counter/time_counter.dart';
import 'package:vegan_app/widgets/homepage/stat_card.dart';
import 'package:vegan_app/widgets/wave_clipper.dart';

class ShareStatsWidget extends StatelessWidget {
  final DateTime? targetDate;
  final int animalUnit;
  final int co2Unit;
  final int forestUnit;
  final int waterUnit;

  const ShareStatsWidget({
    super.key,
    required this.targetDate,
    required this.animalUnit,
    required this.co2Unit,
    required this.forestUnit,
    required this.waterUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                  color: Theme.of(context).colorScheme.primary,
                  height: 480.h),
            ),
          ),
          Positioned(
            top: 42.h,
            left: -72.w,
            child: Opacity(
              opacity: 1.0,
              child: Icon(
                Icons.sunny,
                size: 889.r,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(40.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 128.h),
                SizedBox(height: 128.h),
                Text(
                  "Vous êtes végane depuis",
                  style: TextStyle(
                    fontSize: 90.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Baloo',
                  ),
                ),
                TimeCounter(targetDate: targetDate),
                SizedBox(height: 64.h),
                buildStatCard(
                  context,
                  'Animaux épargnés',
                  animalUnit,
                  '',
                  Icons.favorite,
                  const Color.fromARGB(247, 255, 103, 153),
                  Colors.pinkAccent,
                  info: "...",
                ),
                buildStatCard(
                  context,
                  'CO₂ non émis',
                  co2Unit,
                  'KG',
                  Icons.arrow_downward_sharp,
                  const Color.fromARGB(255, 255, 133, 133),
                  Colors.redAccent,
                  info: "...",
                ),
                buildStatCard(
                  context,
                  'Forêt préservée',
                  forestUnit,
                  'm²',
                  Icons.forest_sharp,
                  const Color.fromARGB(127, 105, 240, 175),
                  const Color.fromARGB(197, 36, 139, 87),
                  info: "...",
                ),
                buildStatCard(
                  context,
                  'Eau économisée',
                  waterUnit,
                  'm³',
                  Icons.water_drop,
                  const Color.fromARGB(255, 97, 166, 250),
                  Colors.blueAccent,
                  info: "...",
                ),
                SizedBox(height: 128.h),
                Column(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'lib/assets/app_icon.png',
                        width: 256.w,
                        height: 256.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '321 Vegan',
                      style: TextStyle(
                        fontSize: 60.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Baloo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
