import 'package:flutter/cupertino.dart';

class ExploradorOption {
  final String title;
  final IconData icon;
  final String description;
  final String routeName;
  final Color? iconColor;

  const ExploradorOption({
    required this.title,
    required this.icon,
    required this.description,
    required this.routeName,
    this.iconColor,
  });
}