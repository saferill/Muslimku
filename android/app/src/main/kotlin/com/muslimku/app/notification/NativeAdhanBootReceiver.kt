package com.muslimku.app.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class NativeAdhanBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        if (
            action == Intent.ACTION_BOOT_COMPLETED ||
            action == Intent.ACTION_MY_PACKAGE_REPLACED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            NativeAdhanScheduler.rescheduleFromStorage(context)
        }
    }
}
