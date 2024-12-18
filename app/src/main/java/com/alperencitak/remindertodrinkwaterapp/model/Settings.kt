package com.alperencitak.remindertodrinkwaterapp.model

data class Settings (
    val isDarkMode: Boolean = false,
    val isSleepMode: Boolean = false,
    val timeInterval: TimeInterval,
    val waterQuantity: Float = 2.5f,
)