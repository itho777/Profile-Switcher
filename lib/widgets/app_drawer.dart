import 'package:flutter/material.dart';
import '../providers/app_state.dart';
import '../screens/scheduler_screen.dart';
import '../screens/profile_settings_screen.dart';
import '../screens/app_settings_screen.dart';

class AppDrawer extends StatelessWidget {
  final AppState appState;

  const AppDrawer({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Menu',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('Scheduler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SchedulerScreen(appState: appState)),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  ListTile(
                    leading: const Icon(Icons.tune),
                    title: const Text('Profile Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProfileSettingsScreen(appState: appState)),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                    title: const Text('Appearance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    trailing: Switch(
                      value: isDark,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        appState.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onTap: () {
                      appState.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                    },
                  ),
                  const SizedBox(height: 4),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('App Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AppSettingsScreen(appState: appState)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
