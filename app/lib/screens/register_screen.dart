
import 'package:flutter/material.dart';
import 'register_medical_screen.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _passportController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedGender = 'Male';
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register (1/2)')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Phone verification
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  enabled: !_otpVerified,
                  validator: (value) => value?.isEmpty == true ? 'Required' : null,
                ),
                if (!_otpVerified) ...[
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _otpSent ? null : _sendOtp,
                    child: Text(_otpSent ? 'OTP Sent' : 'Send OTP'),
                  ),
                ],
                if (_otpSent && !_otpVerified) ...[
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _otpController,
                    decoration: InputDecoration(labelText: 'OTP Code'),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _verifyOtp,
                    child: Text('Verify OTP'),
                  ),
                ],

                if (_otpVerified) ...[
                  SizedBox(height: 16),
                  Text('✓ Phone Verified', style: TextStyle(color: Colors.green)),
                  SizedBox(height: 16),

                  // Personal data
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _surnameController,
                    decoration: InputDecoration(labelText: 'Surname'),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedGender = value!),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passportController,
                    decoration: InputDecoration(labelText: 'Passport Series'),
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Required';
                      if (value != _passwordController.text) return 'Passwords don\'t match';
                      return null;
                    },
                  ),
                  SizedBox(height: 32),

                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _proceedToMedical,
                    child: Text('Next: Medical Data'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final result = await ApiService.sendOtp(_phoneController.text);
    setState(() => _isLoading = false);

    if (result['success']) {
      setState(() => _otpSent = true);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final result = await ApiService.verifyOtp(_phoneController.text, _otpController.text);
    setState(() => _isLoading = false);

    if (result['success']) {
      setState(() => _otpVerified = true);
    }
  }

  void _proceedToMedical() {
    if (!_formKey.currentState!.validate()) return;

    final personalData = PersonalData(
      phone: _phoneController.text,
      name: _nameController.text,
      surname: _surnameController.text,
      age: int.parse(_ageController.text),
      gender: _selectedGender,
      passport: _passportController.text,
      password: _passwordController.text,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterMedicalScreen(personalData: personalData)),
    );
  }
}
