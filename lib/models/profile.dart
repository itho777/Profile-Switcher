import 'package:flutter/material.dart';

class Profile {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final IconData activeIcon;
  final int ringtoneVolume; // 0-100
  final int messageVolume; // 0-100
  final String ringtoneName;
  final String messageToneName;
  final bool isVibrate;
  bool isActive;

  Profile({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.activeIcon,
    this.ringtoneVolume = 75,
    this.messageVolume = 60,
    this.ringtoneName = 'Nokia Tune',
    this.messageToneName = 'Message 2 (Default)',
    this.isVibrate = true,
    this.isActive = false,
  });

  Profile copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    IconData? activeIcon,
    int? ringtoneVolume,
    int? messageVolume,
    String? ringtoneName,
    String? messageToneName,
    bool? isVibrate,
    bool? isActive,
  }) {
    return Profile(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      ringtoneVolume: ringtoneVolume ?? this.ringtoneVolume,
      messageVolume: messageVolume ?? this.messageVolume,
      ringtoneName: ringtoneName ?? this.ringtoneName,
      messageToneName: messageToneName ?? this.messageToneName,
      isVibrate: isVibrate ?? this.isVibrate,
      isActive: isActive ?? this.isActive,
    );
  }
}
