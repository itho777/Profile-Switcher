import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import 'about_dialog.dart' as custom_about;

class AppSettingsScreen extends StatelessWidget {
  final AppState appState;

  const AppSettingsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('App Settings', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const custom_about.AboutAppDialog(),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION: Appearance
                _buildSectionHeader(context, Icons.brush, 'APPEARANCE'),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Theme Selector', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildThemeButton(
                              context: context,
                              mode: ThemeMode.light,
                              icon: Icons.light_mode,
                              label: 'Light',
                              isSelected: appState.themeMode == ThemeMode.light,
                            ),
                            const SizedBox(width: 8),
                            _buildThemeButton(
                              context: context,
                              mode: ThemeMode.dark,
                              icon: Icons.dark_mode,
                              label: 'Dark',
                              isSelected: appState.themeMode == ThemeMode.dark,
                            ),
                            const SizedBox(width: 8),
                            _buildThemeButton(
                              context: context,
                              mode: ThemeMode.system,
                              icon: Icons.settings_brightness,
                              label: 'System',
                              isSelected: appState.themeMode == ThemeMode.system,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Font Size', style: theme.textTheme.titleMedium),
                            Text(
                              _fontSizeLabel(appState.fontSizeIndex),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: appState.fontSizeIndex.toDouble(),
                          min: 1,
                          max: 4,
                          divisions: 3,
                          activeColor: theme.colorScheme.primary,
                          onChanged: (val) {
                            appState.setFontSizeIndex(val.toInt());
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('A', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION: App Permissions
                _buildSectionHeader(context, Icons.security, 'APP PERMISSIONS'),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: Icon(Icons.phonelink_setup, color: theme.colorScheme.primary),
                        title: const Text('Sync OS Hardware Volume'),
                        subtitle: const Text('Automatically sets physical device ringtone & notification volume'),
                        value: appState.hardwareSyncEnabled,
                        onChanged: (val) => appState.toggleHardwareSync(val),
                      ),
                      const Divider(height: 1, indent: 56),
                      SwitchListTile(
                        secondary: Icon(Icons.notifications, color: theme.colorScheme.primary),
                        title: const Text('Push Notifications'),
                        subtitle: const Text('Alerts, badges, and sounds'),
                        value: appState.pushNotifications,
                        onChanged: (val) => appState.togglePushNotifications(val),
                      ),
                      const Divider(height: 1, indent: 56),
                      SwitchListTile(
                        secondary: Icon(Icons.battery_saver, color: theme.colorScheme.primary),
                        title: const Text('Ignore Battery Optimization'),
                        subtitle: const Text('Ensures profiles activate without delay'),
                        value: appState.ignoreBatteryOptimization,
                        onChanged: (val) => appState.toggleIgnoreBatteryOptimization(val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION: About
                _buildSectionHeader(context, Icons.info, 'ABOUT'),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Version'),
                        subtitle: const Text('4.2.0-stable (Build 1204)'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'UP TO DATE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Developer Credits'),
                        subtitle: const Text('Engineering & Design Team'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => const custom_about.AboutAppDialog(),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Reset to Defaults'),
                        subtitle: const Text('Revert all settings to original values'),
                        trailing: Icon(Icons.settings_backup_restore, color: theme.colorScheme.error),
                        onTap: () {
                          _confirmResetDialog(context, appState);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Aesthetic Developer Card Highlight
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primaryContainer,
                        ),
                        child: Icon(Icons.code, color: theme.colorScheme.onPrimaryContainer, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Made with Passion',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Built by the Lumia Modern Core Team in Helsinki. Thank you for using our product.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeButton({
    required BuildContext context,
    required ThemeMode mode,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Material(
        color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => appState.setThemeMode(mode),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fontSizeLabel(int index) {
    switch (index) {
      case 1:
        return 'Small';
      case 2:
        return 'Standard';
      case 3:
        return 'Large';
      case 4:
        return 'Extra Large';
      default:
        return 'Standard';
    }
  }

  void _confirmResetDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text('Are you sure you want to revert all settings to factory default values?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () {
                appState.resetToDefaults();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset to factory defaults.')),
                );
              },
              child: const Text('RESET', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
