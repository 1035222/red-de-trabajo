import 'package:flutter/foundation.dart';

@immutable
class Service {
  final String id;
  final String title;
  final String providerName;
  final String providerId;
  final String imageUrl;
  final double rating;
  final String price;
  final String description;
  final String category;
  final int reviewsCount;
  final bool featured;

  const Service({
    required this.id,
    required this.title,
    required this.providerName,
    required this.providerId,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.description,
    required this.category,
    this.reviewsCount = 0,
    this.featured = false,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] is Map<String, dynamic> ? json['provider'] as Map<String, dynamic> : {};
    return Service(
      id: json['id'] as String,
      title: json['title'] as String,
      providerName: (json['providerName'] as String?) ?? (provider['name'] as String?) ?? '',
      providerId: (json['providerId'] as String?) ?? (provider['id'] as String?) ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      price: json['price'] as String,
      description: json['description'] as String,
      category: json['categoryName'] as String? ?? json['category'] as String? ?? '',
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      featured: json['featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'providerName': providerName,
        'providerId': providerId,
        'imageUrl': imageUrl,
        'rating': rating,
        'price': price,
        'description': description,
        'category': category,
        'reviewsCount': reviewsCount,
        'featured': featured,
      };
}
