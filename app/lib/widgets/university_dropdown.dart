
import 'package:flutter/material.dart';
import '../models/university_model.dart';
import '../utils/constants.dart';

class UniversityDropdown extends StatelessWidget {
  final List<University> universities;
  final University? selectedUniversity;
  final Function(University?) onChanged;
  final bool isLoading;

  const UniversityDropdown({
    Key? key,
    required this.universities,
    required this.selectedUniversity,
    required this.onChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.university,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.hintColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLoading
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          )
              : DropdownButtonHideUnderline(
            child: DropdownButton<University>(
              isExpanded: true,
              value: selectedUniversity,
              hint: const Text(
                'Select your university',
                style: TextStyle(color: AppColors.hintColor),
              ),
              items: universities.map((university) {
                return DropdownMenuItem<University>(
                  value: university,
                  child: Text(university.name),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}