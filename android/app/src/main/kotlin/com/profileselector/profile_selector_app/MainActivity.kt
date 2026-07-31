package com.profileselector.profile_selector_app

import android.app.Activity
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.profileselector/ringtone_picker"
    private val RINGTONE_PICKER_REQUEST = 999
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "pickRingtone") {
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
            } else {
                result.notImplemented()
            }
        }
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
