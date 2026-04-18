package com.muslimku.app

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import com.muslimku.app.notification.NativeAdhanAlarm
import com.muslimku.app.notification.NativeAdhanForegroundService
import com.muslimku.app.notification.NativeAdhanScheduler
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val ADHAN_CHANNEL = "com.muslimku.app/adhan_alarm"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ADHAN_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAdhanAlarms" -> {
                    val rawAlarms =
                        call.argument<List<Map<String, Any?>>>("alarms").orEmpty()
                    val alarms = rawAlarms.mapNotNull { NativeAdhanAlarm.fromMap(it) }
                    NativeAdhanScheduler.scheduleAll(applicationContext, alarms)
                    result.success(null)
                }

                "cancelAdhanAlarms" -> {
                    NativeAdhanScheduler.cancelAll(applicationContext)
                    result.success(null)
                }

                "stopAdhanPlayback" -> {
                    NativeAdhanForegroundService.stop(applicationContext)
                    result.success(null)
                }

                "previewAdhanSound" -> {
                    val rawResource = call.argument<String>("soundRawResource")
                    if (rawResource.isNullOrBlank()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    val volume = call.argument<Double>("volume") ?: 1.0
                    val previewAlarm =
                        NativeAdhanAlarm(
                            id = (System.currentTimeMillis() % Int.MAX_VALUE).toInt(),
                            title = "Pratinjau Adzan",
                            body = "Memutar suara adzan untuk pengujian.",
                            whenEpochMs = System.currentTimeMillis(),
                            channelId = "muslimku_adhan_preview",
                            channelName = "Muslimku Adhan Preview",
                            channelDescription = "Preview suara adzan Muslimku",
                            soundRawResource = rawResource,
                            payload = "preview:$rawResource",
                            enableVibration = false,
                            volume = volume,
                        )
                    val intent = NativeAdhanForegroundService.createStartIntent(
                        applicationContext,
                        previewAlarm,
                    )
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        applicationContext.startForegroundService(intent)
                    } else {
                        applicationContext.startService(intent)
                    }
                    result.success(true)
                }

                "canScheduleExactAlarms" -> {
                    val alarmManager =
                        getSystemService(Context.ALARM_SERVICE) as AlarmManager
                    val canSchedule = Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                        alarmManager.canScheduleExactAlarms()
                    result.success(canSchedule)
                }

                "openExactAlarmSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val intent = Intent(
                            Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM,
                            Uri.parse("package:$packageName"),
                        ).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
