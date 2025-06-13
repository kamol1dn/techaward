class FamilyMember {
  final String id;
  final String name;
  final String phone;
  final String relationship;
  final bool isOnline;
  final DateTime? lastSeen;
  final LocationData? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isInvitePending;

  FamilyMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    this.isOnline = false,
    this.lastSeen,
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.isInvitePending = false,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      relationship: json['relationship'],
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : null,
      location: json['location'] != null
          ? LocationData.fromJson(json['location'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isInvitePending: json['is_invite_pending'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'location': location?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_invite_pending': isInvitePending,
    };
  }

  FamilyMember copyWith({
    String? id,
    String? name,
    String? phone,
    String? relationship,
    bool? isOnline,
    DateTime? lastSeen,
    LocationData? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isInvitePending,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isInvitePending: isInvitePending ?? this.isInvitePending,
    );
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final double? accuracy;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.accuracy,
    required this.timestamp,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      accuracy: json['accuracy']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}