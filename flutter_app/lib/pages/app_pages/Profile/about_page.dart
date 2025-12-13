import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/auth/login_form.dart';
import '../../../widgets/auth/register_form.dart';
import '../../../widgets/auth/forgot_password_form.dart';
import '../../../widgets/auth/user_profile.dart';
import '../../../widgets/shared/social_feedback_buttons.dart';

enum AuthView { login, register, forgotPassword, profile }

class AboutPage extends StatefulWidget {
  const AboutPage({super.key, this.onDateSaved, this.onLoginSuccess});

  final Function(DateTime)? onDateSaved;
  final VoidCallback? onLoginSuccess;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  AuthView _currentView = AuthView.login;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    setState(() {
      _isLoggedIn = AuthService.isLoggedIn;
      _currentView = _isLoggedIn ? AuthView.profile : AuthView.login;
    });

    // If logged in but user data is not loaded, fetch it
    if (_isLoggedIn && AuthService.currentUser == null) {
      final result = await AuthService.getCurrentUser();
      if (mounted) {
        setState(() {});
        // Only logout if authentication expired, not on network errors
        if (!result.isSuccess && result.error == 'AUTH_EXPIRED') {
          await AuthService.logout();
          _checkAuthStatus();
        }
        // If network error, keep user logged in - they can try again later
      }
    }
  }

  void _onLoginSuccess() {
    _checkAuthStatus();
    // Notify parent that login was successful so it can reload data
    widget.onLoginSuccess?.call();
  }

  void _onLogout() {
    _checkAuthStatus();
  }

  void _switchToRegister() {
    setState(() => _currentView = AuthView.register);
  }

  void _switchToLogin() {
    setState(() => _currentView = AuthView.login);
  }

  void _switchToForgotPassword() {
    setState(() => _currentView = AuthView.forgotPassword);
  }

  void _onRegisterSuccess() {
    // Check auth status instead of just switching to login
    // This handles automatic login after registration
    _checkAuthStatus();
    // Notify parent that registration/login was successful
    widget.onLoginSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(top: 200.h, left: 24.w, right: 24.w, bottom: 20.h),
      child: Column(
        children: [
          SizedBox(height: 100.h),
          if (!_isLoggedIn) _buildHeader(),
          SizedBox(height: 32.h),
          _buildAuthContent(),
          if (!_isLoggedIn) ...[
            SizedBox(height: 32.h),
            const SocialFeedbackButtons(showCard: false),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return _buildCard(
      child: Column(
        children: [
          Image.asset(
            'lib/assets/app_icon.png',
            fit: BoxFit.contain,
            height: 150.h,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.account_circle,
                size: 150.sp,
                color: Colors.grey,
              );
            },
          ),
          SizedBox(height: 16.h),
          Text(
            '321 Vegan',
            style: TextStyle(
              fontSize: 60.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Connectez-vous ou créez votre compte',
            style: TextStyle(
              fontSize: 44.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthContent() {
    return _buildCard(
      child: _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case AuthView.login:
        return LoginForm(
          onLoginSuccess: _onLoginSuccess,
          onSwitchToRegister: _switchToRegister,
          onSwitchToForgotPassword: _switchToForgotPassword,
        );
      case AuthView.register:
        return RegisterForm(
          onRegisterSuccess: _onRegisterSuccess,
          onSwitchToLogin: _switchToLogin,
        );
      case AuthView.forgotPassword:
        return ForgotPasswordForm(
          onBackToLogin: _switchToLogin,
        );
      case AuthView.profile:
        return UserProfile(
          onLogout: _onLogout,
          onDateSaved: widget.onDateSaved,
        );
    }
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
