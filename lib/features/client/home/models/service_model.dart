import 'package:flutter/material.dart';

enum ServiceType { category, service }

class SearchSuggestion {
  final String id;
  final String title;
  final String subtitle;
  final ServiceType type;
  final String? categoryId;
  final String? imageUrl;

  SearchSuggestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.categoryId,
    this.imageUrl,
  });
}

class ServiceCategory {
  final String id;
  final String name;
  final IconData icon;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}
