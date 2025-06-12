import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';
import '../../language/language_controller.dart';

class EditSettingsScreen extends StatefulWidget {
  const EditSettingsScreen({super.key});

  @override
  _EditSettingsScreenState createState() => _EditSettingsScreenState();
}

class _EditSettingsScreenState extends State<EditSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;

  // Controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _passportController;
  late TextEditingController _allergiesController;
  late TextEditingController _illnessController;
  late TextEditingController _additionalInfoController;

  String _selectedGender = 'Male';
  String _selectedBloodType = 'A+';

  final List<String> _genders = ['Male', 'Female'];
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  Map<String, dynamic>? _originalData;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _phoneController = TextEditingController();
    _ageController = TextEditingController();
    _passportController = TextEditingController();
    _allergiesController = TextEditingController();
    _illnessController = TextEditingController();
    _additionalInfoController = TextEditingController();

    // Add listeners to detect changes
    _nameController.addListener(_onFieldChanged);
    _surnameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
    _passportController.addListener(_onFieldChanged);
    _allergiesController.addListener(_onFieldChanged);
    _illnessController.addListener(_onFieldChanged);
    _additionalInfoController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _loadUserData() async {
    final data = await StorageService.getUserData();
    if (data != null) {
      setState(() {
        _originalData = Map.from(data);
        _nameController.text = data['name'] ?? '';
        _surnameController.text = data['surname'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _ageController.text = data['age']?.toString() ?? '';
        _passportController.text = data['passport'] ?? '';
        _allergiesController.text = data['allergies'] ?? '';
        _illnessController.text = data['illness'] ?? '';
        _additionalInfoController.text = data['additional_info'] ?? '';
        _selectedGender = data['gender'] ?? 'Male';
        _selectedBloodType = data['blood_type'] ?? 'A+';
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedData = {
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'gender': _selectedGender,
        'passport': _passportController.text.trim(),
        'blood_type': _selectedBloodType,
        'allergies': _allergiesController.text.trim(),
        'illness': _illnessController.text.trim(),
        'additional_info': _additionalInfoController.text.trim(),
      };

      // Update data on server
      final response = await ApiService.updateUserData(updatedData);

      if (response['success']) {
        // Update local storage
        await StorageService.saveUpdatedUserData(updatedData);

        setState(() => _hasChanges = false);

        // Show success message
        _showSnackBar(
          LanguageController.get('data_updated_successfully'),
          Colors.green,
        );

        // Go back to settings screen
        Navigator.pop(context, true); // true indicates data was updated
      } else {
        _showSnackBar(
          response['message'] ?? LanguageController.get('update_failed'),
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar(
        LanguageController.get('network_error'),
        Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          LanguageController.get('unsaved_changes'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(LanguageController.get('discard_changes_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              LanguageController.get('keep_editing'),
              style: TextStyle(color: Colors.red[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(LanguageController.get('discard')),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            LanguageController.get('edit_profile'),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red[600],
          iconTheme: IconThemeData(color: Colors.white),
          scrolledUnderElevation: 0,
          elevation: 0,
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveChanges,
                child: Text(
                  LanguageController.get('save'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
        body: _originalData == null
            ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]!),
          ),
        )
            : Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Personal Information Section
                _buildSectionCard(
                  title: LanguageController.get('personal_info'),
                  icon: Icons.person_outline,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: LanguageController.get('name'),
                      icon: Icons.person,
                      validator: (value) => value?.isEmpty == true
                          ? LanguageController.get('field_required')
                          : null,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _surnameController,
                      label: LanguageController.get('surname'),
                      icon: Icons.person,
                      validator: (value) => value?.isEmpty == true
                          ? LanguageController.get('field_required')
                          : null,
                    ),
                    SizedBox(height: 16),
                    _buildTextFieldPhone(
                      controller: _phoneController,
                      label: LanguageController.get('phone'),
                      icon: Icons.phone,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _ageController,
                            label: LanguageController.get('age'),
                            icon: Icons.cake,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) {
                              if (value?.isEmpty == true) {
                                return LanguageController.get('field_required');
                              }
                              final age = int.tryParse(value!);
                              if (age == null || age < 1 || age > 120) {
                                return LanguageController.get('invalid_age');
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdown(
                            value: _selectedGender,
                            label: LanguageController.get('gender'),
                            icon: Icons.wc,
                            items: _genders,
                            onChanged: (value) {
                              setState(() => _selectedGender = value!);
                              _onFieldChanged();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _passportController,
                      label: LanguageController.get('passport'),
                      icon: Icons.credit_card,
                      validator: (value) => value?.isEmpty == true
                          ? LanguageController.get('field_required')
                          : null,
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Medical Information Section
                _buildSectionCard(
                  title: LanguageController.get('medical_info'),
                  icon: Icons.medical_information_outlined,
                  children: [
                    _buildDropdown(
                      value: _selectedBloodType,
                      label: LanguageController.get('blood_type'),
                      icon: Icons.bloodtype,
                      items: _bloodTypes,
                      onChanged: (value) {
                        setState(() => _selectedBloodType = value!);
                        _onFieldChanged();
                      },
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _allergiesController,
                      label: LanguageController.get('allergies'),
                      icon: Icons.warning_amber,
                      maxLines: 2,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _illnessController,
                      label: LanguageController.get('illness'),
                      icon: Icons.local_hospital,
                      maxLines: 2,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _additionalInfoController,
                      label: LanguageController.get('additional'),
                      icon: Icons.info,
                      maxLines: 3,
                    ),
                  ],
                ),

                SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: Colors.red.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, size: 24),
                        SizedBox(width: 12),
                        Text(
                          LanguageController.get('save_changes'),
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
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
            SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[600]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildTextFieldPhone({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style: TextStyle(fontSize: 16),
      validator: (value) {
        if (value?.isEmpty == true) {
          return LanguageController.get('field_required');
        }
        if (!RegExp(r'^\+998\d{9}$').hasMatch(value!)) {
          return LanguageController.get('invalid_phone');
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[600]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[600]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _passportController.dispose();
    _allergiesController.dispose();
    _illnessController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }
}