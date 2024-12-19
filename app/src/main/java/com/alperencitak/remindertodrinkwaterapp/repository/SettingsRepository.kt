package com.alperencitak.remindertodrinkwaterapp.repository

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.floatPreferencesKey
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.alperencitak.remindertodrinkwaterapp.model.Settings
import com.alperencitak.remindertodrinkwaterapp.model.TimeInterval
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import javax.inject.Inject

class SettingsRepository @Inject constructor(
    private val context: Context
) {
    companion object{
        private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")
    }

    private object SettingsKeys{
        val SILENT_MODE = booleanPreferencesKey("silent_mode")
        val TIME_INTERVAL = stringPreferencesKey("time_interval")
        val WATER_QUANTITY = intPreferencesKey("water_quantity")
        val DRINKING_WATER = intPreferencesKey("drinking_water")
    }

    val settings: Flow<Settings> = context.dataStore.data
        .map { preferences ->
            Settings(
                isSilentMode = preferences[SettingsKeys.SILENT_MODE] ?: false,
                timeInterval = preferences[SettingsKeys.TIME_INTERVAL]
                    ?.let { TimeInterval.valueOf(it) }
                    ?: TimeInterval.TWO_PER_HOUR,
                waterQuantity = preferences[SettingsKeys.WATER_QUANTITY] ?: 2500,
                drinkingWater = preferences[SettingsKeys.DRINKING_WATER] ?: 0
            )
        }

    suspend fun updateSilentMode(value: Boolean){
        context.dataStore.edit { prefences ->
            prefences[SettingsKeys.SILENT_MODE] = value
        }
    }

    suspend fun updateTimeInterval(timeInterval: TimeInterval){
        context.dataStore.edit { prefences ->
            prefences[SettingsKeys.TIME_INTERVAL] = timeInterval.name
        }
    }

    suspend fun updateWaterQuantity(quantity: Int){
        context.dataStore.edit { prefences ->
            prefences[SettingsKeys.WATER_QUANTITY] = quantity
        }
    }

    suspend fun updateDrinkingWater(ml: Int){
        context.dataStore.edit { prefences ->
            prefences[SettingsKeys.DRINKING_WATER] = ml
        }
    }

}