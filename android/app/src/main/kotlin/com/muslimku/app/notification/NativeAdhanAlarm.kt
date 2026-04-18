package com.muslimku.app.notification

import android.content.Intent
import org.json.JSONObject

data class NativeAdhanAlarm(
    val id: Int,
    val title: String,
    val body: String,
    val whenEpochMs: Long,
    val channelId: String,
    val channelName: String,
    val channelDescription: String,
    val soundRawResource: String?,
    val payload: String?,
    val enableVibration: Boolean,
    val volume: Double,
) {
    fun toJson(): JSONObject =
        JSONObject()
            .put(KEY_ID, id)
            .put(KEY_TITLE, title)
            .put(KEY_BODY, body)
            .put(KEY_WHEN_EPOCH_MS, whenEpochMs)
            .put(KEY_CHANNEL_ID, channelId)
            .put(KEY_CHANNEL_NAME, channelName)
            .put(KEY_CHANNEL_DESCRIPTION, channelDescription)
            .put(KEY_SOUND_RAW_RESOURCE, soundRawResource)
            .put(KEY_PAYLOAD, payload)
            .put(KEY_ENABLE_VIBRATION, enableVibration)
            .put(KEY_VOLUME, volume)

    fun toIntent(intent: Intent): Intent =
        intent
            .putExtra(KEY_ID, id)
            .putExtra(KEY_TITLE, title)
            .putExtra(KEY_BODY, body)
            .putExtra(KEY_WHEN_EPOCH_MS, whenEpochMs)
            .putExtra(KEY_CHANNEL_ID, channelId)
            .putExtra(KEY_CHANNEL_NAME, channelName)
            .putExtra(KEY_CHANNEL_DESCRIPTION, channelDescription)
            .putExtra(KEY_SOUND_RAW_RESOURCE, soundRawResource)
            .putExtra(KEY_PAYLOAD, payload)
            .putExtra(KEY_ENABLE_VIBRATION, enableVibration)
            .putExtra(KEY_VOLUME, volume)

    companion object {
        const val KEY_ID = "alarm_id"
        const val KEY_TITLE = "alarm_title"
        const val KEY_BODY = "alarm_body"
        const val KEY_WHEN_EPOCH_MS = "alarm_when_epoch_ms"
        const val KEY_CHANNEL_ID = "alarm_channel_id"
        const val KEY_CHANNEL_NAME = "alarm_channel_name"
        const val KEY_CHANNEL_DESCRIPTION = "alarm_channel_description"
        const val KEY_SOUND_RAW_RESOURCE = "alarm_sound_raw_resource"
        const val KEY_PAYLOAD = "alarm_payload"
        const val KEY_ENABLE_VIBRATION = "alarm_enable_vibration"
        const val KEY_VOLUME = "alarm_volume"

        fun fromMap(map: Map<String, Any?>): NativeAdhanAlarm? {
            val id = (map[KEY_ID] as? Number)?.toInt() ?: return null
            val title = map[KEY_TITLE] as? String ?: return null
            val body = map[KEY_BODY] as? String ?: ""
            val whenEpochMs = (map[KEY_WHEN_EPOCH_MS] as? Number)?.toLong() ?: return null
            val channelId = map[KEY_CHANNEL_ID] as? String ?: "muslimku_adhan"
            val channelName = map[KEY_CHANNEL_NAME] as? String ?: "Muslimku Adhan"
            val channelDescription =
                map[KEY_CHANNEL_DESCRIPTION] as? String ?: "Muslimku adhan alarms"
            val enableVibration = map[KEY_ENABLE_VIBRATION] as? Boolean ?: true
            val volume = (map[KEY_VOLUME] as? Number)?.toDouble() ?: 1.0

            return NativeAdhanAlarm(
                id = id,
                title = title,
                body = body,
                whenEpochMs = whenEpochMs,
                channelId = channelId,
                channelName = channelName,
                channelDescription = channelDescription,
                soundRawResource = map[KEY_SOUND_RAW_RESOURCE] as? String,
                payload = map[KEY_PAYLOAD] as? String,
                enableVibration = enableVibration,
                volume = volume.coerceIn(0.0, 1.0),
            )
        }

        fun fromJson(json: JSONObject): NativeAdhanAlarm? =
            NativeAdhanAlarm(
                id = json.optInt(KEY_ID),
                title = json.optString(KEY_TITLE),
                body = json.optString(KEY_BODY),
                whenEpochMs = json.optLong(KEY_WHEN_EPOCH_MS),
                channelId = json.optString(KEY_CHANNEL_ID),
                channelName = json.optString(KEY_CHANNEL_NAME),
                channelDescription = json.optString(KEY_CHANNEL_DESCRIPTION),
                soundRawResource =
                    json.optString(KEY_SOUND_RAW_RESOURCE).takeIf { it.isNotBlank() },
                payload = json.optString(KEY_PAYLOAD).takeIf { it.isNotBlank() },
                enableVibration = json.optBoolean(KEY_ENABLE_VIBRATION, true),
                volume = json.optDouble(KEY_VOLUME, 1.0).coerceIn(0.0, 1.0),
            ).takeIf { alarm ->
                alarm.id != 0 && alarm.title.isNotBlank() && alarm.whenEpochMs > 0L
            }

        fun fromIntent(intent: Intent): NativeAdhanAlarm? =
            NativeAdhanAlarm(
                id = intent.getIntExtra(KEY_ID, 0),
                title = intent.getStringExtra(KEY_TITLE).orEmpty(),
                body = intent.getStringExtra(KEY_BODY).orEmpty(),
                whenEpochMs = intent.getLongExtra(KEY_WHEN_EPOCH_MS, 0L),
                channelId = intent.getStringExtra(KEY_CHANNEL_ID).orEmpty(),
                channelName = intent.getStringExtra(KEY_CHANNEL_NAME).orEmpty(),
                channelDescription =
                    intent.getStringExtra(KEY_CHANNEL_DESCRIPTION).orEmpty(),
                soundRawResource = intent.getStringExtra(KEY_SOUND_RAW_RESOURCE),
                payload = intent.getStringExtra(KEY_PAYLOAD),
                enableVibration = intent.getBooleanExtra(KEY_ENABLE_VIBRATION, true),
                volume = intent.getDoubleExtra(KEY_VOLUME, 1.0).coerceIn(0.0, 1.0),
            ).takeIf { alarm ->
                alarm.id != 0 && alarm.title.isNotBlank() && alarm.whenEpochMs > 0L
            }
    }
}
