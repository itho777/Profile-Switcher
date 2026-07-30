import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../models/profile.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final AppState appState;

  const ProfileSettingsScreen({super.key, required this.appState});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
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
            title: const Text('Profile Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Active Profile Selector Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: theme.colorScheme.surfaceContainerLow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACTIVE PROFILE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLowest,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          border: Border(
                            bottom: BorderSide(color: theme.colorScheme.primary, width: 2),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: activeProfile.id,
                            isExpanded: true,
                            items: appState.profiles.map((Profile p) {
                              return DropdownMenuItem<String>(
                                value: p.id,
                                child: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) appState.activateProfile(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
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
                      // Ringtone Item
                      ListTile(
                        leading: Icon(Icons.ring_volume, color: theme.colorScheme.primary),
                        title: const Text('Ringtone', style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(activeProfile.ringtoneName),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showRingtoneDialog(context, appState, activeProfile);
                        },
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

                      // Message Alert Dropdown
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.sms, color: theme.colorScheme.primary),
                                const SizedBox(width: 16),
                                const Text('Message Alert Sounds', style: TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerLow,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  border: Border(
                                    bottom: BorderSide(color: theme.colorScheme.outline, width: 2),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _messageTones.contains(activeProfile.messageToneName)
                                        ? activeProfile.messageToneName
                                        : _messageTones[1],
                                    isExpanded: true,
                                    items: _messageTones.map((tone) {
                                      return DropdownMenuItem<String>(
                                        value: tone,
                                        child: Text(tone),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) appState.updateActiveMessageTone(val);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

                      // Message Alert Vibration Switch
                      SwitchListTile(
                        secondary: Icon(Icons.vibration, color: theme.colorScheme.primary),
                        title: const Text('Message Alert Vibration', style: TextStyle(fontWeight: FontWeight.w500)),
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
                      child: Icon(
                        Icons.phonelink_setup,
                        size: 48,
                        color: theme.colorScheme.primary,
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
}
