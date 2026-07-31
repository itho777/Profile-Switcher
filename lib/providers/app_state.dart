import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/profile.dart';
import '../models/schedule_item.dart';

class PreloadedTone {
  final String name;
  final String assetPath;
  const PreloadedTone({required this.name, required this.assetPath});
}

final List<PreloadedTone> preloadedRingtones = const [
  PreloadedTone(name: 'Nokia Ring Tone', assetPath: 'assets/audio/nokia_ring_tone.mp3'),
  PreloadedTone(name: 'Original Nokia', assetPath: 'assets/audio/original_nokia.mp3'),
  PreloadedTone(name: 'Old Ring', assetPath: 'assets/audio/old_ring.mp3'),
  PreloadedTone(name: 'Beep Once', assetPath: 'assets/audio/beep_once_ring_tone.mp3'),
  PreloadedTone(name: 'Nokia Standard', assetPath: 'assets/audio/nokia_standard.mp3'),
];

final List<PreloadedTone> preloadedMessageTones = const [
  PreloadedTone(name: 'Nokia SMS', assetPath: 'assets/audio/nokia_sms.mp3'),
  PreloadedTone(name: 'Beep Once', assetPath: 'assets/audio/beep_once_ring_tone.mp3'),
  PreloadedTone(name: 'Nokia Standard', assetPath: 'assets/audio/nokia_standard.mp3'),
];

class AppState extends ChangeNotifier {
  static const _ringtoneChannel = MethodChannel('com.profileselector/ringtone_picker');

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  int _fontSizeIndex = 2; // 1: Small, 2: Standard, 3: Large, 4: Extra Large
  int get fontSizeIndex => _fontSizeIndex;
  double get fontScale => 0.85 + (_fontSizeIndex * 0.05);

  bool _pushNotifications = true;
  bool get pushNotifications => _pushNotifications;

  bool _ignoreBatteryOptimization = false;
  bool get ignoreBatteryOptimization => _ignoreBatteryOptimization;

  // Hardware integration state
  bool _hardwareSyncEnabled = true;
  bool get hardwareSyncEnabled => _hardwareSyncEnabled;

  // Timed profile state
  Profile? _timedProfile;
  DateTime? _timedProfileEndTime;
  Timer? _countdownTimer;
  int _timedRemainingSeconds = 0;

  Profile? get timedProfile => _timedProfile;
  int get timedRemainingSeconds => _timedRemainingSeconds;

  // Audio Testing State
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingTestSound = false;
  String? _currentlyTestingTonePath;

  bool get isPlayingTestSound => _isPlayingTestSound;
  String? get currentlyTestingTonePath => _currentlyTestingTonePath;

  final List<Profile> _profiles = [
    Profile(
      id: 'outdoor',
      title: 'Outdoor',
      description: 'Maximum volume levels designed for noisy environments.',
      icon: Icons.volume_up_outlined,
      activeIcon: Icons.volume_up,
      ringtoneVolume: 100,
      messageVolume: 100,
      ringtoneName: 'Nokia Ring Tone',
      ringtoneSource: 'preloaded',
      ringtonePath: 'assets/audio/nokia_ring_tone.mp3',
      messageToneName: 'Nokia SMS',
      messageToneSource: 'preloaded',
      messageTonePath: 'assets/audio/nokia_sms.mp3',
      isRingtoneVibrate: true,
      isMessageVibrate: true,
    ),
    Profile(
      id: 'normal',
      title: 'Normal',
      description: 'Standard ringtone volume and tones for everyday use.',
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      isActive: true,
      ringtoneVolume: 70,
      messageVolume: 70,
      ringtoneName: 'Nokia Ring Tone',
      ringtoneSource: 'preloaded',
      ringtonePath: 'assets/audio/nokia_ring_tone.mp3',
      messageToneName: 'Nokia SMS',
      messageToneSource: 'preloaded',
      messageTonePath: 'assets/audio/nokia_sms.mp3',
      isRingtoneVibrate: true,
      isMessageVibrate: true,
    ),
    Profile(
      id: 'meeting',
      title: 'Meeting',
      description: 'Uses subtle alert styles like a single beep or vibration instead of a loud ring.',
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups,
      ringtoneVolume: 30,
      messageVolume: 30,
      ringtoneName: 'Beep Once',
      ringtoneSource: 'preloaded',
      ringtonePath: 'assets/audio/beep_once_ring_tone.mp3',
      messageToneName: 'Nokia SMS',
      messageToneSource: 'preloaded',
      messageTonePath: 'assets/audio/nokia_sms.mp3',
      isRingtoneVibrate: true,
      isMessageVibrate: true,
    ),
    Profile(
      id: 'silent',
      title: 'Silent',
      description: 'All sounds muted. Vibration alerts still active.',
      icon: Icons.notifications_off_outlined,
      activeIcon: Icons.notifications_off,
      ringtoneVolume: 0,
      messageVolume: 0,
      ringtoneName: 'Nokia Ring Tone',
      ringtoneSource: 'preloaded',
      ringtonePath: 'assets/audio/nokia_ring_tone.mp3',
      messageToneName: 'Nokia SMS',
      messageToneSource: 'preloaded',
      messageTonePath: 'assets/audio/nokia_sms.mp3',
      isRingtoneVibrate: true,
      isMessageVibrate: true,
    ),
    Profile(
      id: 'pager',
      title: 'Pager',
      description: 'Low-volume pager-style single beep alerts for calls and messages.',
      icon: Icons.cell_tower_outlined,
      activeIcon: Icons.cell_tower,
      ringtoneVolume: 30,
      messageVolume: 30,
      ringtoneName: 'Beep Once',
      ringtoneSource: 'preloaded',
      ringtonePath: 'assets/audio/beep_once_ring_tone.mp3',
      messageToneName: 'Beep Once',
      messageToneSource: 'preloaded',
      messageTonePath: 'assets/audio/beep_once_ring_tone.mp3',
      isRingtoneVibrate: true,
      isMessageVibrate: true,
    ),
    Profile(
      id: 'discreet',
      title: 'Discreet',
      description: 'Minimum volume with vibration. Single beep tone, quiet keypad.',
      icon: Icons.vibration_outlined,
      activeIcon: Icons.vibration,
      ringtoneVolume: 20,
      messageVolume: 20,
      ringtoneName: 'Beep Once',
      ringtoneSource: 'preloaded',
      ringtonePath: 'assets/audio/beep_once_ring_tone.mp3',
      messageToneName: 'Beep Once',
      messageToneSource: 'preloaded',
      messageTonePath: 'assets/audio/beep_once_ring_tone.mp3',
      isRingtoneVibrate: true,
      isMessageVibrate: true,
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

  AppState() {
    _initStorage();
  }

  Future<void> _initStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isFirstRun = prefs.getBool('is_first_run') ?? true;

      if (prefs.containsKey('profiles_json')) {
        final String? rawJson = prefs.getString('profiles_json');
        if (rawJson != null) {
          final List decoded = jsonDecode(rawJson);
          for (var jsonItem in decoded) {
            final String id = jsonItem['id'];
            final idx = _profiles.indexWhere((p) => p.id == id);
            if (idx != -1) {
              _profiles[idx] = Profile.fromJson(jsonItem, _profiles[idx]);
            }
          }
        }
      }

      if (isFirstRun) {
        // First ever run: detect system default ringtone/message tone and save to Normal profile
        await _detectAndSaveSystemDefaults();
        await prefs.setBool('is_first_run', false);
        // Start on Normal profile for first run
        for (var p in _profiles) {
          p.isActive = (p.id == 'normal');
        }
        await prefs.setString('saved_active_profile_id', 'normal');
      } else {
        // Restore the last active profile the user chose
        final String savedId = prefs.getString('saved_active_profile_id') ?? 'normal';
        final bool profileExists = _profiles.any((p) => p.id == savedId);
        final String restoreId = profileExists ? savedId : 'normal';
        for (var p in _profiles) {
          p.isActive = (p.id == restoreId);
        }
      }

      _saveProfilesToStorage();
      _applyHardwareSettings(activeProfile);
    } catch (e) {
      debugPrint("Error initializing AppState storage: $e");
    }
    notifyListeners();
  }

  Future<void> _detectAndSaveSystemDefaults() async {
    try {
      final ringtoneRes = await _ringtoneChannel.invokeMethod<Map>('getDefaultRingtone');
      final notifRes = await _ringtoneChannel.invokeMethod<Map>('getDefaultNotificationTone');

      String ringTitle = ringtoneRes?['title'] ?? 'Phone Default Ringtone';
      String ringUri = ringtoneRes?['uri'] ?? '';
      String notifTitle = notifRes?['title'] ?? 'Phone Default Message Tone';
      String notifUri = notifRes?['uri'] ?? '';

      // All profiles except meeting, pager, discreet use the phone's initial default tones
      for (var id in ['normal', 'outdoor', 'silent']) {
        final idx = _profiles.indexWhere((p) => p.id == id);
        if (idx != -1) {
          _profiles[idx] = _profiles[idx].copyWith(
            ringtoneName: ringTitle,
            ringtoneSource: 'phone',
            ringtonePath: ringUri,
            messageToneName: notifTitle,
            messageToneSource: 'phone',
            messageTonePath: notifUri,
          );
        }
      }
    } catch (e) {
      debugPrint("Error detecting system defaults: $e");
    }
  }

  Future<void> _saveProfilesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_profiles.map((p) => p.toJson()).toList());
      await prefs.setString('profiles_json', encoded);
    } catch (e) {
      debugPrint("Error saving profiles: $e");
    }
  }

  // Audio Testing Methods
  Future<void> playTestSound({required String source, required String path, required String name}) async {
    await stopTestSound();
    _isPlayingTestSound = true;
    _currentlyTestingTonePath = path;
    notifyListeners();

    try {
      if (source == 'preloaded') {
        // Strip assets/ prefix for audioplayers AssetSource
        final assetRelativePath = path.startsWith('assets/') ? path.substring(7) : path;
        await _audioPlayer.play(AssetSource(assetRelativePath));
      } else {
        await _ringtoneChannel.invokeMethod('playSystemTone', {'uri': path});
      }
    } catch (e) {
      debugPrint("Error playing test sound: $e");
    }
  }

  Future<void> stopTestSound() async {
    _isPlayingTestSound = false;
    _currentlyTestingTonePath = null;
    try {
      await _audioPlayer.stop();
      await _ringtoneChannel.invokeMethod('stopSystemTone');
    } catch (_) {}
    notifyListeners();
  }

  Future<void> openPhoneSoundSettings() async {
    try {
      await _ringtoneChannel.invokeMethod('openSoundSettings');
    } catch (e) {
      debugPrint("Error opening sound settings: $e");
    }
  }

  Future<void> pickPhoneRingtone(String profileId, String type) async {
    try {
      final result = await _ringtoneChannel.invokeMethod<Map>('pickRingtone', {'type': type});
      if (result != null && result['title'] != null) {
        final String title = result['title'].toString();
        final String uri = result['uri']?.toString() ?? '';
        if (type == 'notification') {
          updateProfileMessageTone(profileId, name: title, source: 'phone', path: uri);
        } else {
          updateProfileRingtone(profileId, name: title, source: 'phone', path: uri);
        }
      }
    } catch (e) {
      debugPrint("Error picking native ringtone: $e");
    }
  }

  // Profile Management Methods
  void updateProfileRingtone(String profileId, {required String name, required String source, required String path}) {
    final index = _profiles.indexWhere((p) => p.id == profileId);
    if (index != -1) {
      _profiles[index] = _profiles[index].copyWith(
        ringtoneName: name,
        ringtoneSource: source,
        ringtonePath: path,
      );
      _saveProfilesToStorage();
      notifyListeners();
    }
  }

  void updateProfileMessageTone(String profileId, {required String name, required String source, required String path}) {
    final index = _profiles.indexWhere((p) => p.id == profileId);
    if (index != -1) {
      _profiles[index] = _profiles[index].copyWith(
        messageToneName: name,
        messageToneSource: source,
        messageTonePath: path,
      );
      _saveProfilesToStorage();
      notifyListeners();
    }
  }

  void updateProfileRingtoneVolume(String profileId, int vol) {
    final index = _profiles.indexWhere((p) => p.id == profileId);
    if (index != -1) {
      _profiles[index] = _profiles[index].copyWith(ringtoneVolume: vol);
      _saveProfilesToStorage();
      if (_profiles[index].isActive) {
        _setHardwareVolume(AudioStream.ring, vol / 100.0);
      }
      notifyListeners();
    }
  }

  void updateProfileMessageVolume(String profileId, int vol) {
    final index = _profiles.indexWhere((p) => p.id == profileId);
    if (index != -1) {
      _profiles[index] = _profiles[index].copyWith(messageVolume: vol);
      _saveProfilesToStorage();
      if (_profiles[index].isActive) {
        _setHardwareVolume(AudioStream.notification, vol / 100.0);
      }
      notifyListeners();
    }
  }

  void updateProfileRingtoneVibrate(String profileId, bool val) {
    final index = _profiles.indexWhere((p) => p.id == profileId);
    if (index != -1) {
      _profiles[index] = _profiles[index].copyWith(isRingtoneVibrate: val);
      _saveProfilesToStorage();
      notifyListeners();
    }
  }

  void updateProfileMessageVibrate(String profileId, bool val) {
    final index = _profiles.indexWhere((p) => p.id == profileId);
    if (index != -1) {
      _profiles[index] = _profiles[index].copyWith(isMessageVibrate: val);
      _saveProfilesToStorage();
      notifyListeners();
    }
  }

  // Active Profile Convenience Methods
  void updateActiveRingtone(String name) {
    updateProfileRingtone(activeProfile.id, name: name, source: 'preloaded', path: 'assets/audio/nokia_ring_tone.mp3');
  }

  void updateActiveRingtoneVolume(int vol) {
    updateProfileRingtoneVolume(activeProfile.id, vol);
  }

  void updateActiveRingtoneVibrate(bool val) {
    updateProfileRingtoneVibrate(activeProfile.id, val);
  }

  void updateActiveMessageTone(String name) {
    updateProfileMessageTone(activeProfile.id, name: name, source: 'preloaded', path: 'assets/audio/nokia_sms.mp3');
  }

  void updateActiveMessageVolume(int vol) {
    updateProfileMessageVolume(activeProfile.id, vol);
  }

  void updateActiveMessageVibrate(bool val) {
    updateProfileMessageVibrate(activeProfile.id, val);
  }

  void activateProfile(String profileId) {
    _cancelTimedActivation();
    for (var p in _profiles) {
      p.isActive = (p.id == profileId);
    }
    _saveProfilesToStorage();
    // Persist the chosen profile so it is restored on next app launch
    _saveActiveProfileId(profileId);
    final active = activeProfile;
    _applyHardwareSettings(active);
    notifyListeners();
  }

  Future<void> _saveActiveProfileId(String profileId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_active_profile_id', profileId);
    } catch (e) {
      debugPrint("Error saving active profile id: $e");
    }
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

  void toggleHardwareSync(bool val) {
    _hardwareSyncEnabled = val;
    if (_hardwareSyncEnabled) {
      _applyHardwareSettings(activeProfile);
    }
    notifyListeners();
  }

  void addScheduleItem(ScheduleItem item) {
    _schedules.add(item);
    notifyListeners();
  }

  // Factory default settings for each profile (used by resetProfileToDefault)
  static final Map<String, Map<String, dynamic>> _factoryDefaults = {
    'normal': {
      'ringtoneVolume': 70, 'messageVolume': 70,
      'ringtoneName': 'Nokia Ring Tone', 'ringtoneSource': 'preloaded', 'ringtonePath': 'assets/audio/nokia_ring_tone.mp3',
      'messageToneName': 'Nokia SMS', 'messageToneSource': 'preloaded', 'messageTonePath': 'assets/audio/nokia_sms.mp3',
      'isRingtoneVibrate': true, 'isMessageVibrate': true,
    },
    'outdoor': {
      'ringtoneVolume': 100, 'messageVolume': 100,
      'ringtoneName': 'Nokia Ring Tone', 'ringtoneSource': 'preloaded', 'ringtonePath': 'assets/audio/nokia_ring_tone.mp3',
      'messageToneName': 'Nokia SMS', 'messageToneSource': 'preloaded', 'messageTonePath': 'assets/audio/nokia_sms.mp3',
      'isRingtoneVibrate': true, 'isMessageVibrate': true,
    },
    'meeting': {
      'ringtoneVolume': 30, 'messageVolume': 30,
      'ringtoneName': 'Beep Once', 'ringtoneSource': 'preloaded', 'ringtonePath': 'assets/audio/beep_once_ring_tone.mp3',
      'messageToneName': 'Nokia SMS', 'messageToneSource': 'preloaded', 'messageTonePath': 'assets/audio/nokia_sms.mp3',
      'isRingtoneVibrate': true, 'isMessageVibrate': true,
    },
    'silent': {
      'ringtoneVolume': 0, 'messageVolume': 0,
      'ringtoneName': 'Nokia Ring Tone', 'ringtoneSource': 'preloaded', 'ringtonePath': 'assets/audio/nokia_ring_tone.mp3',
      'messageToneName': 'Nokia SMS', 'messageToneSource': 'preloaded', 'messageTonePath': 'assets/audio/nokia_sms.mp3',
      'isRingtoneVibrate': true, 'isMessageVibrate': true,
    },
    'pager': {
      'ringtoneVolume': 30, 'messageVolume': 30,
      'ringtoneName': 'Beep Once', 'ringtoneSource': 'preloaded', 'ringtonePath': 'assets/audio/beep_once_ring_tone.mp3',
      'messageToneName': 'Beep Once', 'messageToneSource': 'preloaded', 'messageTonePath': 'assets/audio/beep_once_ring_tone.mp3',
      'isRingtoneVibrate': true, 'isMessageVibrate': true,
    },
    'discreet': {
      'ringtoneVolume': 20, 'messageVolume': 20,
      'ringtoneName': 'Beep Once', 'ringtoneSource': 'preloaded', 'ringtonePath': 'assets/audio/beep_once_ring_tone.mp3',
      'messageToneName': 'Beep Once', 'messageToneSource': 'preloaded', 'messageTonePath': 'assets/audio/beep_once_ring_tone.mp3',
      'isRingtoneVibrate': true, 'isMessageVibrate': true,
    },
  };

  /// Resets a single profile back to default:
  /// - 'normal', 'outdoor', 'silent': resets volume & vibration settings only (tones remain untouched).
  /// - 'meeting', 'pager', 'discreet': resets volume, vibration, AND restores preset tones ('Beep Once').
  void resetProfileToDefault(String profileId) {
    final defaults = _factoryDefaults[profileId];
    if (defaults == null) return;
    final index = _profiles.indexWhere((p) => p.id == profileId);
    if (index == -1) return;

    final isTonePreservedOnReset = (profileId == 'normal' || profileId == 'outdoor' || profileId == 'silent');

    if (isTonePreservedOnReset) {
      // Reset volume and vibrate settings only (ringtone / message tone selection preserved)
      _profiles[index] = _profiles[index].copyWith(
        ringtoneVolume: defaults['ringtoneVolume'] as int,
        messageVolume: defaults['messageVolume'] as int,
        isRingtoneVibrate: defaults['isRingtoneVibrate'] as bool,
        isMessageVibrate: defaults['isMessageVibrate'] as bool,
      );
    } else {
      // Reset volume, vibrate, AND tones to factory presets
      _profiles[index] = _profiles[index].copyWith(
        ringtoneVolume: defaults['ringtoneVolume'] as int,
        messageVolume: defaults['messageVolume'] as int,
        ringtoneName: defaults['ringtoneName'] as String,
        ringtoneSource: defaults['ringtoneSource'] as String,
        ringtonePath: defaults['ringtonePath'] as String,
        messageToneName: defaults['messageToneName'] as String,
        messageToneSource: defaults['messageToneSource'] as String,
        messageTonePath: defaults['messageTonePath'] as String,
        isRingtoneVibrate: defaults['isRingtoneVibrate'] as bool,
        isMessageVibrate: defaults['isMessageVibrate'] as bool,
      );
    }

    _saveProfilesToStorage();
    if (_profiles[index].isActive) {
      _applyHardwareSettings(_profiles[index]);
    }
    notifyListeners();
  }

  void resetToDefaults() {
    _themeMode = ThemeMode.system;
    _fontSizeIndex = 2;
    _pushNotifications = true;
    _ignoreBatteryOptimization = false;
    _hardwareSyncEnabled = true;
    _cancelTimedActivation();
    stopTestSound();
    // Restore all profiles to factory defaults
    for (final profileId in _factoryDefaults.keys) {
      resetProfileToDefault(profileId);
    }
    // Reset active profile to Normal
    for (var p in _profiles) {
      p.isActive = (p.id == 'normal');
    }
    _saveProfilesToStorage();
    _saveActiveProfileId('normal');
    _applyHardwareSettings(activeProfile);
    notifyListeners();
  }

  // Hardware Native OS Integration
  Future<void> _applyHardwareSettings(Profile profile) async {
    if (!_hardwareSyncEnabled) return;
    try {
      final ringVol = profile.ringtoneVolume / 100.0;
      final notifVol = profile.messageVolume / 100.0;

      await FlutterVolumeController.setVolume(ringVol, stream: AudioStream.ring);
      await FlutterVolumeController.setVolume(notifVol, stream: AudioStream.notification);
    } catch (_) {}
  }

  Future<void> _setHardwareVolume(AudioStream stream, double volume) async {
    if (!_hardwareSyncEnabled) return;
    try {
      await FlutterVolumeController.setVolume(volume, stream: stream);
    } catch (_) {}
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
