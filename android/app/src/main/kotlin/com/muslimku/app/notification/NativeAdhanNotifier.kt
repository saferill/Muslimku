package com.muslimku.app.notification

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import androidx.core.app.NotificationCompat
import com.muslimku.app.R

object NativeAdhanNotifier {
    fun showReminderNotification(context: Context, alarm: NativeAdhanAlarm) {
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        ensureChannel(context, alarm, silent = false)
        notificationManager.notify(
            alarm.id,
            buildNotification(
                context = context,
                alarm = alarm,
                silent = false,
                ongoing = false,
                stopPendingIntent = null,
            ),
        )
    }

    fun buildForegroundNotification(
        context: Context,
        alarm: NativeAdhanAlarm,
        stopPendingIntent: PendingIntent,
    ): Notification {
        ensureChannel(context, alarm, silent = true)
        return buildNotification(
            context = context,
            alarm = alarm,
            silent = true,
            ongoing = true,
            stopPendingIntent = stopPendingIntent,
        )
    }

    private fun buildNotification(
        context: Context,
        alarm: NativeAdhanAlarm,
        silent: Boolean,
        ongoing: Boolean,
        stopPendingIntent: PendingIntent?,
    ): Notification {
        val launchIntent =
            context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?: Intent(context, com.muslimku.app.MainActivity::class.java).apply {
                    flags =
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                            Intent.FLAG_ACTIVITY_CLEAR_TOP or
                            Intent.FLAG_ACTIVITY_SINGLE_TOP
                }
        launchIntent.putExtra("notification_payload", alarm.payload)
        val contentPendingIntent = PendingIntent.getActivity(
            context,
            alarm.id,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder =
            NotificationCompat.Builder(context, alarm.channelId)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(alarm.title)
                .setContentText(alarm.body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(alarm.body))
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setAutoCancel(!ongoing)
                .setOngoing(ongoing)
                .setContentIntent(contentPendingIntent)
                .setOnlyAlertOnce(true)

        if (silent) {
            builder.setSilent(true).setSound(null)
        }

        if (alarm.enableVibration) {
            builder.setVibrate(longArrayOf(300, 300, 300, 300, 300))
        }

        if (stopPendingIntent != null) {
            builder.addAction(
                R.mipmap.ic_launcher,
                "Stop",
                stopPendingIntent,
            )
        }

        return builder.build()
    }

    private fun ensureChannel(
        context: Context,
        alarm: NativeAdhanAlarm,
        silent: Boolean,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val existing = notificationManager.getNotificationChannel(alarm.channelId)
        if (existing != null) return

        val audioAttributes =
            AudioAttributes.Builder()
                .setUsage(
                    if (silent) {
                        AudioAttributes.USAGE_ALARM
                    } else {
                        AudioAttributes.USAGE_NOTIFICATION_EVENT
                    },
                )
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

        val channel =
            NotificationChannel(
                alarm.channelId,
                alarm.channelName,
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = alarm.channelDescription
                enableVibration(alarm.enableVibration)
                vibrationPattern = longArrayOf(300, 300, 300, 300, 300)
                if (silent) {
                    setSound(null, null)
                } else {
                    setSound(
                        RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION),
                        audioAttributes,
                    )
                }
            }
        notificationManager.createNotificationChannel(channel)
    }
}
