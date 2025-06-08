
class PersonalData {
  final String phone;
  final String name;
  final String surname;
  final int age;
  final String gender;
  final String passport;
  final String password;

  PersonalData({
    required this.phone,
    required this.name,
    required this.surname,
    required this.age,
    required this.gender,
    required this.passport,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'name': name,
    'surname': surname,
    'age': age,
    'gender': gender,
    'passport': passport,
    'password': password,
  };
}

class MedicalData {
  final String bloodType;
  final String allergies;
  final String illness;
  final String additionalInfo;

  MedicalData({
    required this.bloodType,
    required this.allergies,
    required this.illness,
    required this.additionalInfo,
  });

  Map<String, dynamic> toJson() => {
    'blood_type': bloodType,
    'allergies': allergies,
    'illness': illness,
    'additional_info': additionalInfo,
  };
}
