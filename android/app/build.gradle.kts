import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: android/key.properties (not committed). See README.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

// AdMob IDs come from gradle properties (-PADMOB_APP_ID=... or ~/.gradle/gradle.properties),
// same as the native version. Debug builds always use Google's official test IDs.
fun prop(name: String): String = (project.findProperty(name) as String?).orEmpty()
val admobTestAppId = "ca-app-pub-3940256099942544~3347511713"
val admobTestBannerId = "ca-app-pub-3940256099942544/6300978111"

android {
    namespace = "com.alperencitak.remindertodrinkwaterapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "com.alperencitak.remindertodrinkwaterapp"
        minSdk = 24
        targetSdk = 36
        // versionCode/versionName come from pubspec.yaml (version: x.y.z+code).
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystoreProperties.isNotEmpty()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        debug {
            // Always test ads while developing: real impressions/clicks from
            // dev devices can get the AdMob account flagged.
            manifestPlaceholders["ADMOB_APP_ID"] = admobTestAppId
            buildConfigField("String", "ADMOB_AD_UNIT_ID", "\"$admobTestBannerId\"")
        }
        release {
            signingConfig = if (keystoreProperties.isNotEmpty()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // The Ads SDK needs a valid app id in the manifest or it crashes on start;
            // without a real one we keep the test app id and simply show no banner.
            manifestPlaceholders["ADMOB_APP_ID"] = prop("ADMOB_APP_ID").ifEmpty { admobTestAppId }
            buildConfigField("String", "ADMOB_AD_UNIT_ID", "\"${prop("ADMOB_AD_UNIT_ID")}\"")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Reads the settings stored by the native (pre-Flutter) app once, for migration.
    implementation("androidx.datastore:datastore-preferences:1.1.7")
}

flutter {
    source = "../.."
}
