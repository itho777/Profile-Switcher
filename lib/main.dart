import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-warm SharedPreferences and AdMob in parallel before runApp
  final prefsFeature = SharedPreferences.getInstance();
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
    MobileAds.instance.initialize(); // fire-and-forget
  }
  final prefs = await prefsFeature; // wait only for prefs — fast disk read

  runApp(ProfileSelectorApp(prefs: prefs));
}

class ProfileSelectorApp extends StatefulWidget {
  final SharedPreferences prefs;
  const ProfileSelectorApp({super.key, required this.prefs});

  @override
  State<ProfileSelectorApp> createState() => _ProfileSelectorAppState();
}

class _ProfileSelectorAppState extends State<ProfileSelectorApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState(prefs: widget.prefs);
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Profile Switcher',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _appState.themeMode,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(_appState.fontScale),
              ),
              child: child!,
            );
          },
          home: HomeScreen(appState: _appState),
        );
      },
    );
  }
}
