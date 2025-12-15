import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../services/auth_service.dart';
import '../../services/badge_service.dart';
import '../../models/user.dart';
import '../../models/badge.dart' as app_badge;
import '../../pages/app_pages/Scan/sent_products_modal.dart';
import '../../helpers/preference_helper.dart';
import './edit_profile_modal.dart';
import '../shared/social_feedback_buttons.dart';

class UserProfile extends StatefulWidget {
  final VoidCallback? onLogout;
  final Function(DateTime)? onDateSaved;

  const UserProfile({
    super.key,
    this.onLogout,
    this.onDateSaved,
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  User? _user;
  bool _isLoading = false;
  String? _selectedAvatar;

  final List<String> _availableAvatars = [
    'lapin.png',
    'ver.png',
    'poisson.png',
    'canard.png',
    'poule.png',
    'mouton.png',
    'cochon.png',
    'vache.png'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  String _getRandomAvatar(String? currentAvatar) {
    final random = Random();
    final availableCopy = List<String>.from(_availableAvatars);

    // Remove current avatar from available choices
    if (currentAvatar != null && availableCopy.contains(currentAvatar)) {
      availableCopy.remove(currentAvatar);
    }

    // If we still have options, pick a random one
    if (availableCopy.isNotEmpty) {
      return availableCopy[random.nextInt(availableCopy.length)];
    }

    // Fallback: return a random avatar from full list
    return _availableAvatars[random.nextInt(_availableAvatars.length)];
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);

    final result = await AuthService.getCurrentUser();
    final avatar = await PreferencesHelper.getAvatar();
    final randomAvatarEnabled =
        await PreferencesHelper.getRandomAvatarEnabled();

    if (mounted) {
      String? finalAvatar = avatar;

      // If random avatar is enabled, pick a new random one
      if (randomAvatarEnabled) {
        finalAvatar = _getRandomAvatar(avatar);
        // Save the new random avatar
        await PreferencesHelper.saveAvatar(finalAvatar);
      }

      setState(() {
        _isLoading = false;
        _selectedAvatar = finalAvatar;
        if (result.isSuccess) {
          _user = result.data;
        }
      });
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);

    final result = await AuthService.logout();

    // Clear badge tracking on logout
    await BadgeService.clearBadgeTracking();

    if (mounted) {
      setState(() => _isLoading = false);

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Déconnexion réussie !'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onLogout?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Erreur lors de la déconnexion'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    setState(() => _isLoading = true);
    final result = await AuthService.deleteAccount(context, _user);

    // Clear badge tracking on account deletion
    await BadgeService.clearBadgeTracking();

    if (mounted) {
      setState(() => _isLoading = false);
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte supprimé avec succès.'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onLogout?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(result.error ?? 'Erreur lors de la suppression du compte'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProfileCard(),
        SizedBox(height: 24.h),
        _buildStatsCards(),
        SizedBox(height: 24.h),
        _buildBadgesSection(),
        SizedBox(height: 24.h),
        _buildSocialAndFeedbackSection(),
        SizedBox(height: 32.h),
        _buildActionsCard(),
      ],
    );
  }

  Widget _buildProfileCard() {
    return _buildCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile avatar
          GestureDetector(
            onTap: _openEditProfileModal,
            child: SizedBox(
              width: 400.w,
              height: 480.w,
              child: ClipOval(
                child: _selectedAvatar != null
                    ? Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Image.asset(
                          'lib/assets/avatars/$_selectedAvatar',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 64.sp,
                              color: Colors.green,
                            );
                          },
                        ),
                      )
                    : Image.asset(
                        'lib/assets/avatars/cochon.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 64.sp,
                            color: Colors.green,
                          );
                        },
                      ),
              ),
            ),
          ),

          SizedBox(width: 24.w),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user?.nickname ?? 'Utilisateur',
                  style: TextStyle(
                    fontSize: 56.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  _user?.email ?? '',
                  style: TextStyle(
                    fontSize: 44.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Edit button
          IconButton(
            onPressed: _openEditProfileModal,
            icon: Icon(
              Icons.edit,
              size: 64.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _openEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: EditProfileModal(
          currentNickname: _user?.nickname ?? 'Utilisateur',
          currentAvatar: _selectedAvatar,
          onProfileUpdated: () {
            _loadUserInfo();
          },
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        // Products sent card
        Expanded(
          child: _buildStatCard(
            icon: Icons.info_outline,
            iconColor: Colors.black,
            title: 'Produits envoyés',
            value: _user?.nbProductsSent?.toString() ?? '0',
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: const SentProductsModal(),
                ),
              );
            },
          ),
        ),
        SizedBox(width: 16.w),
        // Vegan since card
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            iconColor: Theme.of(context).primaryColor,
            title: 'Végane depuis',
            value: _user?.veganSince != null
                ? DateFormat.yMMMd('fr_FR').format(_user!.veganSince!)
                : 'Non défini',
            onTap: _pickVeganDate,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48.sp,
                color: iconColor,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 36.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 44.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVeganDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _user?.veganSince ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );

    if (picked != null && picked != _user?.veganSince) {
      setState(() => _isLoading = true);

      // Update both local storage and backend (via PreferencesHelper)
      await PreferencesHelper.addSelectedDateToPrefs(picked);

      // Refresh user data from backend to get the updated info
      final result = await AuthService.getCurrentUser();

      if (mounted) {
        setState(() => _isLoading = false);

        if (result.isSuccess) {
          setState(() {
            _user = result.data;
          });

          // Notify the home page about the date change
          widget.onDateSaved?.call(picked);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Date mise à jour avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Erreur lors de la mise à jour'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildActionsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Actions du compte',
            style: TextStyle(
              fontSize: 52.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 24.h),

          // Account info text
          Text(
            'Votre compte permet de conserver certaines données et de collectionner des badges.',
            style: TextStyle(
              fontSize: 42.sp,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          SizedBox(height: 32.h),

          // Logout button
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleLogout,
            icon: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.logout),
            label: Text(
              _isLoading ? 'Déconnexion...' : 'Se déconnecter',
              style: TextStyle(fontSize: 44.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 16.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),

          // Delete button
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleDeleteAccount,
            icon: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.delete),
            label: Text(
              _isLoading ? 'Suppression...' : 'Supprimer mon compte',
              style: TextStyle(fontSize: 44.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 16.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    final productsSent = _user?.nbProductsSent ?? 0;
    final veganSince = _user?.veganSince;
    final supporterLevel = _user?.supporterLevel ?? 0;
    final errorReports = _user?.nbErrorReports ?? 0;

    // Sort badges: unlocked first, then locked
    // Supporter badge is always first (locked or not)
    final sortedBadges = List<app_badge.Badge>.from(app_badge.Badges.all);
    sortedBadges.sort((a, b) {
      if (a.type == app_badge.BadgeType.supporter) return -1;
      if (b.type == app_badge.BadgeType.supporter) return 1;

      final aUnlocked = a.isUnlocked(
        productsSent: productsSent,
        veganSince: veganSince,
        supporterLevel: supporterLevel,
        errorSolved: errorReports,
      );
      final bUnlocked = b.isUnlocked(
        productsSent: productsSent,
        veganSince: veganSince,
        supporterLevel: supporterLevel,
        errorSolved: errorReports,
      );

      // Unlocked badges first (true comes before false)
      if (aUnlocked && !bUnlocked) return -1;
      if (!aUnlocked && bUnlocked) return 1;
      return 0; // Keep original order within same unlock status
    });

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                size: 64.sp,
                color: Colors.amber[700],
              ),
              SizedBox(width: 40.w),
              Text(
                'Badges',
                style: TextStyle(
                  fontSize: 56.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Badges grid (show all)
          GridView.builder(
            padding: EdgeInsets.all(25.w),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.85,
            ),
            itemCount: sortedBadges.length,
            itemBuilder: (context, index) {
              final badge = sortedBadges[index];
              final isUnlocked = badge.isUnlocked(
                productsSent: productsSent,
                veganSince: veganSince,
                supporterLevel: supporterLevel,
                errorSolved: errorReports,
              );

              return _buildBadgeItem(badge, isUnlocked);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialAndFeedbackSection() {
    return const SocialFeedbackButtons(showCard: true);
  }

  Widget _buildBadgeItem(app_badge.Badge badge, bool isUnlocked) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(badge, isUnlocked),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge icon
          Container(
            width: 180.w,
            height: 180.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? Colors.white : Colors.grey[300],
              border: Border.all(
                color: isUnlocked
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[400]!,
                width: isUnlocked ? 3 : 2,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color:
                            Theme.of(context).colorScheme.primary.withAlpha(80),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: ClipOval(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: ColorFiltered(
                      colorFilter: isUnlocked
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            )
                          : const ColorFilter.matrix(<double>[
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                            ]),
                      child: Image.asset(
                        badge.iconPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.emoji_events,
                            size: 80.sp,
                            color: isUnlocked
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[600],
                          );
                        },
                      ),
                    ),
                  ),
                  if (!isUnlocked)
                    Center(
                      child: Icon(
                        Icons.lock,
                        size: 64.sp,
                        color: Colors.orange[700],
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // Badge name
          Text(
            badge.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
              color: isUnlocked ? Colors.grey[800] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetails(app_badge.Badge badge, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon
            Container(
              width: 200.w,
              height: 200.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked ? Colors.white : Colors.grey[300],
                border: Border.all(
                  color: isUnlocked
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[400]!,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: ColorFiltered(
                        colorFilter: isUnlocked
                            ? const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              )
                            : const ColorFilter.matrix(<double>[
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ]),
                        child: Image.asset(
                          badge.iconPath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.emoji_events,
                              size: 100.sp,
                              color: isUnlocked
                                  ? Colors.amber[700]
                                  : Colors.grey[600],
                            );
                          },
                        ),
                      ),
                    ),
                    if (!isUnlocked)
                      Center(
                        child: Icon(
                          Icons.lock,
                          size: 64.sp,
                          color: Colors.orange[700],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Badge name
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 56.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),

            SizedBox(height: 12.h),

            // Badge description
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 44.sp,
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: 16.h),

            // Status
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isUnlocked ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUnlocked ? Icons.check_circle : Icons.lock_outline,
                    size: 44.sp,
                    color: isUnlocked ? Colors.green : Colors.orange,
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      isUnlocked
                          ? 'Badge débloqué !'
                          : badge.getRequirementText(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            isUnlocked ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
