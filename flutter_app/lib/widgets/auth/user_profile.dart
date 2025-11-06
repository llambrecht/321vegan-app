import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../pages/app_pages/Scan/sent_products_modal.dart';
import '../../helpers/preference_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);

    final result = await AuthService.getCurrentUser();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _user = result.data;
        }
      });
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);

    final result = await AuthService.logout();

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
          // Profile icon
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              size: 64.sp,
              color: Colors.green,
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
        ],
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
                builder: (context) => Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
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
            iconColor: Colors.blue,
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
