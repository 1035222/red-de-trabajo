import 'package:flutter/foundation.dart';

@immutable
class AppUser {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String? bio;
  final String? location;
  final double? rating;
  final int? servicesCount;
  final bool? verified;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.bio,
    this.location,
    this.rating,
    this.servicesCount,
    this.verified,
  });

  factory AppUser.fromGoogle({
    required String id,
    required String name,
    required String email,
    String? photoUrl,
  }) {
    return AppUser(
      id: id,
      name: name,
      email: email,
      avatarUrl: photoUrl ?? '',
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String? ?? '',
      bio: json['bio'] as String? ?? json['bio'],
      location: json['location'] as String? ?? json['location'],
      rating: (json['rating'] as num?)?.toDouble(),
      servicesCount: json['servicesCount'] as int? ?? json['services_count'] as int?,
      verified: json['verified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        if (bio != null) 'bio': bio,
        if (location != null) 'location': location,
        if (rating != null) 'rating': rating,
        if (servicesCount != null) 'servicesCount': servicesCount,
        if (verified != null) 'verified': verified,
      };

  AppUser copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    String? location,
    double? rating,
    int? servicesCount,
    bool? verified,
  }) {
    return AppUser(
      id: id,
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
