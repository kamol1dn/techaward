import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/storage_service.dart';
import '../../language/language_controller.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? userData;
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLanguage();
  }

  Future<void> _loadUserData() async {
    final data = await StorageService.getUserData();
    setState(() => userData = data);
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          LanguageController.get('settings'),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red[600],
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: userData == null
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]!),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[600]!, Colors.red[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.red[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${userData!['name']} ${userData!['surname']}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userData!['phone'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Language Selection Card
            _buildSettingsCard(
              title: LanguageController.get('language'),
              icon: Icons.language,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLang,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.red[600]),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (val) {
                      if (val != null) _changeLanguage(val);
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'uz',
                        child: Row(
                          children: [

                            Text(LanguageController.get('uz')),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'ru',
                        child: Row(
                          children: [

                            Text(LanguageController.get('ru')),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Row(
                          children: [
                            Text(LanguageController.get('en')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Personal Information Card
            _buildSettingsCard(
              title: LanguageController.get('personal_info'),
              icon: Icons.person_outline,
              child: Column(
                children: [
                  _buildInfoRow(
                    LanguageController.get('age'),
                    userData!['age'].toString(),
                    Icons.cake_outlined,
                  ),
                  _buildInfoRow(
                    LanguageController.get('gender'),
                    userData!['gender'],
                    Icons.wc_outlined,
                  ),
                  _buildInfoRow(
                    LanguageController.get('passport'),
                    userData!['passport'],
                    Icons.credit_card_outlined,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Medical Information Card
            _buildSettingsCard(
              title: LanguageController.get('medical_info'),
              icon: Icons.medical_information_outlined,
              child: Column(
                children: [
                  _buildInfoRow(
                    LanguageController.get('blood_type'),
                    userData!['blood_type'],
                    Icons.bloodtype_outlined,
                  ),
                  _buildInfoRow(
                    LanguageController.get('allergies'),
                    userData!['allergies'],
                    Icons.warning_amber_outlined,
                  ),
                  _buildInfoRow(
                    LanguageController.get('illness'),
                    userData!['illness'] ?? LanguageController.get('none'),
                    Icons.local_hospital_outlined,
                  ),
                  if (userData!['additional_info']?.isNotEmpty == true)
                    _buildInfoRow(
                      LanguageController.get('additional'),
                      userData!['additional_info'],
                      Icons.info_outline,
                    ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Logout Button
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: Colors.red.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 24),
                    SizedBox(width: 12),
                    Text(
                      LanguageController.get('logout'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.red[600],
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          LanguageController.get('confirm_logout'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(LanguageController.get('logout_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              LanguageController.get('cancel'),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(LanguageController.get('logout')),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await StorageService.clearAll();
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}