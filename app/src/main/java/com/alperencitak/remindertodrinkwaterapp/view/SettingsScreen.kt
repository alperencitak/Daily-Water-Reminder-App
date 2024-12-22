package com.alperencitak.remindertodrinkwaterapp.view

import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Checkbox
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.alperencitak.remindertodrinkwaterapp.R
import com.alperencitak.remindertodrinkwaterapp.ui.theme.LightWaterBlue
import com.alperencitak.remindertodrinkwaterapp.viewmodel.SettingsViewModel

@Composable
fun SettingsScreen(paddingValues: PaddingValues) {
    val settingsViewModel: SettingsViewModel = hiltViewModel()
    val settings by settingsViewModel.settings.collectAsState()
    var silentModeChecked by remember { mutableStateOf(settings?.isSilentMode ?: false) }
    val poppins = FontFamily(
        Font(R.font.poppins_black, FontWeight.Normal)
    )

    Box(modifier = Modifier.fillMaxSize().background(LightWaterBlue))
    Column(
        modifier = Modifier
            .padding(paddingValues)
            .fillMaxSize()
            .padding(horizontal = 16.dp, vertical = 32.dp)
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 16.dp)
                .clip(RoundedCornerShape(16.dp)),
            colors = CardDefaults.cardColors(
                containerColor = Color.White
            )
        ) {
            Column(
                modifier = Modifier.padding(horizontal = 14.dp, vertical = 16.dp)
            ){
                var kg by remember { mutableStateOf("") }
                var perKgOfWater by remember { mutableIntStateOf(30) }
                var selectedCheckbox by remember { mutableIntStateOf(-1) }
                var text by remember { mutableStateOf("") }
                Text(
                    text = "Calculate your daily water needs",
                    fontSize = 21.sp,
                    fontFamily = poppins
                )
                HorizontalDivider(
                    color = Color.Gray,
                    thickness = 1.dp,
                    modifier = Modifier.padding(vertical = 16.dp)
                )
                Row (
                    modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ){
                    Text(
                        text = "Weight:",
                        fontSize = 18.sp,
                        fontFamily = poppins,
                        modifier = Modifier.padding(end = 16.dp)
                    )
                    OutlinedTextField(
                        modifier = Modifier.width(108.dp),
                        value = kg,
                        onValueChange = { kg = it },
                        label = { Text(text = "KG", fontFamily = poppins) },
                        singleLine = true,
                        shape = RoundedCornerShape(8.dp),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                    )
                }
                Text(
                    text = "Select your daily activity level:",
                    fontSize = 18.sp,
                    fontFamily = poppins,
                    modifier = Modifier.padding(vertical = 6.dp)
                )
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(
                        checked = selectedCheckbox == 3,
                        onCheckedChange = {
                            selectedCheckbox = 3
                            perKgOfWater = 36
                        }
                    )
                    Text(
                        text = "I do heavy sports",
                        fontSize = 17.sp,
                        fontFamily = poppins,
                        modifier = Modifier.padding(vertical = 6.dp)
                    )
                }
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(
                        checked = selectedCheckbox == 2,
                        onCheckedChange = {
                            selectedCheckbox = 2
                            perKgOfWater = 34
                        }
                    )
                    Text(
                        text = "I do light sports",
                        fontSize = 17.sp,
                        fontFamily = poppins,
                        modifier = Modifier.padding(vertical = 6.dp)
                    )
                }
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(
                        checked = selectedCheckbox == 1,
                        onCheckedChange = {
                            selectedCheckbox =1
                            perKgOfWater = 32
                        }
                    )
                    Text(
                        text = "I move a lot during the day",
                        fontSize = 17.sp,
                        fontFamily = poppins,
                        modifier = Modifier.padding(vertical = 6.dp)
                    )
                }
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Checkbox(
                        checked = selectedCheckbox == 0,
                        onCheckedChange = {
                            selectedCheckbox = 0
                            perKgOfWater = 30
                        }
                    )
                    Text(
                        text = "I move little during the day",
                        fontSize = 17.sp,
                        fontFamily = poppins,
                        modifier = Modifier.padding(vertical = 6.dp)
                    )
                }
                FilledTonalButton(
                    modifier = Modifier.padding(vertical = 6.dp).align(Alignment.CenterHorizontally),
                    onClick = {
                        text = if( kg.isNotEmpty() && kg.toInt() in 20..200){
                            if(selectedCheckbox != -1){
                                "${kg.toInt() * perKgOfWater} ml/day"
                            }else{
                                "Choose one activity!"
                            }
                        }else{
                            "Enter a valid weight!"
                        }
                    }
                ) {
                    Text(
                        text = "Calculate",
                        fontSize = 17.sp,
                        fontFamily = poppins
                    )
                }
                Text(
                    text = text,
                    fontSize = 20.sp,
                    fontFamily = poppins,
                    modifier = Modifier.align(Alignment.CenterHorizontally).padding(top = 4.dp)
                )
            }
        }
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(32.dp))
                .padding(top = 16.dp),
            colors = CardDefaults.cardColors(
                containerColor = Color.White
            )
        ){
            Column(
                modifier = Modifier.padding(horizontal = 14.dp, vertical = 16.dp)
            ){
                var value by remember { mutableStateOf("") }
                var isError by remember { mutableStateOf(false) }
                var showTick by remember { mutableStateOf(false) }
                Text(
                    text = "Manually set the amount of water per day",
                    fontSize = 21.sp,
                    fontFamily = poppins
                )
                HorizontalDivider(
                    color = Color.Gray,
                    thickness = 1.dp,
                    modifier = Modifier.padding(vertical = 16.dp)
                )
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedTextField(
                        modifier = Modifier.width(144.dp),
                        value = value,
                        onValueChange = {
                            value = it
                            isError = false
                        },
                        label = { Text(text = "Enter value", fontFamily = poppins) },
                        singleLine = true,
                        shape = RoundedCornerShape(8.dp),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        colors = TextFieldDefaults.colors(
                            focusedIndicatorColor = if (isError) Color.Red else Color.Gray,
                            unfocusedIndicatorColor = if (isError) Color.Red else Color.Gray,
                            focusedContainerColor = Color.White,
                            unfocusedContainerColor = Color.White,
                            focusedLabelColor = if (isError) Color.Red else Color.DarkGray,
                            unfocusedLabelColor = if (isError) Color.Red else Color.DarkGray
                        )
                    )
                    FilledTonalButton(
                        modifier = Modifier.padding(vertical = 6.dp, horizontal = 10.dp),
                        onClick = {
                            if( value.isNotEmpty() && value.toInt() in 900..7200){
                                settingsViewModel.updateWaterQuantity(value.toInt())
                                showTick = true
                                value = ""
                            }else{
                                isError = true
                            }
                        }
                    ) {
                        Text(
                            text = "SET",
                            fontSize = 16.sp,
                            fontFamily = poppins
                        )
                    }
                    if(showTick){
                        Icon(
                            imageVector = Icons.Default.Check,
                            contentDescription = "Tick Icon",
                            tint = Color.Green
                        )
                    }
                }
            }
        }
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(32.dp))
                .padding(top = 16.dp),
            colors = CardDefaults.cardColors(
                containerColor = Color.White
            )
        ) {

            settings?.let {
                silentModeChecked = it.isSilentMode
            }

            Row(
                modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp, horizontal = 16.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "MUTE NOTIFICATIONS",
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp,
                    fontFamily = poppins,
                    color = Color.Black,
                    modifier = Modifier.padding(start = 12.dp)
                )
                Switch(
                    modifier = Modifier.padding(end = 12.dp),
                    checked = silentModeChecked,
                    onCheckedChange = {
                        silentModeChecked = it
                        settingsViewModel.toggleSilentMode()
                    },
                    thumbContent = {
                        Icon(
                            imageVector = if (silentModeChecked) Icons.Default.Check else Icons.Default.Clear,
                            contentDescription = "Check Icon",
                            modifier = Modifier.size(22.dp)
                        )
                    }
                )
            }
        }
    }
}