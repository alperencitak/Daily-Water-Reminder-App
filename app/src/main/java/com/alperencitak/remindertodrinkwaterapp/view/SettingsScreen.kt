package com.alperencitak.remindertodrinkwaterapp.view

import android.content.Intent
import android.net.Uri
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Checkbox
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.alperencitak.remindertodrinkwaterapp.R
import com.alperencitak.remindertodrinkwaterapp.ui.theme.LightWaterBlue
import com.alperencitak.remindertodrinkwaterapp.viewmodel.SettingsViewModel

@Composable
fun SettingsScreen(paddingValues: PaddingValues) {
    val settingsViewModel: SettingsViewModel = hiltViewModel()
    val nunito = FontFamily(
        Font(R.font.nunito_black, FontWeight.Normal)
    )
    val context = LocalContext.current
    val url = "https://icons8.com"


    Box(modifier = Modifier.fillMaxSize().background(LightWaterBlue))
    Column(
        modifier = Modifier
            .padding(paddingValues)
            .fillMaxSize()
            .padding(horizontal = 16.dp)
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
                    text = stringResource(R.string.calculate_card_title),
                    fontSize = 21.sp,
                    fontFamily = nunito
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
                        text = "${stringResource(R.string.weight)}:",
                        fontSize = 18.sp,
                        fontFamily = nunito,
                        modifier = Modifier.padding(end = 16.dp)
                    )
                    OutlinedTextField(
                        modifier = Modifier
                            .width(108.dp)
                            .semantics { contentDescription = "KG text field" },
                        value = kg,
                        onValueChange = {
                            if(it.matches(Regex("^\\d*\$")) && it.length <= 3){
                                kg = it
                            }
                        },
                        label = { Text(text = "KG", fontFamily = nunito) },
                        singleLine = true,
                        shape = RoundedCornerShape(8.dp),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                    )
                }
                Text(
                    text = stringResource(R.string.select_daily_activity),
                    fontSize = 18.sp,
                    fontFamily = nunito,
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
                        },
                        modifier = Modifier.semantics { contentDescription = "1. Checkbox" }
                    )
                    Text(
                        text = stringResource(R.string.activity_4),
                        fontSize = 17.sp,
                        fontFamily = nunito,
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
                        },
                        modifier = Modifier.semantics { contentDescription = "2. Checkbox" }
                    )
                    Text(
                        text = stringResource(R.string.activity_3),
                        fontSize = 17.sp,
                        fontFamily = nunito,
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
                        },
                        modifier = Modifier.semantics { contentDescription = "3. Checkbox" }
                    )
                    Text(
                        text = stringResource(R.string.activity_2),
                        fontSize = 17.sp,
                        fontFamily = nunito,
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
                        },
                        modifier = Modifier.semantics { contentDescription = "4. Checkbox" }
                    )
                    Text(
                        text = stringResource(R.string.activity_1),
                        fontSize = 17.sp,
                        fontFamily = nunito,
                        modifier = Modifier.padding(vertical = 6.dp)
                    )
                }
                val chooseActivityText = stringResource(R.string.choose_one_activity)
                val enterValidWeight = stringResource(R.string.enter_valid_weight)
                FilledTonalButton(
                    modifier = Modifier.padding(vertical = 6.dp).align(Alignment.CenterHorizontally),
                    onClick = {
                        text = if( kg.isNotEmpty() && kg.toInt() in 30..170){
                            if(selectedCheckbox != -1){
                                "${kg.toInt() * perKgOfWater} ml/day"
                            }else{
                                chooseActivityText
                            }
                        }else{
                            enterValidWeight
                        }
                    }
                ) {
                    Text(
                        text = stringResource(R.string.calculate),
                        fontSize = 17.sp,
                        fontFamily = nunito
                    )
                }
                Text(
                    text = text,
                    fontSize = 20.sp,
                    fontFamily = nunito,
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
                modifier = Modifier.padding(horizontal = 14.dp, vertical = 32.dp)
            ){
                var value by remember { mutableStateOf("") }
                var isError by remember { mutableStateOf(false) }
                var showTick by remember { mutableStateOf(false) }
                Text(
                    text = stringResource(R.string.manually_set_water_quantity),
                    fontSize = 21.sp,
                    fontFamily = nunito
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
                        modifier = Modifier
                            .width(144.dp)
                            .semantics { contentDescription = "Manually set the amount of water per day text field" },
                        value = value,
                        onValueChange = {
                            if (it.matches(Regex("^\\d*\$")) && it.length <= 4) {
                                value = it
                                isError = false
                            }
                        },
                        label = { Text(text = stringResource(R.string.enter_value), fontFamily = nunito) },
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
                            if( value.isNotEmpty() && value.toInt() in 900..6120){
                                settingsViewModel.updateWaterQuantity(value.toInt())
                                settingsViewModel.updateIsScheduled(false)
                                settingsViewModel.updateDrinkingGlass(0)
                                showTick = true
                                value = ""
                            }else{
                                isError = true
                            }
                        }
                    ) {
                        Text(
                            text = stringResource(R.string.set),
                            fontSize = 16.sp,
                            fontFamily = nunito
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
                .padding(top = 16.dp)
                .semantics { contentDescription = "Privacy & Policy Page" }
                .clickable {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://sites.google.com/view/dwrprivacypolicy"))
                    context.startActivity(intent)
                },
            colors = CardDefaults.cardColors(
                containerColor = Color.White
            )
        ){
            Text(
                text = stringResource(R.string.privacy_and_policy),
                fontSize = 18.sp,
                fontFamily = nunito,
                modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp, vertical = 6.dp)
            )
        }
        Row(
            Modifier.fillMaxWidth().padding(vertical = 8.dp),
            horizontalArrangement = Arrangement.Center
        ) {
            Text(
                text = "Icons by ",
                fontSize = 16.sp,
                fontFamily = FontFamily.SansSerif
            )
            Text(
                text = "Icons8",
                fontSize = 16.sp,
                fontFamily = FontFamily.SansSerif,
                textDecoration = TextDecoration.Underline,
                modifier = Modifier.clickable {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                    context.startActivity(intent)
                }
            )
        }
    }
}