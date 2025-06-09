
import 'package:flutter/material.dart';
import 'package:talaba_plus/language/language_controller.dart';
import 'register_screen.dart';
import 'main_screen.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //title: Text('Login')
        title: Text(LanguageController.get('login')),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _loginController,
                decoration: InputDecoration(
                  //labelText: 'Passport Series or Phone Number',
                  //hintText: 'AD1234567 or +998901234567',
                  labelText: LanguageController.get('passport_or_phone'),
                  hintText: LanguageController.get('hint_text_passport_phone'),

                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                    labelText: LanguageController.get('password'),
                ),
                obscureText: true,
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              SizedBox(height: 32),

              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _login,
                child: Text(LanguageController.get('login')),
              ),
              SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => RegisterScreen())
                ),

                // child: Text('Don\'t have an account? Register'),
                child: Text(LanguageController.get('not_account_register'),)
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(_loginController.text, _passwordController.text);
      print('Login response: $result');
      if (result.containsKey('access')) {
        await StorageService.saveUserToken(result['access']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
      } else {
        _showError(result['message']);
      }
    } catch (e) {
      _showError(LanguageController.get('login_fail'));
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}