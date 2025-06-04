
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import 'register/register_step1.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.school,
                size: 100,
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 32),
              const Text(
                AppStrings.welcome,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to our university platform',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.hintColor,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              CustomButton(
                text: 'Get Started',
                onPressed: () async {
                  await StorageService.setNotFirstTime();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const RegisterStep1()),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(AppStrings.haveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}