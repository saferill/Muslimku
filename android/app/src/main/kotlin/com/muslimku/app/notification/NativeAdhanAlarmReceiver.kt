package com.muslimku.app.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat

class NativeAdhanAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val alarm = NativeAdhanAlarm.fromIntent(intent) ?: return
        NativeAdhanScheduler.markTriggered(context, alarm.id)

        if ((alarm.soundRawResource ?: "").isBlank()) {
            NativeAdhanNotifier.showReminderNotification(context, alarm)
            return
        }

        ContextCompat.startForegroundService(
            context,
            NativeAdhanForegroundService.createStartIntent(context, alarm),
        )
    }
}
