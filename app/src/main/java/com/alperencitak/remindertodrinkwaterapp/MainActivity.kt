package com.alperencitak.remindertodrinkwaterapp

import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.annotation.RequiresApi
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.alperencitak.remindertodrinkwaterapp.ui.theme.ReminderToDrinkWaterAppTheme
import com.alperencitak.remindertodrinkwaterapp.ui.theme.WaterBlue
import com.alperencitak.remindertodrinkwaterapp.view.NavScreen
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            ReminderToDrinkWaterAppTheme {
                requestNotificationPermission()
                ScaffoldWithNavBar()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    private fun requestNotificationPermission(){
        if(ContextCompat.checkSelfPermission(this, android.Manifest.permission.POST_NOTIFICATIONS)
            != PackageManager.PERMISSION_GRANTED){
            ActivityCompat.requestPermissions(
                this,
                arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                101
            )
        }
    }
}

@Composable
fun ScaffoldWithNavBar(){
    val navController = rememberNavController()
    val currentRoute = navController.currentBackStackEntryAsState().value?.destination?.route
    Scaffold(
        bottomBar = {
            NavigationBar(
                modifier = Modifier.clip(RoundedCornerShape(topEnd = 48.dp, topStart = 48.dp)),
                containerColor = WaterBlue,
                tonalElevation = 8.dp
            ){
                NavigationBarItem(
                    selected = currentRoute == "main",
                    onClick = {
                        if(currentRoute != "main"){
                            navController.navigate("main")
                        }
                    },
                    icon = { Icon(painterResource(R.drawable.water), contentDescription = "Water Icon") },
                    label = { Text(text = "Home", fontSize = 16.sp) }
                )
                NavigationBarItem(
                    selected = currentRoute == "settings",
                    onClick = {
                        if(currentRoute != "settings"){
                            navController.navigate("settings")
                        }
                    },
                    icon = { Icon(painterResource(R.drawable.settings), contentDescription = "Settings Icon") },
                    label = { Text(text = "Settings", fontSize = 16.sp) }
                )
            }
        }
    ) { paddingValues ->
        NavScreen(navController, paddingValues)
    }
}