import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../widgets/ad_banner_widget.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final AppState appState;
  final String? initialProfileId;

  const ProfileSettingsScreen({
    super.key,
    required this.appState,
    this.initialProfileId,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late String _editingProfileId;

  @override
  void initState() {
    super.initState();
    _editingProfileId = widget.initialProfileId ?? widget.appState.activeProfile.id;
  }

  @override
  void dispose() {
    // Stop any playing test sounds when leaving settings screen
    widget.appState.stopTestSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = widget.appState;
    final profiles = appState.profiles;

    // Retrieve currently selected profile to edit
    final profile = profiles.firstWhere(
      (p) => p.id == _editingProfileId,
      orElse: () => profiles.first,
    );

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                appState.stopTestSound();
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Profile Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          bottomNavigationBar: const AdBannerWidget(),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Requirement #10: Profile Selector Pulldown / Dropdown Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  color: theme.colorScheme.surfaceContainerLow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SELECT PROFILE TO EDIT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: profile.id,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                            items: profiles.map((p) {
                              return DropdownMenuItem<String>(
                                value: p.id,
                                child: Row(
                                  children: [
                                    Icon(p.icon, size: 20, color: theme.colorScheme.primary),
                                    const SizedBox(width: 12),
                                    Text(
                                      p.title,
                                      style: TextStyle(
                                        fontWeight: p.isActive ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                    if (p.isActive) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'ACTIVE',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newId) {
                              if (newId != null) {
                                appState.stopTestSound();
                                setState(() {
                                  _editingProfileId = newId;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Editing: ${profile.title} Profile (${profile.description})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Ringtone Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'CALL RINGTONE SETTINGS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Ringtone Source & Selection Card
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.ring_volume, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            const Text(
                              'Ringtone Tone Source',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Requirement #5: Options Pre-loaded vs Phone's tone
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'preloaded',
                              label: Text('Pre-loaded'),
                              icon: Icon(Icons.audiotrack, size: 16),
                            ),
                            ButtonSegment<String>(
                              value: 'phone',
                              label: Text("Phone's Tone"),
                              icon: Icon(Icons.phone_android, size: 16),
                            ),
                          ],
                          selected: {profile.ringtoneSource},
                          onSelectionChanged: (Set<String> newSelection) {
                            final newSource = newSelection.first;
                            appState.stopTestSound();
                            if (newSource == 'preloaded') {
                              appState.updateProfileRingtone(
                                profile.id,
                                name: preloadedRingtones.first.name,
                                source: 'preloaded',
                                path: preloadedRingtones.first.assetPath,
                              );
                            } else {
                              appState.pickPhoneRingtone(profile.id, 'ringtone');
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        if (profile.ringtoneSource == 'preloaded') ...[
                          const Text('Select Pre-loaded Ringtone:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.colorScheme.outline),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: preloadedRingtones.any((t) => t.assetPath == profile.ringtonePath)
                                    ? profile.ringtonePath
                                    : preloadedRingtones.first.assetPath,
                                isExpanded: true,
                                items: preloadedRingtones.map((tone) {
                                  return DropdownMenuItem<String>(
                                    value: tone.assetPath,
                                    child: Text(tone.name),
                                  );
                                }).toList(),
                                onChanged: (path) {
                                  if (path != null) {
                                    final tone = preloadedRingtones.firstWhere((t) => t.assetPath == path);
                                    appState.updateProfileRingtone(
                                      profile.id,
                                      name: tone.name,
                                      source: 'preloaded',
                                      path: tone.assetPath,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Selected Phone Ringtone:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 2),
                                    Text(
                                      profile.ringtoneName,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.music_note, size: 16),
                                label: const Text('Change'),
                                onPressed: () {
                                  appState.pickPhoneRingtone(profile.id, 'ringtone');
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Requirement #7: Option to go to phone sound settings
                          OutlinedButton.icon(
                            icon: const Icon(Icons.settings, size: 16),
                            label: const Text("Go to Phone's Sound Settings"),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 38),
                            ),
                            onPressed: () {
                              appState.openPhoneSoundSettings();
                            },
                          ),
                        ],

                        const SizedBox(height: 16),
                        const Divider(),
                        // Requirement #4: Button to test selected sound
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Test Ringtone Sound',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            _buildTestSoundButton(
                              appState: appState,
                              source: profile.ringtoneSource,
                              path: profile.ringtonePath,
                              name: profile.ringtoneName,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Ringtone Volume & Vibrate Card
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      // Requirement #9: Ringtone Volume Slider
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.volume_up, color: theme.colorScheme.primary),
                                const SizedBox(width: 12),
                                Text(
                                  'Ringtone Volume (${profile.ringtoneVolume}%)',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.volume_mute, size: 20),
                                Expanded(
                                  child: Slider(
                                    value: profile.ringtoneVolume.toDouble(),
                                    min: 0,
                                    max: 100,
                                    activeColor: theme.colorScheme.primary,
                                    onChanged: (val) {
                                      appState.updateProfileRingtoneVolume(profile.id, val.toInt());
                                    },
                                  ),
                                ),
                                const Icon(Icons.volume_up, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: Icon(Icons.vibration, color: theme.colorScheme.primary),
                        title: const Text('Ringtone Vibration', style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: const Text('Vibrate on incoming calls'),
                        value: profile.isRingtoneVibrate,
                        onChanged: (val) {
                          appState.updateProfileRingtoneVibrate(profile.id, val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Message Alert Tone Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'MESSAGE ALERT TONE SETTINGS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Message Tone Source & Selection Card
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.sms, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            const Text(
                              'Message Tone Source',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'preloaded',
                              label: Text('Pre-loaded'),
                              icon: Icon(Icons.audiotrack, size: 16),
                            ),
                            ButtonSegment<String>(
                              value: 'phone',
                              label: Text("Phone's Tone"),
                              icon: Icon(Icons.phone_android, size: 16),
                            ),
                          ],
                          selected: {profile.messageToneSource},
                          onSelectionChanged: (Set<String> newSelection) {
                            final newSource = newSelection.first;
                            appState.stopTestSound();
                            if (newSource == 'preloaded') {
                              appState.updateProfileMessageTone(
                                profile.id,
                                name: preloadedMessageTones.first.name,
                                source: 'preloaded',
                                path: preloadedMessageTones.first.assetPath,
                              );
                            } else {
                              appState.pickPhoneRingtone(profile.id, 'notification');
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        if (profile.messageToneSource == 'preloaded') ...[
                          const Text('Select Pre-loaded Message Tone:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.colorScheme.outline),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: preloadedMessageTones.any((t) => t.assetPath == profile.messageTonePath)
                                    ? profile.messageTonePath
                                    : preloadedMessageTones.first.assetPath,
                                isExpanded: true,
                                items: preloadedMessageTones.map((tone) {
                                  return DropdownMenuItem<String>(
                                    value: tone.assetPath,
                                    child: Text(tone.name),
                                  );
                                }).toList(),
                                onChanged: (path) {
                                  if (path != null) {
                                    final tone = preloadedMessageTones.firstWhere((t) => t.assetPath == path);
                                    appState.updateProfileMessageTone(
                                      profile.id,
                                      name: tone.name,
                                      source: 'preloaded',
                                      path: tone.assetPath,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Selected Message Tone:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 2),
                                    Text(
                                      profile.messageToneName,
                                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.music_note, size: 16),
                                label: const Text('Change'),
                                onPressed: () {
                                  appState.pickPhoneRingtone(profile.id, 'notification');
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.settings, size: 16),
                            label: const Text("Go to Phone's Sound Settings"),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 38),
                            ),
                            onPressed: () {
                              appState.openPhoneSoundSettings();
                            },
                          ),
                        ],

                        const SizedBox(height: 16),
                        const Divider(),
                        // Requirement #4: Test Message Sound Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Test Message Sound',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            _buildTestSoundButton(
                              appState: appState,
                              source: profile.messageToneSource,
                              path: profile.messageTonePath,
                              name: profile.messageToneName,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Message Volume & Vibrate Card
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.volume_up, color: theme.colorScheme.primary),
                                const SizedBox(width: 12),
                                Text(
                                  'Message Volume (${profile.messageVolume}%)',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.volume_mute, size: 20),
                                Expanded(
                                  child: Slider(
                                    value: profile.messageVolume.toDouble(),
                                    min: 0,
                                    max: 100,
                                    activeColor: theme.colorScheme.primary,
                                    onChanged: (val) {
                                      appState.updateProfileMessageVolume(profile.id, val.toInt());
                                    },
                                  ),
                                ),
                                const Icon(Icons.volume_up, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: Icon(Icons.vibration, color: theme.colorScheme.primary),
                        title: const Text('Message Vibration', style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: const Text('Vibrate on incoming messages'),
                        value: profile.isMessageVibrate,
                        onChanged: (val) {
                          appState.updateProfileMessageVibrate(profile.id, val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Reset This Profile to Default Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.restore, size: 18),
                    label: Text('Reset ${profile.title} Profile to Default'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 46),
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Reset ${profile.title} Profile?'),
                          content: Text(
                            'This will restore the ${profile.title} profile\'s factory default '
                            'volumes, tones, and vibration settings.\n\nYour other profiles will not be affected.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('CANCEL'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                              ),
                              onPressed: () {
                                appState.stopTestSound();
                                appState.resetProfileToDefault(profile.id);
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${profile.title} profile reset to defaults.'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Text('RESET'),
                            ),
                          ],
                        ),
                      );
                    },
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

  Widget _buildTestSoundButton({
    required AppState appState,
    required String source,
    required String path,
    required String name,
  }) {
    final bool isTestingThisTone = appState.isPlayingTestSound && appState.currentlyTestingTonePath == path;

    return FilledButton.icon(
      icon: Icon(isTestingThisTone ? Icons.stop : Icons.play_arrow, size: 18),
      label: Text(isTestingThisTone ? 'Stop Test' : 'Test Sound'),
      style: FilledButton.styleFrom(
        backgroundColor: isTestingThisTone ? Colors.red : null,
      ),
      onPressed: () {
        if (isTestingThisTone) {
          appState.stopTestSound();
        } else {
          appState.playTestSound(source: source, path: path, name: name);
        }
      },
    );
  }
}
