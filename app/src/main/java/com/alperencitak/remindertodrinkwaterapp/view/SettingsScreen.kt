package com.alperencitak.remindertodrinkwaterapp.view

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import com.alperencitak.remindertodrinkwaterapp.R
import com.alperencitak.remindertodrinkwaterapp.ui.theme.WaterBlue
import com.alperencitak.remindertodrinkwaterapp.viewmodel.SettingsViewModel
import java.util.Calendar

@Composable
fun SettingsScreen(navController: NavController) {
    val settingsViewModel: SettingsViewModel = hiltViewModel()
    val settings by settingsViewModel.settings.collectAsState()
    var silentModeChecked by remember { mutableStateOf(settings?.isSilentMode ?: false) }
    var waterQuantity by remember { mutableIntStateOf(settings?.waterQuantity ?: 2400) }


    Scaffold (
        content = { paddingValues ->
            Box(modifier = Modifier.fillMaxSize()){
                Image(
                    painter = painterResource(id = R.drawable.bg3),
                    contentDescription = "Background Image",
                    modifier = Modifier.matchParentSize(),
                    contentScale = ContentScale.Crop
                )
            }
            Column(
                modifier = Modifier.padding(paddingValues).fillMaxSize().padding(horizontal = 64.dp, vertical = 128.dp),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Row(
                    modifier = Modifier.padding(top = 16.dp, bottom = 72.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Switch(
                        checked = silentModeChecked,
                        onCheckedChange = {
                            silentModeChecked = it
                            settingsViewModel.toggleSilentMode()
                        },
                        thumbContent = {
                            Icon(
                                painterResource(R.drawable.moon),
                                contentDescription = "Moon Icon",
                                modifier = Modifier.size(22.dp)
                            )
                        }
                    )
                    Text(
                        text = "SILENT MODE",
                        fontWeight = FontWeight.Bold,
                        fontSize = 18.sp,
                        color = Color.Black,
                        modifier = Modifier.padding(start = 8.dp)
                    )
                }
            }
        },
        bottomBar = {
            NavigationBar(
                modifier = Modifier.clip(RoundedCornerShape(topEnd = 48.dp, topStart = 48.dp)),
                containerColor = WaterBlue,
                tonalElevation = 8.dp
            ){
                NavigationBarItem(
                    selected = false,
                    onClick = { navController.navigate("main") },
                    icon = { Icon(painterResource(R.drawable.water), contentDescription = "Water Icon") },
                    label = { Text(text = "Home", fontSize = 16.sp) }
                )
                NavigationBarItem(
                    selected = true,
                    onClick = {  },
                    icon = { Icon(painterResource(R.drawable.settings), contentDescription = "Settings Icon") },
                    label = { Text(text = "Settings", fontSize = 16.sp) }
                )
            }
        }
    )
}