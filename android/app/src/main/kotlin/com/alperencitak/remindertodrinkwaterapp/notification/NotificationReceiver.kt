package com.alperencitak.remindertodrinkwaterapp.notification

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Receiver name used by the native app's repeating AlarmManager alarm. Reminders are now
 * scheduled from Flutter, so if that old alarm still fires we just cancel it.
 */
class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        LegacyMigration.cancelLegacyAlarm(context)
    }
}
