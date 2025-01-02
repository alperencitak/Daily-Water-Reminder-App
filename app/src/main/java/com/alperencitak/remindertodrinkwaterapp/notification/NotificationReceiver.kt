package com.alperencitak.remindertodrinkwaterapp.notification

import android.Manifest
import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import android.content.BroadcastReceiver
import com.alperencitak.remindertodrinkwaterapp.MainActivity
import com.alperencitak.remindertodrinkwaterapp.R
import java.util.Calendar
import java.util.Locale

@SuppressLint("RestrictedApi")
class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {

        val calendar = Calendar.getInstance()
        val currentHour = calendar.get(Calendar.HOUR_OF_DAY)

        if (currentHour !in 9..23) {
            return
        }

        val notificationIntent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            notificationIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, "reminder_notifications")
            .setContentTitle(getContentTitle())
            .setContentText(getContentText())
            .setSmallIcon(R.drawable.glassofwater)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
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
                "Su niye içmiyorsun?",
                "Dostum, kuraklık kapıda! Hemen bir bardak su iç!",
                "Bugün litreleri devirmedin mi? Hadi bakalım!",
                "Bir bardak su, zihnini berraklaştırır. Denemeye ne dersin?",
                "Bugün yeterince su içtin mi? Hadi bir bardak daha!",
                "Hadi su iç, belki suyun tadı bugün daha güzeldir.",
                "Suyunu iç, şaka yapmıyorum!",
                "Bir bardak su zamanı! Şimdi içmeye ne dersin?",
                "Hadi dostum, suyun sana 'beni iç' diyor!",
                "Bugün su içmeden günü kapatmayı mı planlıyorsun? Şaka mı bu?",
                "Bir bardak su mu? Çok zor bir görev değil, hadi başla!",
                "Suyunu iç, sonra teşekkür edebilirsin!",
                "Su içmek ücretsizdir, kaçırma fırsatı!",
                "Bugün su içtin mi? Yoksa hep mi erteliyorsun?",
                "Su iç! Çünkü bu bildirim başka bir şey söylemeyecek!",
                "Düşündün ama su içmedin, bravo! Kendine nasıl iyi bakıyorsun öyle?",
                "Bu bildirim su içmeden gitmeyecek, benden söylemesi.",
                "Bugün su içmek için mükemmel bir gün, yarın zaten geç kalmış olursun.",
                "Su iç! Çünkü senin gibi harika bir insan bunu hak ediyor.",
                "Suyu içmek için mi bekliyorsun? Efsane bir an mı yaratacağız?",
                "Hayat zor, biliyorum. Ama bir bardak su içmek bu kadar da zor olmamalı.",
                "Kusura bakma, bu bildirim seni bu kadar rahatsız etmezdi... Eğer su içseydin.",
                "Bu kadar güçlüysen, bir bardak su içmeyi de başarabilirsin!",
                "Telefonun kadar vücudun da şarj edilmeye ihtiyaç duyuyor. Su iç!",
                "Su içmek için bu kadar bildirim göndermemiz mi gerekiyordu? Hadi ama!"
            )
        } else {
            listOf(
                "Don't forget to drink water.",
                "Reward your body with a glass of water.",
                "Drink a glass of water for Bob.",
                "Your throat is dry, go drink some water.",
                "I heard you're going to drink a glass of water.",
                "Please give me a glass of water.",
                "I bet you can't drink water in 10 seconds.",
                "Why aren't you drinking water?",
                "Dude, drought is coming! Go drink a glass of water now!",
                "Didn't you hit your water goals today? Let's go!",
                "A glass of water clears your mind. How about trying it?",
                "Have you drunk enough water today? Let's have another glass!",
                "Go drink some water, maybe it tastes better today.",
                "Drink your water, I'm not kidding!",
                "It's time for a glass of water! How about drinking now?",
                "Come on, your water is calling 'Drink me!'",
                "Are you planning to end the day without drinking water? Is this a joke?",
                "A glass of water? Not such a hard task, come on!",
                "Drink your water, you can thank me later!",
                "Drinking water is free, don't miss the chance!",
                "Did you drink water today? Or are you always postponing it?",
                "Drink water! Because this notification won’t say anything else!",
                "You thought about it but didn't drink, bravo! How do you take care of yourself like that?",
                "This notification won't go away without drinking water, just so you know.",
                "Today is the perfect day to drink water, you'll be late tomorrow anyway.",
                "Drink water! Because a great person like you deserves it.",
                "Are you waiting to drink your water? Are we creating an epic moment?",
                "Life is hard, I know. But drinking a glass of water shouldn't be that difficult.",
                "Sorry, this notification wouldn’t bother you this much... if you had drunk water.",
                "If you're this strong, you can also manage to drink a glass of water!",
                "Your body needs charging just like your phone. Drink water!",
                "Did we have to send this many notifications for you to drink water? Come on!"
            )
        }
        return messages.shuffled().first()
    }

}