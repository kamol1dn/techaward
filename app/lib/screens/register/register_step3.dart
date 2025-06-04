
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/otp_field.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../models/university_model.dart';

class RegisterStep3 extends StatefulWidget {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final University university;

  const RegisterStep3({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.university,
  }) : super(key: key);

  @override
  State<RegisterStep3> createState() => _RegisterStep3State();
}

class _RegisterStep3State extends State<RegisterStep3> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _showOtpField = false;
  bool _isOtpVerified = false;
  int _otpAttempts = 0;
  DateTime? _lastOtpSent;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final error = Validators.validateEmail(_emailController.text.trim());
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    // Check if user can send OTP (max 3 attempts with 2-minute timeout)
    if (_otpAttempts >= 3 &&
        _lastOtpSent != null &&
        DateTime.now().difference(_lastOtpSent!).inMinutes < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Too many attempts. Try again in 2 minutes.')),
      );
      return;
    }

    if (_otpAttempts >= 3) {
      _otpAttempts = 0; // Reset after timeout
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendOtp(_emailController.text.trim());

    setState(() {
      _isLoading = false;
      _otpAttempts++;
      _lastOtpSent = DateTime.now();
    });

    if (success) {
      setState(() => _showOtpField = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your email')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP. Please try again.')),
      );
    }
  }

  Future<void> _verifyOtp(String otp) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOtp(_emailController.text.trim(), otp);

    if (success) {
      setState(() => _isOtpVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || !_isOtpVerified) return;

    setState(() => _isLoading = true);

    final userData = {
      'firstName': widget.firstName,
      'lastName': widget.lastName,
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'dateOfBirth': widget.dateOfBirth.toIso8601String(),
      'gender': widget.gender,
      'universityId': widget.university.id,
      'universityName': widget.university.name,
    };

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(userData);

    setState(() => _isLoading = false);

    if (success) {
      // Navigate to main screen - handled by main.dart
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
  }

  bool _canContinue() {
    return _formKey.currentState?.validate() == true && _isOtpVerified;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: const Text(
          'Register (3/3)',
          style: TextStyle(color: AppColors.textColor),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: AppStrings.email,
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: _showOtpField ? 'Resend Code' : AppStrings.sendCode,
                    onPressed: _sendOtp,
                    isLoading: _isLoading,
                    backgroundColor: _showOtpField ? AppColors.secondaryColor : AppColors.primaryColor,
                  ),
                  if (_showOtpField) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Enter OTP sent to your email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OtpField(onCompleted: _verifyOtp),
                    if (_isOtpVerified)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Email verified', style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: AppStrings.password,
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    validator: Validators.validatePassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _isPasswordVisible = !_isPasswordVisible);
                      },
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                      },
                      icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Complete Registration',
                    onPressed: _canContinue() ? _register : null,
                    isLoading: _isLoading,
                    backgroundColor: _canContinue() ? AppColors.primaryColor : AppColors.hintColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}