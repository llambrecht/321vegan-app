import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/seasonal_theme.dart';
import '../../helpers/theme_helper.dart';
import 'theme_preview_card.dart';
import '../../main.dart';

class ThemeSelectorModal extends StatefulWidget {
  const ThemeSelectorModal({super.key});

  @override
  State<ThemeSelectorModal> createState() => _ThemeSelectorModalState();
}

class _ThemeSelectorModalState extends State<ThemeSelectorModal> {
  bool _isAutoTheme = true;
  Season? _selectedSeason;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final isAuto = await ThemeHelper.isAutoThemeEnabled();
    final savedSeason = await ThemeHelper.getSavedThemePreference();

    setState(() {
      _isAutoTheme = isAuto;
      _selectedSeason = savedSeason ??
          (isAuto ? ThemeHelper.getCurrentSeason() : Season.defaultTheme);
      _isLoading = false;
    });
  }

  Future<void> _saveThemeSettings() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await ThemeHelper.saveAutoThemePreference(_isAutoTheme);
    if (!_isAutoTheme && _selectedSeason != null) {
      await ThemeHelper.saveThemePreference(_selectedSeason);
    }

    // Update the theme in the app
    if (mounted) {
      final myAppState = MyApp.of(context);
      if (myAppState != null) {
        await myAppState.updateTheme();
      }

      // Close loading dialog
      Navigator.of(context).pop();
      // Close the modal
      Navigator.of(context).pop(true);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Thème mis à jour avec succès !',
            style: TextStyle(fontSize: 50.sp, fontFamily: 'Baloo'),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentSeason = ThemeHelper.getCurrentSeason();
    final allThemes = ThemeHelper.getAllThemes();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 20.h),
            width: 100.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 30.h),
          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choisir un thème',
                  style: TextStyle(
                    fontSize: 90.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Baloo',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 80.r),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          // Auto theme toggle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thème automatique',
                          style: TextStyle(
                            fontSize: 60.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Baloo',
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Change selon la saison en cours',
                          style: TextStyle(
                            fontSize: 45.sp,
                            color: Colors.grey.shade600,
                            fontFamily: 'Baloo',
                          ),
                        ),
                        if (_isAutoTheme)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              'Saison actuelle : ${ThemeHelper.getThemeDisplayName(currentSeason)}',
                              style: TextStyle(
                                fontSize: 45.sp,
                                color:
                                    ThemeHelper.getThemeBySeason(currentSeason)
                                        .primaryColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Baloo',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isAutoTheme,
                    onChanged: (value) {
                      setState(() {
                        _isAutoTheme = value;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30.h),
          // Theme list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: allThemes.length,
              itemBuilder: (context, index) {
                final theme = allThemes[index];
                final isSelected =
                    !_isAutoTheme && _selectedSeason == theme.season;
                final isCurrentSeason = theme.season == currentSeason;

                return Stack(
                  children: [
                    Opacity(
                      opacity: _isAutoTheme && !isCurrentSeason ? 0.5 : 1.0,
                      child: ThemePreviewCard(
                        theme: theme,
                        isSelected: _isAutoTheme ? isCurrentSeason : isSelected,
                        onTap: _isAutoTheme
                            ? () {}
                            : () {
                                setState(() {
                                  _selectedSeason = theme.season;
                                });
                              },
                      ),
                    ),
                    if (_isAutoTheme && !isCurrentSeason)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          // Apply button
          Padding(
            padding: EdgeInsets.all(32.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveThemeSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Appliquer le thème',
                  style: TextStyle(
                    fontSize: 60.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Baloo',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
