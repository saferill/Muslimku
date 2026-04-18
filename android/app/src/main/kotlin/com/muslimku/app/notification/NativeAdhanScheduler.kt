package com.muslimku.app.notification

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray

object NativeAdhanScheduler {
    private const val PREFS_NAME = "muslimku_native_adhan"
    private const val KEY_ALARMS = "scheduled_alarms_json"

    fun scheduleAll(context: Context, alarms: List<NativeAdhanAlarm>) {
        cancelExisting(context)
        val futureAlarms = alarms
            .filter { it.whenEpochMs > System.currentTimeMillis() }
            .sortedBy { it.whenEpochMs }
        persist(context, futureAlarms)
        futureAlarms.forEach { schedule(context, it) }
    }

    fun rescheduleFromStorage(context: Context) {
        val futureAlarms = load(context)
            .filter { it.whenEpochMs > System.currentTimeMillis() }
            .sortedBy { it.whenEpochMs }
        persist(context, futureAlarms)
        futureAlarms.forEach { schedule(context, it) }
    }

    fun cancelAll(context: Context) {
        cancelExisting(context)
        persist(context, emptyList())
    }

    fun markTriggered(context: Context, id: Int) {
        val remaining = load(context).filter { it.id != id && it.whenEpochMs > System.currentTimeMillis() }
        persist(context, remaining)
    }

    private fun schedule(context: Context, alarm: NativeAdhanAlarm) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = alarm.toIntent(Intent(context, NativeAdhanAlarmReceiver::class.java))
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            alarm.id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            !alarmManager.canScheduleExactAlarms()
        ) {
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                alarm.whenEpochMs,
                pendingIntent,
            )
            return
        }

        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            alarm.whenEpochMs,
            pendingIntent,
        )
    }

    private fun cancelExisting(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        load(context).forEach { alarm ->
            val intent = Intent(context, NativeAdhanAlarmReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                alarm.id,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            alarmManager.cancel(pendingIntent)
        }
    }

    private fun persist(context: Context, alarms: List<NativeAdhanAlarm>) {
        val jsonArray = JSONArray()
        alarms.forEach { jsonArray.put(it.toJson()) }
        context
            .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_ALARMS, jsonArray.toString())
            .apply()
    }

    private fun load(context: Context): List<NativeAdhanAlarm> {
        val raw = context
            .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(KEY_ALARMS, null)
            ?: return emptyList()
        return runCatching {
            val json = JSONArray(raw)
            buildList {
                for (index in 0 until json.length()) {
                    NativeAdhanAlarm.fromJson(json.getJSONObject(index))?.let(::add)
                }
            }
        }.getOrDefault(emptyList())
    }
}
