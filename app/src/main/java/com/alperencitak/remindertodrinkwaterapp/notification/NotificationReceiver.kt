package com.alperencitak.remindertodrinkwaterapp.notification

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import android.content.BroadcastReceiver
import com.alperencitak.remindertodrinkwaterapp.R
import java.util.Locale

@SuppressLint("RestrictedApi")
class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val notification = NotificationCompat.Builder(context, "reminder_notifications")
            .setContentTitle(getContentTitle())
            .setContentText(getContentText())
            .setSmallIcon(R.drawable.glassofwater)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        val notificationManager = NotificationManagerCompat.from(context)
        
        if (ActivityCompat.checkSelfPermission(context,Manifest.permission.POST_NOTIFICATIONS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        notificationManager.notify(1, notification)
    }

    private fun getContentTitle() : String{
        return if (Locale.getDefault().language == "tr"){
            "Su İçme Zamanı!"
        }else{
            "Time to Drink Water!"
        }
    }

    private fun getContentText(): String {
        val messages = if (Locale.getDefault().toLanguageTag().startsWith("tr")) {
            listOf(
                "Su içmeyi unutma.",
                "Vücudunu bir bardak su ile ödüllendir.",
                "Bob için bir bardak su iç.",
                "Boğazın kurudu, git su iç.",
                "Bir bardak su içeceğini duydum.",
                "Lütfen bana bir bardak su ver.",
                "Bence 10 saniyede su içemezsin.",
                "Su niye içmiyon?",
                "Beni yalvartma su iç"
            )
        } else {
            listOf(
                "Get up and drink 1 glass of water.",
                "Reward your body with a glass of water.",
                "Drink a glass of water for Bob.",
                "Your throat is dry, go drink water.",
                "I heard you were going to drink a glass of water.",
                "Please give me a glass of water.",
                "I don't think you can drink water in 10 seconds.",
                "Why don't you drink water?",
                "Don't make me beg for water"
            )
        }
        return messages.shuffled().first()
    }

}