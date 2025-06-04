
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF212121);
  static const Color hintColor = Color(0xFF757575);
  static const Color errorColor = Color(0xFFD32F2F);
}

class AppStrings {
  static const String appName = 'Auth App';
  static const String welcome = 'Welcome';
  static const String login = 'Login';
  static const String register = 'Register';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String dateOfBirth = 'Date of Birth';
  static const String university = 'University';
  static const String male = 'Male';
  static const String female = 'Female';
  static const String sendCode = 'Send Code';
  static const String continue_ = 'Continue';
  static const String haveAccount = 'Have an account? Login';
  static const String noAccount = 'Don\'t have an account? Register';
}

class ApiEndpoints {
  static const String baseUrl = 'https://your-api-url.com';
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String sendOtp = '$baseUrl/auth/send-otp';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String universities = '$baseUrl/universities';
}