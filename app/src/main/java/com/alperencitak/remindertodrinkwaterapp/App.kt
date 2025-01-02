package com.alperencitak.remindertodrinkwaterapp

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.annotation.RequiresApi
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
        MobileAds.initialize(this)
        createNotificationChannel()

        CoroutineScope(Dispatchers.Default).launch {
            settingsRepository.settings.collect{ setting ->
                val currentHour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
                if(currentHour in 9..23){
                    if(!setting.isScheduled){
                        val intervalMinutes = 840 / (setting.waterQuantity / 200)
                        scheduleReminderNotification(this@App, intervalMinutes)

                        settingsRepository.updateIsScheduled(true)
                    }
                }else{
                    settingsRepository.updateDrinkingGlass(0)
//                    cancelReminderNotification(this@App)
//                    settingsRepository.updateIsScheduled(false)
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