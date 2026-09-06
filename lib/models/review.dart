import 'package:flutter/foundation.dart';

@immutable
class Review {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;

  const Review({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final dateString = json['date'] as String? ?? json['createdAt'] as String? ?? '';
    return Review(
      id: json['id'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String? ?? '',
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      date: dateString.isEmpty ? DateTime.now() : DateTime.parse(dateString),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'userAvatar': userAvatar,
        'rating': rating,
        'comment': comment,
        'date': date.toIso8601String(),
      };
}
