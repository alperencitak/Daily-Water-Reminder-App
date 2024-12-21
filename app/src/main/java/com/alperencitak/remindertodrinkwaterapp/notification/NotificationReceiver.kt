package com.alperencitak.remindertodrinkwaterapp.notification

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.impl.utils.ForceStopRunnable.BroadcastReceiver
import com.alperencitak.remindertodrinkwaterapp.R

@SuppressLint("RestrictedApi")
class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val notification = NotificationCompat.Builder(context, "reminder_notifications")
            .setContentTitle("Time to Drink Water!")
            .setContentText("Don't forget to drink water!")
            .setSmallIcon(R.drawable.glassofwater)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        val notificationManager = NotificationManagerCompat.from(context)
        
        if (ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        notificationManager.notify(1, notification)
    }
}