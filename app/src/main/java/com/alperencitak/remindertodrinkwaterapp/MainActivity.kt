package com.alperencitak.remindertodrinkwaterapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.alperencitak.remindertodrinkwaterapp.ui.theme.ReminderToDrinkWaterAppTheme
import com.alperencitak.remindertodrinkwaterapp.view.MainScreen
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            ReminderToDrinkWaterAppTheme {
                MainScreen()
            }
        }
    }
}