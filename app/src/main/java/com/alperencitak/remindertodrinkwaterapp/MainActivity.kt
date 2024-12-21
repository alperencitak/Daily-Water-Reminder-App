package com.alperencitak.remindertodrinkwaterapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.painterResource
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.alperencitak.remindertodrinkwaterapp.ui.theme.ReminderToDrinkWaterAppTheme
import com.alperencitak.remindertodrinkwaterapp.view.MainScreen
import com.alperencitak.remindertodrinkwaterapp.view.SettingsScreen
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            ReminderToDrinkWaterAppTheme {
                NavScreen()
            }
        }
    }
}

@Composable
fun NavScreen(){
    val navController = rememberNavController()
    Column(modifier = Modifier.fillMaxSize()) {
        NavHost(navController = navController, startDestination = "main"){
            composable("main"){ MainScreen(navController) }
            composable("settings"){ SettingsScreen(navController) }
        }
    }
}