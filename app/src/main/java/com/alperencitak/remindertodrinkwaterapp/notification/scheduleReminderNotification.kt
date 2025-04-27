package com.alperencitak.remindertodrinkwaterapp.notification

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import java.util.Calendar
import java.util.Date

fun scheduleReminderNotification(context: Context, intervalMinutes: Int) {
    Log.d("WaterReminder", "scheduleReminderNotification çağrıldı. Aralık: $intervalMinutes dakika")

    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    val intent = Intent(context, NotificationReceiver::class.java)
    val pendingIntent = PendingIntent.getBroadcast(
        context,
        0,
        intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    val interval = intervalMinutes * 60 * 1000L
    val triggerTime = System.currentTimeMillis() + interval
    Log.d("WaterReminder", "Alarm ayarlanıyor. Tetikleme zamanı: ${Date(triggerTime)}, Aralık: $interval ms")

    alarmManager.setRepeating(
        AlarmManager.RTC_WAKEUP,
        triggerTime,
        interval,
        pendingIntent
    )
    Log.d("WaterReminder", "Alarm başarıyla ayarlandı")
}