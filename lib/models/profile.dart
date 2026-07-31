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
  final String ringtoneSource; // 'preloaded' or 'phone'
  final String ringtonePath;
  final String messageToneName;
  final String messageToneSource; // 'preloaded' or 'phone'
  final String messageTonePath;
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
    this.ringtoneVolume = 70,
    this.messageVolume = 70,
    this.ringtoneName = 'Nokia Ring Tone',
    this.ringtoneSource = 'preloaded',
    this.ringtonePath = 'assets/audio/nokia_ring_tone.mp3',
    this.messageToneName = 'Nokia SMS',
    this.messageToneSource = 'preloaded',
    this.messageTonePath = 'assets/audio/nokia_sms.mp3',
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
    String? ringtoneSource,
    String? ringtonePath,
    String? messageToneName,
    String? messageToneSource,
    String? messageTonePath,
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
      ringtoneSource: ringtoneSource ?? this.ringtoneSource,
      ringtonePath: ringtonePath ?? this.ringtonePath,
      messageToneName: messageToneName ?? this.messageToneName,
      messageToneSource: messageToneSource ?? this.messageToneSource,
      messageTonePath: messageTonePath ?? this.messageTonePath,
      isRingtoneVibrate: isRingtoneVibrate ?? this.isRingtoneVibrate,
      isMessageVibrate: isMessageVibrate ?? this.isMessageVibrate,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ringtoneVolume': ringtoneVolume,
      'messageVolume': messageVolume,
      'ringtoneName': ringtoneName,
      'ringtoneSource': ringtoneSource,
      'ringtonePath': ringtonePath,
      'messageToneName': messageToneName,
      'messageToneSource': messageToneSource,
      'messageTonePath': messageTonePath,
      'isRingtoneVibrate': isRingtoneVibrate,
      'isMessageVibrate': isMessageVibrate,
      'isActive': isActive,
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json, Profile defaultProfile) {
    return defaultProfile.copyWith(
      ringtoneVolume: json['ringtoneVolume'] as int? ?? defaultProfile.ringtoneVolume,
      messageVolume: json['messageVolume'] as int? ?? defaultProfile.messageVolume,
      ringtoneName: json['ringtoneName'] as String? ?? defaultProfile.ringtoneName,
      ringtoneSource: json['ringtoneSource'] as String? ?? defaultProfile.ringtoneSource,
      ringtonePath: json['ringtonePath'] as String? ?? defaultProfile.ringtonePath,
      messageToneName: json['messageToneName'] as String? ?? defaultProfile.messageToneName,
      messageToneSource: json['messageToneSource'] as String? ?? defaultProfile.messageToneSource,
      messageTonePath: json['messageTonePath'] as String? ?? defaultProfile.messageTonePath,
      isRingtoneVibrate: json['isRingtoneVibrate'] as bool? ?? defaultProfile.isRingtoneVibrate,
      isMessageVibrate: json['isMessageVibrate'] as bool? ?? defaultProfile.isMessageVibrate,
      isActive: json['isActive'] as bool? ?? defaultProfile.isActive,
    );
  }
}
