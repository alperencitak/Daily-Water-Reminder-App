package com.alperencitak.remindertodrinkwaterapp

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import com.alperencitak.remindertodrinkwaterapp.notification.cancelReminderNotification
import com.alperencitak.remindertodrinkwaterapp.notification.scheduleReminderNotification
import com.alperencitak.remindertodrinkwaterapp.repository.SettingsRepository
import dagger.hilt.android.HiltAndroidApp
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.Calendar
import javax.inject.Inject

@HiltAndroidApp
class App : Application() {

    @Inject
    lateinit var settingsRepository: SettingsRepository

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        CoroutineScope(Dispatchers.Default).launch {
            settingsRepository.settings.collect{ setting ->

                val currentHour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)

                if(!setting.isSilentMode || currentHour in 9..23){

                    val intervalMinutes = 840 / (setting.waterQuantity / 200)

                    scheduleReminderNotification(this@App, intervalMinutes)

                }else{
                    cancelReminderNotification(this@App)
                }

            }
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "reminder_notifications",
                "Reminder Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Reminders to drink water every 10 minutes."
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager?.createNotificationChannel(channel)
        }
    }
}