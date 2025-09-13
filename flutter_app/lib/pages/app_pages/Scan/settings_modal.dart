import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vegan_app/helpers/preference_helper.dart';

class SettingsModal extends StatefulWidget {
  final bool initialOpenOnScanPage;
  final Function(bool) onOpenOnScanPageChanged;

  const SettingsModal({
    super.key,
    required this.initialOpenOnScanPage,
    required this.onOpenOnScanPageChanged,
  });

  @override
  SettingsModalState createState() => SettingsModalState();
}

class SettingsModalState extends State<SettingsModal> {
  late bool _openOnScanPage;

  @override
  void initState() {
    super.initState();
    _openOnScanPage = widget.initialOpenOnScanPage;
  }

  Future<void> _setOpenOnScanPagePref(bool value) async {
    await PreferencesHelper.setOpenOnScanPagePref(value);
    setState(() {
      _openOnScanPage = value;
    });
    widget.onOpenOnScanPageChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: const Color(0xFF1A722E),
                size: 60.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Paramètres',
                style: TextStyle(
                  fontSize: 60.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Page par défaut',
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Ouvrir directement sur la page de scan',
                        style: TextStyle(
                          fontSize: 30.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _openOnScanPage,
                  onChanged: (value) {
                    _setOpenOnScanPagePref(value);
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF1A722E),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
