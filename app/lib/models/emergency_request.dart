
import '../screens/home_screen.dart';


class EmergencyRequest {
  final EmergencyType type;
  final bool isForMe;
  final String details;
  final String location;
  final String? imagePath;
  final Map<String, dynamic>? userData;

  EmergencyRequest({
    required this.type,
    required this.isForMe,
    required this.details,
    required this.location,
    this.imagePath,
    this.userData,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'is_for_me': isForMe,
    'details': details,
    'location': location,
    'image_path': imagePath,
    'user_data': userData,
    'timestamp': DateTime.now().toIso8601String(),
  };
}
