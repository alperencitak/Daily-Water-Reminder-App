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
        val WATER_QUANTITY = intPreferencesKey("water_quantity")
        val DRINKING_GLASS = intPreferencesKey("drinking_glass")
    }

    val settings: Flow<Settings> = context.dataStore.data
        .map { preferences ->
            Settings(
                isSilentMode = preferences[SettingsKeys.SILENT_MODE] ?: false,
                waterQuantity = preferences[SettingsKeys.WATER_QUANTITY] ?: 2400,
                drinkingGlass = preferences[SettingsKeys.DRINKING_GLASS] ?: 0
            )
        }

    suspend fun updateSilentMode(value: Boolean){
        context.dataStore.edit { prefences ->
            prefences[SettingsKeys.SILENT_MODE] = value
        }
    }

    suspend fun updateWaterQuantity(quantity: Int){
        context.dataStore.edit { prefences ->
            prefences[SettingsKeys.WATER_QUANTITY] = quantity
        }
    }

    suspend fun updateDrinkingGlass(value: Int){
        context.dataStore.edit { prefences ->
            prefences[SettingsKeys.DRINKING_GLASS] = value
        }
    }
}