package com.alperencitak.remindertodrinkwaterapp.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.alperencitak.remindertodrinkwaterapp.model.Settings
import com.alperencitak.remindertodrinkwaterapp.model.TimeInterval
import com.alperencitak.remindertodrinkwaterapp.repository.SettingsRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val settingsRepository: SettingsRepository
) : ViewModel() {
    private val _settings = MutableStateFlow<Settings?>(null)
    val settings: StateFlow<Settings?> = _settings

    init {
        loadSettings()
    }

    private fun loadSettings(){
        viewModelScope.launch {
            try {
                settingsRepository.settings.collect{ settingsData ->
                    _settings.value = settingsData
                }
            }catch (e: Exception){
                e.printStackTrace()
            }
        }
    }

    fun toggleSilentMode(){
        viewModelScope.launch {
            try {
                if(_settings.value != null){
                    settingsRepository.updateSilentMode(!_settings.value!!.isSilentMode)
                    loadSettings()
                }
            }catch (e: Exception){
                e.printStackTrace()
            }
        }
    }

    fun updateTimeInterval(timeInterval: TimeInterval){
        viewModelScope.launch {
            settingsRepository.updateTimeInterval(timeInterval)
            loadSettings()
        }
    }

    fun updateWaterQuantity(quantity: Int){
        viewModelScope.launch {
            settingsRepository.updateWaterQuantity(quantity)
            loadSettings()
        }
    }

    fun increaseDrinkingWater(ml: Int){
        viewModelScope.launch {
            settings.value?.let {
                settingsRepository.updateDrinkingWater(it.drinkingWater + ml)
            }
        }
    }

    fun decreaseDrinkingWater(ml: Int){
        viewModelScope.launch {
            settings.value?.let {
                settingsRepository.updateDrinkingWater(it.drinkingWater - ml)
            }
        }
    }

}