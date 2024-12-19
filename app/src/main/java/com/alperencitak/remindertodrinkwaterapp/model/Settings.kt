package com.alperencitak.remindertodrinkwaterapp.model

data class Settings (
    val isSilentMode: Boolean = false,
    val timeInterval: TimeInterval,
    val waterQuantity: Int = 2500,
    val drinkingWater: Int = 0
)