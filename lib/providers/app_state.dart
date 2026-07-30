import 'dart:async';
import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/schedule_item.dart';

class AppState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  int _fontSizeIndex = 2; // 1: Small, 2: Standard, 3: Large, 4: Extra Large
  int get fontSizeIndex => _fontSizeIndex;
  double get fontScale => 0.85 + (_fontSizeIndex * 0.05);

  bool _pushNotifications = true;
  bool get pushNotifications => _pushNotifications;

  bool _ignoreBatteryOptimization = false;
  bool get ignoreBatteryOptimization => _ignoreBatteryOptimization;

  // Timed profile state
  Profile? _timedProfile;
  DateTime? _timedProfileEndTime;
  Timer? _countdownTimer;
  int _timedRemainingSeconds = 0;

  Profile? get timedProfile => _timedProfile;
  int get timedRemainingSeconds => _timedRemainingSeconds;

  final List<Profile> _profiles = [
    Profile(
      id: 'outdoor',
      title: 'Outdoor',
      description: 'Maximum volume levels designed for noisy environments.',
      icon: Icons.volume_up_outlined,
      activeIcon: Icons.volume_up,
      ringtoneVolume: 100,
      messageVolume: 100,
    ),
    Profile(
      id: 'normal',
      title: 'Normal',
      description: 'Standard ringtone volume and tones for everyday use.',
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      isActive: true,
      ringtoneVolume: 75,
      messageVolume: 60,
    ),
    Profile(
      id: 'meeting',
      title: 'Meeting',
      description: 'Uses subtle alert styles like a single beep or vibration instead of a loud ring.',
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups,
      ringtoneVolume: 20,
      messageVolume: 20,
    ),
    Profile(
      id: 'silent',
      title: 'Silent',
      description: 'Mutes all rings and alert sounds completely.',
      icon: Icons.notifications_off_outlined,
      activeIcon: Icons.notifications_off,
      ringtoneVolume: 0,
      messageVolume: 0,
    ),
    Profile(
      id: 'pager',
      title: 'Pager',
      description: 'Configures specific alert tones mimicking pager notifications.',
      icon: Icons.cell_tower_outlined,
      activeIcon: Icons.cell_tower,
      ringtoneVolume: 80,
      messageVolume: 80,
    ),
    Profile(
      id: 'discreet',
      title: 'Discreet',
      description: 'Alternative muted or low-vibration.',
      icon: Icons.vibration_outlined,
      activeIcon: Icons.vibration,
      ringtoneVolume: 30,
      messageVolume: 30,
    ),
  ];

  List<Profile> get profiles => List.unmodifiable(_profiles);

  Profile get activeProfile {
    return _profiles.firstWhere(
      (p) => p.isActive,
      orElse: () => _profiles[1],
    );
  }

  final List<ScheduleItem> _schedules = [
    ScheduleItem(
      id: 's1',
      timeString: '08:00 AM',
      profileTitle: 'Outdoor',
      description: 'High volume, GPS enabled, brightness max.',
      icon: Icons.wb_sunny,
    ),
    ScheduleItem(
      id: 's2',
      timeString: '12:00 PM',
      profileTitle: 'Meeting',
      description: 'Vibrate only, auto-reply SMS active.',
      icon: Icons.groups,
    ),
    ScheduleItem(
      id: 's3',
      timeString: '10:00 PM',
      profileTitle: 'Silent',
      description: 'Do not disturb, white-list favorites only.',
      icon: Icons.notifications_off,
    ),
  ];

  List<ScheduleItem> get schedules => List.unmodifiable(_schedules);

  // Methods
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setFontSizeIndex(int index) {
    _fontSizeIndex = index;
    notifyListeners();
  }

  void togglePushNotifications(bool val) {
    _pushNotifications = val;
    notifyListeners();
  }

  void toggleIgnoreBatteryOptimization(bool val) {
    _ignoreBatteryOptimization = val;
    notifyListeners();
  }

  void activateProfile(String profileId) {
    _cancelTimedActivation();
    for (var p in _profiles) {
      p.isActive = (p.id == profileId);
    }
    notifyListeners();
  }

  void startTimedActivation(String profileId, int hours) {
    activateProfile(profileId);
    _timedProfile = activeProfile;
    _timedProfileEndTime = DateTime.now().add(Duration(hours: hours));
    _timedRemainingSeconds = hours * 3600;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timedProfileEndTime == null) {
        timer.cancel();
        return;
      }
      final diff = _timedProfileEndTime!.difference(DateTime.now()).inSeconds;
      if (diff <= 0) {
        _cancelTimedActivation();
        activateProfile('normal'); // revert to default
      } else {
        _timedRemainingSeconds = diff;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void _cancelTimedActivation() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _timedProfile = null;
    _timedProfileEndTime = null;
    _timedRemainingSeconds = 0;
  }

  void updateActiveRingtone(String name) {
    final active = activeProfile;
    final index = _profiles.indexWhere((p) => p.id == active.id);
    if (index != -1) {
      _profiles[index] = _profiles[index].copyWith(ringtoneName: name);
      notifyListeners();
    }
  }

  void updateActiveRingtoneVolume(int vol) {
    final active = activeProfile;
    final index = _profiles.indexWhere((p) => p.id == active.id);
    if (index != -1) {
      _profiles[index] = _profiles[index].copyWith(ringtoneVolume: vol);
      notifyListeners();
    }
  }

  void updateActiveMessageTone(String name) {
    final active = activeProfile;
    final index = _profiles.indexWhere((p) => p.id == active.id);
    if (index != -1) {
      _profiles[index] = _profiles[index].copyWith(messageToneName: name);
      notifyListeners();
    }
  }

  void updateActiveMessageVolume(int vol) {
    final active = activeProfile;
    final index = _profiles.indexWhere((p) => p.id == active.id);
    if (index != -1) {
      _profiles[index] = _profiles[index].copyWith(messageVolume: vol);
      notifyListeners();
    }
  }

  void addScheduleItem(ScheduleItem item) {
    _schedules.add(item);
    notifyListeners();
  }

  void resetToDefaults() {
    _themeMode = ThemeMode.system;
    _fontSizeIndex = 2;
    _pushNotifications = true;
    _ignoreBatteryOptimization = false;
    _cancelTimedActivation();
    for (var p in _profiles) {
      p.isActive = (p.id == 'normal');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
