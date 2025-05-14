package com.alperencitak.remindertodrinkwaterapp.view

import android.content.Intent
import android.net.Uri
import android.widget.Space
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
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.expandVertically
import androidx.compose.animation.shrinkVertically
import androidx.compose.animation.expandHorizontally
import androidx.compose.animation.shrinkHorizontally
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.calculateStartPadding
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.graphics.Brush
import com.alperencitak.remindertodrinkwaterapp.ui.theme.WaterBlue

@Composable
fun SettingsScreen(paddingValues: PaddingValues) {
    val settingsViewModel: SettingsViewModel = hiltViewModel()
    val nunito = FontFamily(Font(R.font.nunito_black, FontWeight.Normal))
    val context = LocalContext.current
    val url = "https://icons8.com"

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                brush = Brush.verticalGradient(
                    colors = listOf(
                        LightWaterBlue,
                        WaterBlue
                    )
                )
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp)
                .verticalScroll(rememberScrollState()),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Spacer(modifier = Modifier.height(32.dp))
            ElevatedCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 16.dp),
                shape = RoundedCornerShape(24.dp),
                elevation = CardDefaults.elevatedCardElevation(defaultElevation = 6.dp),
                colors = CardDefaults.elevatedCardColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            ) {
                Column(
                    modifier = Modifier.padding(20.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    var kg by remember { mutableStateOf("") }
                    var perKgOfWater by remember { mutableIntStateOf(30) }
                    var selectedCheckbox by remember { mutableIntStateOf(-1) }
                    var text by remember { mutableStateOf("") }

                    Text(
                        text = stringResource(R.string.calculate_card_title),
                        fontSize = 24.sp,
                        fontFamily = nunito,
                        color = MaterialTheme.colorScheme.primary
                    )

                    HorizontalDivider(
                        color = MaterialTheme.colorScheme.primary.copy(alpha = 0.2f),
                        thickness = 2.dp
                    )

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        Text(
                            text = "${stringResource(R.string.weight)}:",
                            fontSize = 18.sp,
                            fontFamily = nunito
                        )
                        OutlinedTextField(
                            modifier = Modifier
                                .width(120.dp)
                                .semantics { contentDescription = "KG text field" },
                            value = kg,
                            onValueChange = {
                                if(it.matches(Regex("^\\d*\$")) && it.length <= 3) {
                                    kg = it
                                }
                            },
                            label = { Text(text = "KG", fontFamily = nunito) },
                            singleLine = true,
                            shape = RoundedCornerShape(12.dp),
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            colors = TextFieldDefaults.colors(
                                focusedContainerColor = MaterialTheme.colorScheme.surface,
                                unfocusedContainerColor = MaterialTheme.colorScheme.surface,
                                focusedIndicatorColor = MaterialTheme.colorScheme.primary,
                                unfocusedIndicatorColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.5f)
                            )
                        )
                    }

                    Text(
                        text = stringResource(R.string.select_daily_activity),
                        fontSize = 18.sp,
                        fontFamily = nunito,
                        color = MaterialTheme.colorScheme.onSurface
                    )

                    Column(
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        ActivityCheckboxItem(
                            isSelected = selectedCheckbox == 3,
                            onSelect = { selectedCheckbox = 3; perKgOfWater = 36 },
                            text = stringResource(R.string.activity_4),
                            contentDesc = "1. Checkbox",
                            nunito = nunito
                        )
                        ActivityCheckboxItem(
                            isSelected = selectedCheckbox == 2,
                            onSelect = { selectedCheckbox = 2; perKgOfWater = 34 },
                            text = stringResource(R.string.activity_3),
                            contentDesc = "2. Checkbox",
                            nunito = nunito
                        )
                        ActivityCheckboxItem(
                            isSelected = selectedCheckbox == 1,
                            onSelect = { selectedCheckbox = 1; perKgOfWater = 32 },
                            text = stringResource(R.string.activity_2),
                            contentDesc = "3. Checkbox",
                            nunito = nunito
                        )
                        ActivityCheckboxItem(
                            isSelected = selectedCheckbox == 0,
                            onSelect = { selectedCheckbox = 0; perKgOfWater = 30 },
                            text = stringResource(R.string.activity_1),
                            contentDesc = "4. Checkbox",
                            nunito = nunito
                        )
                    }

                    val chooseActivityText = stringResource(R.string.choose_one_activity)
                    val enterValidWeight = stringResource(R.string.enter_valid_weight)

                    Button(
                        onClick = {
                            text = if(kg.isNotEmpty() && kg.toInt() in 30..170) {
                                if(selectedCheckbox != -1) {
                                    "${kg.toInt() * perKgOfWater} ml/day"
                                } else {
                                    chooseActivityText
                                }
                            } else {
                                enterValidWeight
                            }
                        },
                        modifier = Modifier.align(Alignment.CenterHorizontally),
                        shape = RoundedCornerShape(16.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = MaterialTheme.colorScheme.primary
                        )
                    ) {
                        Text(
                            text = stringResource(R.string.calculate),
                            fontSize = 17.sp,
                            fontFamily = nunito,
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp)
                        )
                    }

                    AnimatedVisibility(
                        visible = text.isNotEmpty(),
                        enter = fadeIn() + expandVertically(),
                        exit = fadeOut() + shrinkVertically()
                    ) {
                        Text(
                            text = text,
                            fontSize = 22.sp,
                            fontFamily = nunito,
                            color = MaterialTheme.colorScheme.primary,
                            modifier = Modifier
                                .align(Alignment.CenterHorizontally)
                                .padding(top = 8.dp)
                        )
                    }
                }
            }

            ElevatedCard(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                elevation = CardDefaults.elevatedCardElevation(defaultElevation = 6.dp),
                colors = CardDefaults.elevatedCardColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            ) {
                Column(
                    modifier = Modifier.padding(20.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    var value by remember { mutableStateOf("") }
                    var isError by remember { mutableStateOf(false) }
                    var showTick by remember { mutableStateOf(false) }

                    Text(
                        text = stringResource(R.string.manually_set_water_quantity),
                        fontSize = 22.sp,
                        fontFamily = nunito,
                        color = MaterialTheme.colorScheme.primary
                    )

                    HorizontalDivider(
                        color = MaterialTheme.colorScheme.primary.copy(alpha = 0.2f),
                        thickness = 2.dp
                    )

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        OutlinedTextField(
                            modifier = Modifier
                                .weight(1f)
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
                            shape = RoundedCornerShape(12.dp),
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            colors = TextFieldDefaults.colors(
                                focusedContainerColor = MaterialTheme.colorScheme.surface,
                                unfocusedContainerColor = MaterialTheme.colorScheme.surface,
                                focusedIndicatorColor = if (isError) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.primary,
                                unfocusedIndicatorColor = if (isError) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.primary.copy(alpha = 0.5f)
                            ),
                            isError = isError
                        )

                        Button(
                            onClick = {
                                if(value.isNotEmpty() && value.toInt() in 900..6120) {
                                    settingsViewModel.updateWaterQuantity(value.toInt())
                                    settingsViewModel.updateIsScheduled(false)
                                    settingsViewModel.updateDrinkingGlass(0)
                                    showTick = true
                                    value = ""
                                } else {
                                    isError = true
                                }
                            },
                            shape = RoundedCornerShape(16.dp),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = MaterialTheme.colorScheme.primary
                            )
                        ) {
                            Text(
                                text = stringResource(R.string.set),
                                fontSize = 16.sp,
                                fontFamily = nunito,
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                            )
                        }

                        AnimatedVisibility(
                            visible = showTick,
                            enter = fadeIn() + expandHorizontally(),
                            exit = fadeOut() + shrinkHorizontally()
                        ) {
                            Icon(
                                imageVector = Icons.Default.Check,
                                contentDescription = "Success Icon",
                                tint = MaterialTheme.colorScheme.primary,
                                modifier = Modifier.size(24.dp)
                            )
                        }
                    }
                }
            }

            ElevatedCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .semantics { contentDescription = "Privacy & Policy Page" }
                    .clickable {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://sites.google.com/view/dwrprivacypolicy"))
                        context.startActivity(intent)
                    },
                shape = RoundedCornerShape(24.dp),
                elevation = CardDefaults.elevatedCardElevation(defaultElevation = 6.dp),
                colors = CardDefaults.elevatedCardColors(
                    containerColor = MaterialTheme.colorScheme.surface
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(20.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = stringResource(R.string.privacy_and_policy),
                        fontSize = 18.sp,
                        fontFamily = nunito,
                        color = MaterialTheme.colorScheme.primary
                    )
                    Icon(
                        imageVector = Icons.Default.ArrowForward,
                        contentDescription = "Go to Privacy Policy",
                        tint = MaterialTheme.colorScheme.primary
                    )
                }
            }

            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 8.dp),
                color = Color.Transparent
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Icons by ",
                        fontSize = 16.sp,
                        fontFamily = nunito,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.8f)
                    )
                    Text(
                        text = "Icons8",
                        fontSize = 16.sp,
                        fontFamily = nunito,
                        color = MaterialTheme.colorScheme.primary,
                        textDecoration = TextDecoration.Underline,
                        modifier = Modifier.clickable {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                            context.startActivity(intent)
                        }
                    )
                }
            }
            Spacer(modifier = Modifier.height(paddingValues.calculateBottomPadding()))
        }
    }
}

@Composable
private fun ActivityCheckboxItem(
    isSelected: Boolean,
    onSelect: () -> Unit,
    text: String,
    contentDesc: String,
    nunito: FontFamily
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .clickable { onSelect() },
        color = if (isSelected)
            MaterialTheme.colorScheme.primary.copy(alpha = 0.1f)
        else
            MaterialTheme.colorScheme.surface
    ) {
        Row(
            modifier = Modifier.padding(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Checkbox(
                checked = isSelected,
                onCheckedChange = { onSelect() },
                modifier = Modifier.semantics { contentDescription = contentDesc },
                colors = CheckboxDefaults.colors(
                    checkedColor = MaterialTheme.colorScheme.primary,
                    uncheckedColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.6f)
                )
            )
            Text(
                text = text,
                fontSize = 17.sp,
                fontFamily = nunito,
                color = MaterialTheme.colorScheme.onSurface
            )
        }
    }
}