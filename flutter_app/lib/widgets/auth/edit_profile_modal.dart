import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/auth_service.dart';
import '../../helpers/preference_helper.dart';

class EditProfileModal extends StatefulWidget {
  final String currentNickname;
  final String? currentAvatar;
  final VoidCallback onProfileUpdated;

  const EditProfileModal({
    super.key,
    required this.currentNickname,
    this.currentAvatar,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late TextEditingController _nicknameController;
  String? _selectedAvatar;
  bool _isLoading = false;

  final List<String> _availableAvatars = [
    'lapin.png',
    'ver.png',
    'poisson.png',
    'canard.png',
  ];

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.currentNickname);
    _selectedAvatar = widget.currentAvatar;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final newNickname = _nicknameController.text.trim();

    if (newNickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le pseudo ne peut pas être vide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save avatar to SharedPreferences
      if (_selectedAvatar != widget.currentAvatar) {
        await PreferencesHelper.saveAvatar(_selectedAvatar);
      }

      // Update nickname on backend if changed
      if (newNickname != widget.currentNickname) {
        final result = await AuthService.updateUser(nickname: newNickname);

        if (!result.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.error ?? 'Erreur lors de la mise à jour'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onProfileUpdated();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Modifier le profil',
                style: TextStyle(
                  fontSize: 60.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                iconSize: 64.sp,
              ),
            ],
          ),

          SizedBox(height: 32.h),

          // Nickname field
          TextField(
            controller: _nicknameController,
            enabled: !_isLoading,
            decoration: InputDecoration(
              labelText: 'Pseudo',
              labelStyle: TextStyle(fontSize: 44.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            style: TextStyle(fontSize: 48.sp),
          ),

          SizedBox(height: 32.h),

          // Avatar selection
          Text(
            'Choisir un avatar',
            style: TextStyle(
              fontSize: 52.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            'Illustrations @kodasmarket.art & @violetteviette.tattoo.dessin',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 32.sp,
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: 16.h),

          // Avatar grid
          SizedBox(
            height: 300.h,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
              ),
              itemCount: _availableAvatars.length,
              itemBuilder: (context, index) {
                final avatar = _availableAvatars[index];
                final isSelected = avatar == _selectedAvatar;

                return GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _selectedAvatar = avatar;
                          });
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 4 : 2,
                      ),
                      color: Colors.grey[100],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Image.asset(
                          'lib/assets/avatars/$avatar',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 80.sp,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24.h),

          // Save button
          ElevatedButton(
            onPressed: _isLoading ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Enregistrer',
                    style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }
}
