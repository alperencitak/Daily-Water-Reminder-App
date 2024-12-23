package com.alperencitak.remindertodrinkwaterapp.view

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.alperencitak.remindertodrinkwaterapp.R
import com.alperencitak.remindertodrinkwaterapp.viewmodel.SettingsViewModel
import java.util.Calendar

@Composable
fun MainScreen(paddingValues: PaddingValues) {
    val settingsViewModel: SettingsViewModel = hiltViewModel()
    val settings by settingsViewModel.settings.collectAsState()
    var silentModeChecked by remember { mutableStateOf(settings?.isSilentMode ?: false) }
    var waterQuantity by remember { mutableIntStateOf(settings?.waterQuantity ?: 2400) }
    var goalGLass by remember { mutableIntStateOf(waterQuantity / 200) }
    var intervalMinutes by remember { mutableIntStateOf(840 / goalGLass) }
    val currentHour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
    val currentMinute = Calendar.getInstance().get(Calendar.MINUTE)
    var drinkingGlass by remember { mutableIntStateOf(((currentHour - 9) * 60) + currentMinute / intervalMinutes) }

    val bobMap = mapOf(
        stringResource(R.string.bob_lol) to R.drawable.bob_lol,
        stringResource(R.string.bob_angel) to R.drawable.bob_angel,
        stringResource(R.string.bob_surprise) to R.drawable.bob_surprise,
        stringResource(R.string.bob_cry) to R.drawable.bob_cry,
        stringResource(R.string.bob_anime) to R.drawable.bob_anime,
        stringResource(R.string.bob_crazy) to R.drawable.bob_crazy,
        stringResource(R.string.bob_love) to R.drawable.bob_love,
        stringResource(R.string.bob_neutral) to R.drawable.bob_neutral,
        stringResource(R.string.bob_sleep) to R.drawable.bob_sleep
    )

    val nunito = FontFamily(
        Font(R.font.nunito_black, FontWeight.Normal)
    )

    Box(modifier = Modifier.fillMaxSize()) {
        Image(
            painter = painterResource(id = R.drawable.bg3),
            contentDescription = "Background Image",
            modifier = Modifier.matchParentSize(),
            contentScale = ContentScale.Crop
        )
    }
    Row(
        modifier = Modifier.fillMaxWidth().padding(vertical = 64.dp, horizontal = 32.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        val bobEntry = bobMap.entries.random()
        Image(
            painter = painterResource(bobEntry.value),
            contentDescription = "Cry Bob Gif",
            modifier = Modifier
                .size(75.dp),
            contentScale = ContentScale.Fit
        )
        Text(
            text = bobEntry.key,
            fontSize = 17.sp,
            fontFamily = nunito,
            modifier = Modifier.padding(start = 16.dp)
        )
    }
    Column(
        modifier = Modifier
            .padding(paddingValues)
            .fillMaxSize()
            .padding(horizontal = 64.dp, vertical = 128.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "${drinkingGlass * 200}ml / ${waterQuantity}ml",
            fontWeight = FontWeight.Bold,
            fontSize = 18.sp,
            color = Color.Black,
            fontFamily = nunito,
            modifier = Modifier.padding(bottom = 12.dp)
        )
        LazyVerticalGrid(
            columns = GridCells.Adaptive(minSize = 48.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            items(goalGLass) { index ->
                val alpha = if (index + 1 > drinkingGlass) 0.5f else 1f
                Image(
                    painter = painterResource(id = R.drawable.glassofwater),
                    contentDescription = "Glass Icon",
                    modifier = Modifier
                        .width(48.dp)
                        .height(48.dp)
                        .alpha(alpha),
                    contentScale = ContentScale.Fit
                )
            }
        }
        settings?.let {
            silentModeChecked = it.isSilentMode
            waterQuantity = it.waterQuantity
            goalGLass = waterQuantity / 200
            intervalMinutes = 840 / goalGLass
            drinkingGlass = (((currentHour - 9) * 60) + currentMinute) / intervalMinutes
        }
    }
}