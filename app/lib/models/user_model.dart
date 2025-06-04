
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime dateOfBirth;
  final String gender;
  final String universityId;
  final String universityName;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.universityId,
    required this.universityName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      universityId: json['universityId'],
      universityName: json['universityName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'universityId': universityId,
      'universityName': universityName,
    };
  }
}