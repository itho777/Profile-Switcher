import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  private let CHANNEL = "com.profileselector/ringtone_picker"
  private var audioPlayer: AVAudioPlayer?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    setupMethodChannel(registry: engineBridge.pluginRegistry)
  }

  private func setupMethodChannel(registry: FlutterPluginRegistry) {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      switch call.method {

      case "pickRingtone":
        // iOS does not have a native system ringtone picker like Android.
        // We return nil so Flutter falls back to the preloaded tones dialog.
        result(nil)

      case "getDefaultRingtone":
        // iOS default ringtone is "Opening" but is not directly accessible via API.
        // Return a descriptive placeholder — the app will save this as Normal profile's ringtone.
        result(["title": "iPhone Default Ringtone", "uri": ""])

      case "getDefaultNotificationTone":
        result(["title": "iPhone Default Message Tone", "uri": ""])

      case "openSoundSettings":
        // Open iOS Settings app (deeplink to Sounds & Haptics if available)
        if let url = URL(string: "App-Prefs:root=Sounds") {
          if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            result(true)
            return
          }
        }
        // Fallback: open general Settings
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        result(true)

      case "playSystemTone":
        // On iOS we can play a system sound by ID for notification tones
        // For phone ringtones, fallback to AudioServicesPlaySystemSound for a beep
        self.stopCurrentTone()
        AudioServicesPlaySystemSound(1007) // SMS Received tone
        result(true)

      case "stopSystemTone":
        self.stopCurrentTone()
        result(true)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func stopCurrentTone() {
    audioPlayer?.stop()
    audioPlayer = nil
  }
}
