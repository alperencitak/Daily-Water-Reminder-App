package com.alperencitak.remindertodrinkwaterapp

import android.content.Intent
import android.os.Build
import android.provider.Settings
import com.alperencitak.remindertodrinkwaterapp.notification.LegacyMigration
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dwr/native")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "readLegacySettings" -> {
                        // DataStore reads block, keep them off the UI thread.
                        Thread {
                            val settings = LegacyMigration.readLegacySettings(applicationContext)
                            LegacyMigration.cancelLegacyAlarm(applicationContext)
                            runOnUiThread { result.success(settings) }
                        }.start()
                    }
                    "adUnitId" -> result.success(BuildConfig.ADMOB_AD_UNIT_ID)
                    "openNotificationSettings" -> {
                        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        } else {
                            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                                .setData(android.net.Uri.fromParts("package", packageName, null))
                        }
                        startActivity(intent)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
