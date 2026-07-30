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
  final bool isRingtoneVibrate;
  final bool isMessageVibrate;
  bool isActive;

  bool get isVibrate => isRingtoneVibrate || isMessageVibrate;

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
    this.isRingtoneVibrate = true,
    this.isMessageVibrate = true,
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
    bool? isRingtoneVibrate,
    bool? isMessageVibrate,
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
      isRingtoneVibrate: isRingtoneVibrate ?? this.isRingtoneVibrate,
      isMessageVibrate: isMessageVibrate ?? this.isMessageVibrate,
      isActive: isActive ?? this.isActive,
    );
  }
}
