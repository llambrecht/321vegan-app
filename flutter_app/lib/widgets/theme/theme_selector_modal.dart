import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/seasonal_theme.dart';
import '../../helpers/theme_helper.dart';
import '../../main.dart';
import '../../services/subscription_service.dart';
import '../../pages/app_pages/Profile/subscription_page.dart';

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

    if (mounted) {
      final myAppState = MyApp.of(context);
      if (myAppState != null) {
        await myAppState.updateTheme();
      }

      Navigator.of(context).pop();
      Navigator.of(context).pop(true);

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

  void _openSubscriptionPage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isSubscribed = SubscriptionService.isSubscribed;
    final currentSeason = ThemeHelper.getCurrentSeason();
    final allThemes = ThemeHelper.getAllThemes();
    final activeTheme = _isAutoTheme
        ? ThemeHelper.getThemeBySeason(currentSeason)
        : ThemeHelper.getThemeBySeason(_selectedSeason ?? Season.defaultTheme);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        children: [
          // Header with active theme gradient
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 16.h),
                  width: 60.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(28.w, 24.h, 16.w, 24.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              activeTheme.waveColor,
                              activeTheme.primaryColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.palette,
                          size: 52.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thèmes',
                              style: TextStyle(
                                fontSize: 56.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Personnalisez l\'apparence',
                              style: TextStyle(
                                fontSize: 36.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 48.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              children: [
                // Auto theme toggle card (only for subscribers)
                if (isSubscribed) ...[
                  _buildAutoThemeToggle(currentSeason),
                  SizedBox(height: 24.h),
                ],

                // Section title
                Padding(
                  padding: EdgeInsets.only(left: 4.w, bottom: 16.h),
                  child: Text(
                    'Choisir un thème',
                    style: TextStyle(
                      fontSize: 44.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),

                // Themes grid
                ...allThemes.map((theme) {
                  final isDefault = theme.season == Season.defaultTheme;
                  final isLocked = !isDefault && !isSubscribed;
                  final isSelected =
                      !_isAutoTheme && _selectedSeason == theme.season;
                  final isCurrentSeason = theme.season == currentSeason;
                  final isActive = _isAutoTheme ? isCurrentSeason : isSelected;
                  final isDisabled =
                      (_isAutoTheme && !isCurrentSeason) || isLocked;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _buildThemeCard(
                      theme,
                      isActive: isActive,
                      isDisabled: isDisabled,
                      isCurrentSeason: isCurrentSeason,
                      isLocked: isLocked,
                    ),
                  );
                }),

                SizedBox(height: 16.h),
              ],
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveThemeSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Appliquer',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoThemeToggle(Season currentSeason) {
    final currentTheme = ThemeHelper.getThemeBySeason(currentSeason);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _isAutoTheme
              ? currentTheme.primaryColor.withValues(alpha: 0.3)
              : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _isAutoTheme
                  ? currentTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 48.sp,
              color:
                  _isAutoTheme ? currentTheme.primaryColor : Colors.grey[400],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thème automatique',
                  style: TextStyle(
                    fontSize: 44.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _isAutoTheme
                      ? 'Saison : ${ThemeHelper.getThemeDisplayName(currentSeason)}'
                      : 'Change selon la saison',
                  style: TextStyle(
                    fontSize: 36.sp,
                    color: _isAutoTheme
                        ? currentTheme.primaryColor
                        : Colors.grey[500],
                    fontWeight:
                        _isAutoTheme ? FontWeight.w600 : FontWeight.normal,
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
            activeTrackColor: currentTheme.primaryColor,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    SeasonalTheme theme, {
    required bool isActive,
    required bool isDisabled,
    required bool isCurrentSeason,
    bool isLocked = false,
  }) {
    final isDefault = theme.season == Season.defaultTheme;
    final gradientStart = isDefault ? const Color(0xFF9E9E9E) : theme.waveColor;
    final gradientEnd =
        isDefault ? const Color(0xFF616161) : theme.primaryColor;
    final shadowColor = isDefault ? Colors.grey : theme.primaryColor;
    final checkColor = isDefault ? Colors.grey[700]! : theme.primaryColor;

    return GestureDetector(
      onTap: isLocked
          ? _openSubscriptionPage
          : isDisabled
              ? null
              : () {
                  if (!_isAutoTheme) {
                    setState(() {
                      _selectedSeason = theme.season;
                    });
                  }
                },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: (isDisabled && !isLocked) ? 0.4 : isLocked ? 0.7 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 260.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isActive ? Colors.white : Colors.transparent,
              width: isActive ? 3 : 0,
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                  spreadRadius: 2,
                ),
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isActive ? 17.r : 20.r),
            child: Stack(
              children: [
                // Full gradient background
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradientStart, gradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                // Large seasonal icon in background
                Positioned(
                  right: -60.w,
                  top: -40.h,
                  child: Icon(
                    theme.seasonalIcon,
                    size: 600.r,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                // Content overlay
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top row: badges
                        Row(
                          children: [
                            if (_isAutoTheme && isCurrentSeason)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  'Saison actuelle',
                                  style: TextStyle(
                                    fontSize: 30.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            // Lock icon or selection indicator
                            if (isLocked)
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lock,
                                  size: 36.sp,
                                  color: Colors.white,
                                ),
                              )
                            else
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 48.w,
                                height: 48.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.25),
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                        alpha: isActive ? 1.0 : 0.5),
                                    width: 2,
                                  ),
                                ),
                                child: isActive
                                    ? Icon(
                                        Icons.check,
                                        size: 32.sp,
                                        color: checkColor,
                                      )
                                    : null,
                              ),
                          ],
                        ),
                        // Bottom: name + color dots
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  theme.name,
                                  style: TextStyle(
                                    fontSize: 56.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isLocked) ...[
                                  SizedBox(width: 10.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.25),
                                      borderRadius:
                                          BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      'Premium',
                                      style: TextStyle(
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                _buildColorDot(theme.primaryColor),
                                SizedBox(width: 8.w),
                                _buildColorDot(theme.secondaryColor),
                                SizedBox(width: 8.w),
                                _buildColorDot(theme.accentColor),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
