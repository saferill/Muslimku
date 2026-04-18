package com.muslimku.app.notification

import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.IBinder
import androidx.core.app.ServiceCompat

class NativeAdhanForegroundService : Service() {
    private var mediaPlayer: MediaPlayer? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopPlayback()
            stopSelf()
            return START_NOT_STICKY
        }

        val alarm = NativeAdhanAlarm.fromIntent(intent ?: return START_NOT_STICKY)
            ?: return START_NOT_STICKY
        val stopIntent =
            PendingIntent.getService(
                this,
                alarm.id + 900000,
                Intent(this, NativeAdhanForegroundService::class.java).apply {
                    action = ACTION_STOP
                },
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

        startForeground(
            alarm.id,
            NativeAdhanNotifier.buildForegroundNotification(
                context = this,
                alarm = alarm,
                stopPendingIntent = stopIntent,
            ),
        )
        startPlayback(alarm)
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        stopPlayback()
        super.onDestroy()
    }

    private fun startPlayback(alarm: NativeAdhanAlarm) {
        stopPlayback()
        val rawName = alarm.soundRawResource ?: run {
            stopSelf()
            return
        }
        val resourceId = resources.getIdentifier(rawName, "raw", packageName)
        if (resourceId == 0) {
            stopSelf()
            return
        }

        val fileDescriptor = resources.openRawResourceFd(resourceId)
        val player = MediaPlayer()
        player.setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build(),
        )
        player.setDataSource(
            fileDescriptor.fileDescriptor,
            fileDescriptor.startOffset,
            fileDescriptor.length,
        )
        fileDescriptor.close()
        player.setOnPreparedListener {
            it.setVolume(alarm.volume.toFloat(), alarm.volume.toFloat())
            it.start()
        }
        player.setOnCompletionListener {
            stopPlayback()
            stopSelf()
        }
        player.prepareAsync()
        mediaPlayer = player
    }

    private fun stopPlayback() {
        mediaPlayer?.run {
            if (isPlaying) {
                stop()
            }
            release()
        }
        mediaPlayer = null
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
    }

    companion object {
        private const val ACTION_STOP = "com.muslimku.app.notification.STOP_ADHAN"

        fun createStartIntent(context: Context, alarm: NativeAdhanAlarm): Intent =
            alarm.toIntent(Intent(context, NativeAdhanForegroundService::class.java))

        fun stop(context: Context) {
            context.startService(
                Intent(context, NativeAdhanForegroundService::class.java).apply {
                    action = ACTION_STOP
                },
            )
        }
    }
}
