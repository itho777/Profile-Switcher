import 'package:flutter/material.dart';

class ScheduleItem {
  final String id;
  final String timeString; // e.g. "08:00 AM"
  final String profileTitle;
  final String description;
  final IconData icon;

  ScheduleItem({
    required this.id,
    required this.timeString,
    required this.profileTitle,
    required this.description,
    required this.icon,
  });
}
