package com.alperencitak.remindertodrinkwaterapp.repository

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.floatPreferencesKey
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
        val DARK_MODE = booleanPreferencesKey("dark_mode")
        val SLEEP_MODE = booleanPreferencesKey("sleep_mode")
        val TIME_INTERVAL = stringPreferencesKey("time_interval")
        val WATER_QUANTITY = floatPreferencesKey("water_quantity")
    }

    val settings: Flow<Settings> = context.dataStore.data
        .map { preferences ->
            Settings(
                isDarkMode = preferences[SettingsKeys.DARK_MODE] ?: false,
                isSleepMode = preferences[SettingsKeys.SLEEP_MODE] ?: false,
                timeInterval = preferences[SettingsKeys.TIME_INTERVAL]
                    ?.let { TimeInterval.valueOf(it) }
                    ?: TimeInterval.TWO_PER_HOUR,
                waterQuantity = preferences[SettingsKeys.WATER_QUANTITY] ?: 2.5f
            )
        }

    suspend fun updateDarkMode(value: Boolean){
        context.dataStore.edit { prefences ->
            prefences[SettingsKeys.DARK_MODE] = value
        }
    }

    suspend fun updateSleepMode(value: Boolean){
        context.dataStore.edit { prefences ->
            prefences[SettingsKeys.SLEEP_MODE] = value
        }
    }

    suspend fun updateTimeInterval(timeInterval: TimeInterval){
        context.dataStore.edit { prefences ->
            prefences[SettingsKeys.TIME_INTERVAL] = timeInterval.name
        }
    }

    suspend fun updateWaterQuantity(quantity: Float){
        context.dataStore.edit { prefences ->
            prefences[SettingsKeys.WATER_QUANTITY] = quantity
        }
    }

    suspend fun getSettings(): Settings {
        val preferences = context.dataStore.data.first()
        return Settings(
            isDarkMode = preferences[SettingsKeys.DARK_MODE] ?: false,
            isSleepMode = preferences[SettingsKeys.SLEEP_MODE] ?: false,
            timeInterval = preferences[SettingsKeys.TIME_INTERVAL]
                ?.let { TimeInterval.valueOf(it) }
                ?: TimeInterval.TWO_PER_HOUR,
            waterQuantity = preferences[SettingsKeys.WATER_QUANTITY] ?: 2.5f
        )
    }

}