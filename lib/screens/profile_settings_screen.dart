import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/app_state.dart';
import '../models/profile.dart';
import '../widgets/ad_banner_widget.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final AppState appState;

  const ProfileSettingsScreen({super.key, required this.appState});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  static const _ringtoneChannel = MethodChannel('com.profileselector/ringtone_picker');

  final List<String> _ringtones = [
    'Nokia Tune',
    'Horizon',
    'Chime Classic',
    'Digital Pager',
    'Ascending Tone',
  ];

  final List<String> _messageTones = [
    'Message 1',
    'Message 2 (Default)',
    'Message 3',
    'Ascending',
    'Silent',
  ];

  Future<void> _pickNativeTone(AppState appState, String type) async {
    try {
      final result = await _ringtoneChannel.invokeMethod<Map>('pickRingtone', {'type': type});
      if (result != null && result['title'] != null) {
        final String toneName = result['title'].toString();
        if (type == 'notification') {
          appState.updateActiveMessageTone(toneName);
        } else {
          appState.updateActiveRingtone(toneName);
        }
      }
    } catch (e) {
      if (!mounted) return;
      if (type == 'notification') {
        _showFallbackMessageToneDialog(context, appState);
      } else {
        _showRingtoneDialog(context, appState, appState.activeProfile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = widget.appState;
    final activeProfile = appState.activeProfile;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '${activeProfile.title} Settings',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          bottomNavigationBar: const AdBannerWidget(),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: theme.colorScheme.surfaceContainerLow,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          activeProfile.icon,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeProfile.title.toUpperCase(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Customize audio, vibration, and alerts for this profile.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Sound & Notification Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'SOUND & NOTIFICATION',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Settings List Stack
                Container(
                  color: theme.colorScheme.surfaceContainerLowest,
                  child: Column(
                    children: [
                      // Ringtone Item (Native Selector)
                      ListTile(
                        leading: Icon(Icons.ring_volume, color: theme.colorScheme.primary),
                        title: const Text('Ringtone', style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(activeProfile.ringtoneName),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _pickNativeTone(appState, 'ringtone'),
                      ),
                      const Divider(height: 1, indent: 56),

                      // Ringtone Volume Slider Item
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.volume_up, color: theme.colorScheme.primary),
                                const SizedBox(width: 16),
                                Text(
                                  'Ringtone Volume (${activeProfile.ringtoneVolume}%)',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const SizedBox(width: 40),
                                const Icon(Icons.volume_mute, size: 20),
                                Expanded(
                                  child: Slider(
                                    value: activeProfile.ringtoneVolume.toDouble(),
                                    min: 0,
                                    max: 100,
                                    activeColor: theme.colorScheme.primary,
                                    onChanged: (val) {
                                      appState.updateActiveRingtoneVolume(val.toInt());
                                    },
                                  ),
                                ),
                                const Icon(Icons.volume_up, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, indent: 56),

                      // Ringtone Vibration Switch
                      SwitchListTile(
                        secondary: Icon(Icons.vibration, color: theme.colorScheme.primary),
                        title: const Text('Ringtone Vibration', style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: const Text('Vibrate on incoming calls'),
                        value: activeProfile.isRingtoneVibrate,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: (val) {
                          appState.updateActiveRingtoneVibrate(val);
                        },
                      ),
                      const Divider(height: 1, indent: 56),

                      // Message Alert Tone (Native Selector)
                      ListTile(
                        leading: Icon(Icons.sms, color: theme.colorScheme.primary),
                        title: const Text('Message Alert Tone', style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(activeProfile.messageToneName),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _pickNativeTone(appState, 'notification'),
                      ),
                      const Divider(height: 1, indent: 56),

                      // Message Volume Slider
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.volume_up, color: theme.colorScheme.primary),
                                const SizedBox(width: 16),
                                Text(
                                  'Message Alert Volume (${activeProfile.messageVolume}%)',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const SizedBox(width: 40),
                                const Icon(Icons.volume_mute, size: 20),
                                Expanded(
                                  child: Slider(
                                    value: activeProfile.messageVolume.toDouble(),
                                    min: 0,
                                    max: 100,
                                    activeColor: theme.colorScheme.primary,
                                    onChanged: (val) {
                                      appState.updateActiveMessageVolume(val.toInt());
                                    },
                                  ),
                                ),
                                const Icon(Icons.volume_up, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, indent: 56),

                      // Message Vibration Switch
                      SwitchListTile(
                        secondary: Icon(Icons.vibration, color: theme.colorScheme.primary),
                        title: const Text('Message Vibration', style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: const Text('Vibrate on incoming messages'),
                        value: activeProfile.isMessageVibrate,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: (val) {
                          appState.updateActiveMessageVibrate(val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                // Aesthetic Branding Anchor
                Center(
                  child: Opacity(
                    opacity: 0.25,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.primary, width: 4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(48),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRingtoneDialog(BuildContext context, AppState appState, Profile activeProfile) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Select Ringtone'),
          children: _ringtones.map((tone) {
            final isSelected = tone == activeProfile.ringtoneName;
            return SimpleDialogOption(
              onPressed: () {
                appState.updateActiveRingtone(tone);
                Navigator.pop(ctx);
              },
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  ),
                  const SizedBox(width: 12),
                  Text(tone, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showFallbackMessageToneDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Select Message Alert Tone'),
          children: _messageTones.map((tone) {
            final isSelected = tone == appState.activeProfile.messageToneName;
            return SimpleDialogOption(
              onPressed: () {
                appState.updateActiveMessageTone(tone);
                Navigator.pop(ctx);
              },
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  ),
                  const SizedBox(width: 12),
                  Text(tone, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
