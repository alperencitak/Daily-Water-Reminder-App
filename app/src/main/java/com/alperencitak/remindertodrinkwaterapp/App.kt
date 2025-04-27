package com.alperencitak.remindertodrinkwaterapp

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import com.alperencitak.remindertodrinkwaterapp.notification.NotificationReceiver
import com.alperencitak.remindertodrinkwaterapp.notification.cancelReminderNotification
import com.alperencitak.remindertodrinkwaterapp.notification.scheduleReminderNotification
import com.alperencitak.remindertodrinkwaterapp.repository.SettingsRepository
import com.google.android.gms.ads.MobileAds
import dagger.hilt.android.HiltAndroidApp
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.Calendar
import java.util.Locale
import javax.inject.Inject

@HiltAndroidApp
class App : Application() {

    @Inject
    lateinit var settingsRepository: SettingsRepository

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate() {
        super.onCreate()
        Log.d("WaterReminder", "App.onCreate çağrıldı")
        MobileAds.initialize(this)
        createNotificationChannel()
        Log.d("WaterReminder", "Bildirim kanalı oluşturuldu")

        CoroutineScope(Dispatchers.Default).launch {
            Log.d("WaterReminder", "Settings flow'u dinleniyor")

            settingsRepository.settings.collect{ setting ->
                val currentHour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
                Log.d("WaterReminder", "Ayarlar toplandı. Şu anki saat: $currentHour, waterQuantity: ${setting.waterQuantity}")

                val isAlarmSet = PendingIntent.getBroadcast(
                    this@App,
                    0,
                    Intent(this@App, NotificationReceiver::class.java),
                    PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
                ) != null

                Log.d("WaterReminder", "Alarm zaten kurulu mu: $isAlarmSet")

                if (!isAlarmSet) {
                    val intervalMinutes = 840 / (setting.waterQuantity / 200)
                    Log.d("WaterReminder", "Alarm kurulmamış, yeni alarm ayarlanıyor. Interval: $intervalMinutes dk")
                    scheduleReminderNotification(this@App, intervalMinutes)
                }

                if(currentHour == 3){
                    Log.d("WaterReminder", "Saat 3, içilen su sıfırlanıyor")
                    settingsRepository.updateDrinkingGlass(0)
                }
            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "reminder_notifications",
                getChannelName(),
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = getChannelDescription()
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(channel)
        }
    }

    private fun getChannelName(): String {
        return if (Locale.getDefault().language == "tr") {
            "Hatırlatma Bildirimleri"
        } else {
            "Reminder Notifications"
        }
    }

    private fun getChannelDescription(): String {
        return if (Locale.getDefault().language == "tr") {
            "Günlük su içme hatırlatmaları."
        } else {
            "Daily reminders to drink water."
        }
    }

}