# Profile Switcher

A retro Nokia-inspired phone profile manager for Android. Switch between sound profiles with one tap — volume, ringtone, and vibration settings applied instantly to your device.

[**Get it on Google Play →**](https://play.google.com/store/apps/details?id=id.broadandbright.profileswitcher) &nbsp;|&nbsp; [**Download APK →**](https://github.com/itho777/Profile-Switcher/releases/latest/download/app-release.apk) &nbsp;|&nbsp; [**Product Page →**](https://broadandbright.id/profileswitcher/)

---

## Features

**Six built-in profiles**

| Profile | Volume | Tone |
|---|---|---|
| Outdoor | 100% | Nokia Ring |
| Normal | 70% | Nokia Ring |
| Meeting | 30% | Beep Once |
| Silent | 0% | — |
| Pager | 30% | Beep Once |
| Discreet | 20% | Beep Once |

- **Settings persist** — volume, ringtone, and vibration saved per profile; restored on every launch
- **Custom ringtones** — use built-in Nokia tones or pick any ringtone from your phone
- **Timed activation** — activate a profile for 1–24 hours, auto-reverts to Normal when done
- **Hardware sync** — switching a profile instantly applies volume to ring and notification streams
- **Dark & light theme** — follows system or set manually; adjustable font size
- **Fully offline** — no internet, no account, no cloud

---

## Build

Requirements: Flutter 3.x, Android SDK 36

```bash
git clone https://github.com/itho777/Profile-Switcher.git
cd Profile-Switcher
flutter pub get
flutter run
```

**Release build (AAB):**

```bash
flutter build appbundle --release
```

Signing is handled by GitHub Actions CI on tagged releases. See [`.github/workflows/build_apk.yml`](.github/workflows/build_apk.yml).

---

## Release

Tag a version to trigger CI — builds a signed APK + AAB and publishes them to GitHub Releases automatically.

```bash
git tag v1.0.0
git push origin v1.0.0
```

Download the latest APK directly:
```
https://github.com/itho777/Profile-Switcher/releases/latest/download/app-release.apk
```

---

## Project Structure

```
lib/
  main.dart                       # Entry point
  providers/
    app_state.dart                # All state: profiles, persistence, hardware sync
  models/
    profile.dart                  # Profile data model
    schedule_item.dart            # Scheduler item model
  screens/
    home_screen.dart              # Profile list + active state banner
    profile_settings_screen.dart  # Volume, ringtone, vibration per profile
    scheduler_screen.dart         # Timed schedule list
    app_settings_screen.dart      # Theme, font size, hardware sync toggle
  widgets/
    ad_banner_widget.dart         # AdMob banner
    app_drawer.dart               # Side navigation drawer
  theme/
    app_theme.dart                # Light + dark Material 3 theme
assets/
  audio/                          # Bundled Nokia ringtones
android/
  app/src/main/kotlin/id/broadandbright/profileswitcher/
    MainActivity.kt               # MethodChannel: ringtone picker, volume, sound settings
```

---

## Privacy

Profile Switcher does not collect, transmit, or store any data externally. All settings are saved locally via Android SharedPreferences and deleted on uninstall.

[Privacy Policy](https://broadandbright.id/profileswitcher/privacy/)

---

## License

MIT © [Broad & Bright Indonesia](https://broadandbright.id)
