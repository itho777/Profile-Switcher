package com.profileselector.profile_selector_app

import android.app.Activity
import android.content.Intent
import android.media.Ringtone
import android.media.RingtoneManager
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.profileselector/ringtone_picker"
    private val RINGTONE_PICKER_REQUEST = 999
    private var pendingResult: MethodChannel.Result? = null
    private var currentPlayingRingtone: Ringtone? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickRingtone" -> {
                    val typeString = call.argument<String>("type") ?: "ringtone"
                    val type = if (typeString == "notification") {
                        RingtoneManager.TYPE_NOTIFICATION
                    } else {
                        RingtoneManager.TYPE_RINGTONE
                    }

                    val title = if (typeString == "notification") "Select Message Alert Tone" else "Select Ringtone"

                    val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
                        putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, type)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, title)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
                        putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, true)
                    }

                    pendingResult = result
                    startActivityForResult(intent, RINGTONE_PICKER_REQUEST)
                }
                "getDefaultRingtone" -> {
                    try {
                        val defaultUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                        val ringtone = RingtoneManager.getRingtone(applicationContext, defaultUri)
                        val title = ringtone?.getTitle(applicationContext) ?: "Phone Default Ringtone"
                        result.success(mapOf("title" to title, "uri" to (defaultUri?.toString() ?: "")))
                    } catch (e: Exception) {
                        result.success(mapOf("title" to "Phone Default Ringtone", "uri" to ""))
                    }
                }
                "getDefaultNotificationTone" -> {
                    try {
                        val defaultUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                        val ringtone = RingtoneManager.getRingtone(applicationContext, defaultUri)
                        val title = ringtone?.getTitle(applicationContext) ?: "Phone Default Message Tone"
                        result.success(mapOf("title" to title, "uri" to (defaultUri?.toString() ?: "")))
                    } catch (e: Exception) {
                        result.success(mapOf("title" to "Phone Default Message Tone", "uri" to ""))
                    }
                }
                "openSoundSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_SOUND_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("ERROR", "Cannot open sound settings", e.message)
                    }
                }
                "playSystemTone" -> {
                    val uriString = call.argument<String>("uri")
                    stopCurrentTone()
                    if (!uriString.isNullEmpty()) {
                        try {
                            val uri = Uri.parse(uriString)
                            currentPlayingRingtone = RingtoneManager.getRingtone(applicationContext, uri)
                            currentPlayingRingtone?.play()
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("PLAY_ERROR", e.message, null)
                        }
                    } else {
                        val defaultUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                        currentPlayingRingtone = RingtoneManager.getRingtone(applicationContext, defaultUri)
                        currentPlayingRingtone?.play()
                        result.success(true)
                    }
                }
                "stopSystemTone" -> {
                    stopCurrentTone()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun String?.isNullEmpty(): Boolean = this == null || this.isEmpty() || this == "silent"

    private fun stopCurrentTone() {
        try {
            if (currentPlayingRingtone?.isPlaying == true) {
                currentPlayingRingtone?.stop()
            }
        } catch (_: Exception) {}
        currentPlayingRingtone = null
    }

    override fun onStop() {
        super.onStop()
        stopCurrentTone()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == RINGTONE_PICKER_REQUEST) {
            val result = pendingResult
            pendingResult = null
            if (result == null) return

            if (resultCode == Activity.RESULT_OK && data != null) {
                val uri: Uri? = data.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
                if (uri != null) {
                    val ringtone = RingtoneManager.getRingtone(applicationContext, uri)
                    val title = ringtone?.getTitle(applicationContext) ?: "Custom Tone"
                    result.success(mapOf("title" to title, "uri" to uri.toString()))
                } else {
                    result.success(mapOf("title" to "Silent", "uri" to "silent"))
                }
            } else {
                result.success(null)
            }
        }
    }
}
