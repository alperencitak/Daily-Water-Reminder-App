package com.alperencitak.remindertodrinkwaterapp.model

data class Settings (
    val isSilentMode: Boolean = false,
    val waterQuantity: Int = 2400,
    val drinkingGlass: Int = 0,
    val isScheduled: Boolean = false
)