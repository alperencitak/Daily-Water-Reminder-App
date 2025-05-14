package com.alperencitak.remindertodrinkwaterapp.view

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
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
import com.alperencitak.remindertodrinkwaterapp.component.BannerAdView
import com.alperencitak.remindertodrinkwaterapp.viewmodel.SettingsViewModel

@Composable
fun MainScreen(paddingValues: PaddingValues) {

    val settingsViewModel: SettingsViewModel = hiltViewModel()
    val settings by settingsViewModel.settings.collectAsState()

    var waterQuantity by remember { mutableIntStateOf(settings?.waterQuantity ?: 2400) }
    var drinkingGlass by remember { mutableIntStateOf(settings?.drinkingGlass ?: 0) }
    var goalGLass by remember { mutableIntStateOf(waterQuantity / 200) }
    var drinkingWaterQuantity by remember { mutableIntStateOf(drinkingGlass*200) }
    var intervalMinutes by remember { mutableIntStateOf(840 / goalGLass) }

    val nunito = FontFamily( Font(R.font.nunito_black, FontWeight.Normal) )

    val bobMap = mapOf(
        listOf(
            stringResource(R.string.bob_lol), stringResource(R.string.bob_lol2),
            stringResource(R.string.bob_lol3)
        ) to R.drawable.bob_lol,
        listOf(
            stringResource(R.string.bob_angel), stringResource(R.string.bob_angel2),
            stringResource(R.string.bob_angel3)
        ) to R.drawable.bob_angel,
        listOf(
            stringResource(R.string.bob_surprise), stringResource(R.string.bob_surprise2),
            stringResource(R.string.bob_surprise3)
        ) to R.drawable.bob_surprise,
        listOf(
            stringResource(R.string.bob_cry), stringResource(R.string.bob_cry2),
            stringResource(R.string.bob_cry3)
        ) to R.drawable.bob_cry,
        listOf(
            stringResource(R.string.bob_anime), stringResource(R.string.bob_anime2),
            stringResource(R.string.bob_anime3)
        ) to R.drawable.bob_anime,
        listOf(
            stringResource(R.string.bob_crazy), stringResource(R.string.bob_crazy2),
            stringResource(R.string.bob_crazy3)
        ) to R.drawable.bob_crazy,
        listOf(
            stringResource(R.string.bob_love), stringResource(R.string.bob_love2),
            stringResource(R.string.bob_love3)
        ) to R.drawable.bob_love,
        listOf(
            stringResource(R.string.bob_neutral), stringResource(R.string.bob_neutral2),
            stringResource(R.string.bob_neutral3)
        ) to R.drawable.bob_neutral,
        listOf(
            stringResource(R.string.bob_sleep), stringResource(R.string.bob_sleep2),
            stringResource(R.string.bob_sleep3)
        ) to R.drawable.bob_sleep
    )
    val bobEntry = remember { bobMap.entries.random() }
    val bobEntryRandomValue = remember { bobEntry.value }
    val bobEntryRandomKey = remember { bobEntry.key.random() }

    Box(modifier = Modifier.fillMaxSize()) {

        Image(
            painter = painterResource(id = R.drawable.bg3),
            contentDescription = "Background Image",
            modifier = Modifier
                .matchParentSize()
                .alpha(0.85f),
            contentScale = ContentScale.Crop
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(bottom = 64.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            BannerAdView(Modifier.fillMaxWidth())

            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 16.dp),
                elevation = CardDefaults.cardElevation(8.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.9f)
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceAround
                ) {
                    Image(
                        painter = painterResource(bobEntryRandomValue),
                        contentDescription = "Bob Gif",
                        modifier = Modifier
                            .size(85.dp)
                            .clip(RoundedCornerShape(12.dp)),
                        contentScale = ContentScale.Fit
                    )
                    Text(
                        text = bobEntryRandomKey,
                        fontSize = 18.sp,
                        fontFamily = nunito,
                        modifier = Modifier.padding(start = 16.dp),
                        color = MaterialTheme.colorScheme.onSurface
                    )
                }
            }

            Card(
                modifier = Modifier
                    .padding(vertical = 24.dp, horizontal = 32.dp)
                    .fillMaxWidth(),
                elevation = CardDefaults.cardElevation(4.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.9f)
                )
            ) {
                Row(
                    modifier = Modifier
                        .padding(16.dp)
                        .fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    IconButton(
                        onClick = {
                            if (drinkingGlass > 0) {
                                settingsViewModel.updateDrinkingGlass(drinkingGlass - 1)
                            }
                        },
                        modifier = Modifier
                            .size(56.dp)
                            .clip(CircleShape)
                            .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.1f))
                    ) {
                        Image(
                            painter = painterResource(id = R.drawable.decrease_glass),
                            contentDescription = "Decrease Glass Icon",
                            contentScale = ContentScale.Fit,
                            modifier = Modifier.size(48.dp)
                        )
                    }

                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "${drinkingWaterQuantity}ml",
                            fontWeight = FontWeight.Bold,
                            fontSize = 24.sp,
                            color = MaterialTheme.colorScheme.onPrimaryContainer,
                            fontFamily = nunito
                        )
                        Text(
                            text = "/ ${waterQuantity}ml",
                            fontSize = 16.sp,
                            color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.7f),
                            fontFamily = nunito
                        )
                    }

                    IconButton(
                        onClick = {
                            if (drinkingGlass < goalGLass) {
                                settingsViewModel.updateDrinkingGlass(drinkingGlass + 1)
                            } else if(drinkingGlass == goalGLass) {
                                drinkingWaterQuantity = waterQuantity
                            }
                        },
                        modifier = Modifier
                            .size(56.dp)
                            .clip(CircleShape)
                            .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.1f))
                    ) {
                        Image(
                            painter = painterResource(id = R.drawable.increase_glass),
                            contentDescription = "Increase Glass Icon",
                            contentScale = ContentScale.Fit,
                            modifier = Modifier.size(48.dp)
                        )
                    }
                }
            }

            Card(
                modifier = Modifier
                    .padding(horizontal = 24.dp)
                    .fillMaxWidth(),
                elevation = CardDefaults.cardElevation(4.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.9f)
                )
            ) {
                LazyVerticalGrid(
                    columns = GridCells.Adaptive(minSize = 52.dp),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                    horizontalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    items(goalGLass) { index ->
                        val alpha = if (index + 1 > drinkingGlass) 0.5f else 1f
                        Image(
                            painter = painterResource(id = R.drawable.glassofwater),
                            contentDescription = "${index+1}.Glass Icon",
                            modifier = Modifier
                                .size(52.dp)
                                .alpha(alpha)
                                .clip(RoundedCornerShape(8.dp)),
                            contentScale = ContentScale.Fit
                        )
                    }
                }
            }
        }
    }

    settings?.let {
        waterQuantity = it.waterQuantity
        goalGLass = waterQuantity / 200
        intervalMinutes = 840 / goalGLass
        drinkingGlass = it.drinkingGlass
        drinkingWaterQuantity = if(drinkingGlass==goalGLass) waterQuantity else drinkingGlass*200
    }
}