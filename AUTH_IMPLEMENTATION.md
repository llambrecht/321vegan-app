# Authentication System for 321 Vegan App

## Overview

I've implemented a complete authentication system for your Flutter app that integrates with your FastAPI backend. The authentication replaces the About page and provides login, registration, and password reset functionality.

## What's Been Created

### 1. Models (`/lib/models/`)

- **`user.dart`**: User model matching your backend User structure
- **`auth.dart`**: Authentication models including:
  - `AuthToken` - for access tokens
  - `LoginRequest` - for login form data
  - `RegisterRequest` - for registration
  - `PasswordResetRequest` - for password reset requests
  - `PasswordResetConfirm` - for password reset confirmation
  - `PasswordResetTokenVerify` - for token verification

### 2. Services (`/lib/services/`)

- **`auth_service.dart`**: Complete authentication service that handles:
  - Login with OAuth2PasswordRequestForm format
  - User registration (if you add the endpoint)
  - Token storage in SharedPreferences
  - Automatic token refresh
  - Logout with server-side cleanup
  - Password reset flow
  - Current user information retrieval

### 3. UI Components (`/lib/widgets/auth/`)

- **`login_form.dart`**: Complete login form with validation
- **`register_form.dart`**: Registration form with password confirmation
- **`forgot_password_form.dart`**: Password reset request form
- **`user_profile.dart`**: User profile display when logged in

### 4. Updated Pages

- **`about_page.dart`**: Completely redesigned to show:
  - Login form when not authenticated
  - User profile when authenticated
  - Easy switching between login, register, and forgot password views

## API Integration

The service is configured to work with your existing backend endpoints:

### Implemented Endpoints:

- `POST /auth/login` - User login
- `POST /auth/refresh` - Token refresh
- `GET /auth/logout` - User logout
- `POST /auth/password-reset/request` - Request password reset
- `POST /auth/password-reset/confirm` - Confirm password reset
- `POST /auth/password-reset/verify-token` - Verify reset token

### Additional Endpoints (you may need to add):

- `POST /auth/register` - User registration
- `GET /auth/me` - Get current user profile

## Features

### Authentication Flow:

1. **Login**: Users enter email/password → gets access token → stored locally
2. **Registration**: Users create account → redirected to login
3. **Password Reset**: Email → reset link → new password
4. **Auto-refresh**: Tokens automatically refreshed when expired
5. **Logout**: Clears local storage and notifies server

### Security Features:

- Tokens stored securely in SharedPreferences
- Automatic token refresh handling
- Proper error handling and user feedback
- Form validation on all inputs
- Password visibility toggle

### UI/UX Features:

- Clean, consistent design matching your app style
- Loading states for all async operations
- Success/error messages via SnackBar
- Responsive design with ScreenUtil
- Easy navigation between auth states

## Environment Setup

Make sure your `.env` file contains:

```
API_BASE_URL=https://api.321vegan.fr
API_KEY=your_existing_api_key
```

## Usage

The authentication system is automatically initialized in `main.dart` and the About page now serves as the authentication hub. Users can:

1. **New Users**: Click "S'inscrire" → fill registration → login
2. **Existing Users**: Enter credentials → access profile
3. **Forgot Password**: Click "Mot de passe oublié" → enter email → check email for reset link
4. **Logout**: Click "Se déconnecter" in profile view

## Backend Requirements

You may need to add these endpoints to your FastAPI backend:

### User Registration Endpoint:

```python
@router.post("/register", status_code=status.HTTP_201_CREATED)
def register_user(
    user_data: UserCreate,  # Your user creation schema
    db: Session = Depends(get_db)
) -> Dict[str, str]:
    # Implementation for user registration
    pass
```

### User Profile Endpoint:

```python
@router.get("/me", response_model=UserResponse)
def get_current_user(
    current_user: User = Depends(get_current_user_from_token),
    db: Session = Depends(get_db)
) -> User:
    return current_user
```

## Integration with Product Submission

Your existing product submission functionality using API keys remains unchanged. The authentication system is separate and doesn't interfere with the existing API key-based product submissions.

When users are logged in, you could optionally:

- Associate product submissions with the logged-in user
- Show user contribution history
- Add user-specific features

The authentication system is now ready to use and provides a solid foundation for user account management in your 321 Vegan app!
