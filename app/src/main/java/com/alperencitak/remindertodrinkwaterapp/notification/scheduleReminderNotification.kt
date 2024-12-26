package com.alperencitak.remindertodrinkwaterapp.notification

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import java.util.Calendar

fun scheduleReminderNotification(context: Context, intervalMinutes: Int) {
    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    val intent = Intent(context, NotificationReceiver::class.java)
    val pendingIntent = PendingIntent.getBroadcast(
        context,
        0,
        intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    val calendar = Calendar.getInstance()
    val currentHour = calendar.get(Calendar.HOUR_OF_DAY)

    if (currentHour !in 9..23) {
        return
    }

    val interval = intervalMinutes * 60 * 1000L
    val triggerTime = System.currentTimeMillis() + interval

    alarmManager.setRepeating(
        AlarmManager.RTC_WAKEUP,
        triggerTime,
        interval,
        pendingIntent
    )
}