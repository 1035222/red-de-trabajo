import 'package:flutter/foundation.dart';

@immutable
class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String bio;
  final String location;
  final double rating;
  final int servicesCount;
  final bool verified;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.bio = '',
    this.location = '',
    this.rating = 0.0,
    this.servicesCount = 0,
    this.verified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      location: json['location'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      servicesCount: json['servicesCount'] as int? ?? 0,
      verified: json['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'bio': bio,
        'location': location,
        'rating': rating,
        'servicesCount': servicesCount,
        'verified': verified,
      };

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    String? location,
    double? rating,
    int? servicesCount,
    bool? verified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      servicesCount: servicesCount ?? this.servicesCount,
      verified: verified ?? this.verified,
    );
  }
}
