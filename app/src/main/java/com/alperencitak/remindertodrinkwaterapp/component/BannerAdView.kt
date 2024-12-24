package com.alperencitak.remindertodrinkwaterapp.component

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.viewinterop.AndroidView
import com.alperencitak.remindertodrinkwaterapp.BuildConfig
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView

@Composable
fun BannerAdView(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    AndroidView(
        modifier = modifier,
        factory = { createAdView(context) },
        update = { adView ->
            val adRequest = AdRequest.Builder().build()
            adView.loadAd(adRequest)
        }
    )
}

fun createAdView(context: Context): AdView {
    val adView = AdView(context)
    adView.setAdSize(AdSize.FULL_BANNER)
    adView.adUnitId = BuildConfig.ADMOB_AD_UNIT_ID
    return adView
}