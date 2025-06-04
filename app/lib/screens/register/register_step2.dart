
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/university_dropdown.dart';
import '../../utils/constants.dart';
import '../../models/university_model.dart';
import 'register_step3.dart';

class RegisterStep2 extends StatefulWidget {
  final String firstName;
  final String lastName;

  const RegisterStep2({
    Key? key,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  State<RegisterStep2> createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {
  DateTime? _selectedDate;
  String _selectedGender = 'Male';
  University? _selectedUniversity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    setState(() => _isLoading = true);
    await Provider.of<AuthProvider>(context, listen: false).loadUniversities();
    setState(() => _isLoading = false);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime.now().subtract(const Duration(days: 36500)), // 100 years ago
      lastDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  bool _canContinue() {
    return _selectedDate != null && _selectedUniversity != null;
  }

  void _continue() {
    if (!_canContinue()) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterStep3(
          firstName: widget.firstName,
          lastName: widget.lastName,
          dateOfBirth: _selectedDate!,
          gender: _selectedGender,
          university: _selectedUniversity!,
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
          'Register (2/3)',
          style: TextStyle(color: AppColors.textColor),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Date of Birth
              const Text(
                AppStrings.dateOfBirth,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.hintColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                        : 'Select your date of birth',
                    style: TextStyle(
                      color: _selectedDate != null ? AppColors.textColor : AppColors.hintColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Gender
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(AppStrings.male),
                      value: 'Male',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() => _selectedGender = value!);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(AppStrings.female),
                      value: 'Female',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() => _selectedGender = value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // University
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return UniversityDropdown(
                    universities: authProvider.universities,
                    selectedUniversity: _selectedUniversity,
                    onChanged: (university) {
                      setState(() => _selectedUniversity = university);
                    },
                    isLoading: _isLoading,
                  );
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: AppStrings.continue_,
                onPressed: _canContinue() ? _continue : null,
                backgroundColor: _canContinue() ? AppColors.primaryColor : AppColors.hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}