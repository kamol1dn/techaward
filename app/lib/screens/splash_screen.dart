// old version
// import 'package:flutter/material.dart';
// import 'login_screen.dart';
// import 'quick_numbers_screen.dart';
//
// class SplashScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.local_hospital, size: 100, color: Colors.red),
//             SizedBox(height: 20),
//             Text('Emergency Services', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//             SizedBox(height: 50),
//             ElevatedButton(
//               onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen())),
//               child: Text('Login / Register'),
//             ),
//             SizedBox(height: 20),
//             OutlinedButton(
//               onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuickNumbersScreen())),
//               child: Text('Quick Numbers / Tutorials'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// new one with multiple language support
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../language/language_controller.dart';
import 'login_screen.dart';
import 'quick_numbers_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language') ?? 'en';
    setState(() => _selectedLang = code);
  }

  Future<void> _changeLanguage(String langCode) async {
    await LanguageController.setLanguage(langCode);
    setState(() => _selectedLang = langCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_hospital, size: 100, color: Colors.red),
                SizedBox(height: 20),
                Text(
                  LanguageController.get('emergency_services'),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen())),
                  child: Text(LanguageController.get('login_register')),
                ),
                SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuickNumbersScreen())),
                  child: Text(LanguageController.get('quick_numbers')),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: DropdownButton<String>(
              value: _selectedLang,
              onChanged: (val) {
                if (val != null) _changeLanguage(val);
              },
              items: [
                DropdownMenuItem(value: 'uz', child: Text(LanguageController.get('uz'))),
                DropdownMenuItem(value: 'ru', child: Text(LanguageController.get('ru'))),
                DropdownMenuItem(value: 'en', child: Text(LanguageController.get('en'))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
