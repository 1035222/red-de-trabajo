import 'package:flutter/foundation.dart';

@immutable
class Category {
  final String name;
  final String icon;
  final String color;

  const Category({
    required this.name,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon,
        'color': color,
      };
}
