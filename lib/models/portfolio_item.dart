import 'package:flutter/foundation.dart';

@immutable
class PortfolioItem {
  final String id;
  final String imageUrl;
  final String title;

  const PortfolioItem({
    required this.id,
    required this.imageUrl,
    required this.title,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imageUrl': imageUrl,
        'title': title,
      };
}
