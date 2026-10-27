package com.alperencitak.remindertodrinkwaterapp.notification

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.preferencesDataStoreFile
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking

/** One-time bridge from the native (Jetpack Compose) version of the app. */
object LegacyMigration {

    /** Returns the settings saved by the native app, or null if there are none. */
    fun readLegacySettings(context: Context): Map<String, Any>? {
        val file = context.preferencesDataStoreFile("settings")
        if (!file.exists()) return null
        return try {
            val store = PreferenceDataStoreFactory.create { file }
            val prefs = runBlocking { store.data.first() }
            buildMap {
                prefs[intPreferencesKey("water_quantity")]?.let { put("waterQuantity", it) }
                prefs[intPreferencesKey("drinking_glass")]?.let { put("drinkingGlass", it) }
                prefs[booleanPreferencesKey("silent_mode")]?.let { put("silentMode", it) }
            }
        } catch (e: Exception) {
            null
        }
    }

    fun cancelLegacyAlarm(context: Context) {
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            Intent(context, NotificationReceiver::class.java),
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        ) ?: return
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
    }
}
