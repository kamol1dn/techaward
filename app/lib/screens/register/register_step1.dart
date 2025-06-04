
import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../login_screen.dart';
import 'register_step2.dart';

class RegisterStep1 extends StatefulWidget {
  const RegisterStep1({Key? key}) : super(key: key);

  @override
  State<RegisterStep1> createState() => _RegisterStep1State();
}

class _RegisterStep1State extends State<RegisterStep1> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterStep2(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: const Text(
          'Register (1/3)',
          style: TextStyle(color: AppColors.textColor),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                CustomTextField(
                  label: AppStrings.firstName,
                  hint: 'Enter your first name',
                  controller: _firstNameController,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: AppStrings.lastName,
                  hint: 'Enter your last name',
                  controller: _lastNameController,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: AppStrings.continue_,
                  onPressed: _continue,
                ),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(AppStrings.haveAccount),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}