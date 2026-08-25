import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}
val releaseSigningConfigured =
    keystorePropertiesFile.exists() &&
        listOf("keyAlias", "keyPassword", "storeFile", "storePassword").all {
            !keystoreProperties.getProperty(it).isNullOrBlank()
        }
val wenyouEnableImpeller = providers.gradleProperty("wenyouEnableImpeller")
    .orElse("true")
    .get()
    .also { value ->
        require(value == "true" || value == "false") {
            "wenyouEnableImpeller must be true or false."
        }
    }

android {
    namespace = "site.wenyou.app"
    // flutter_secure_storage 11 requires API 37 at compile time. This does not
    // change the Android 8 (API 26) minimum supported version.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "site.wenyou.app"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appLabel"] = "温油站"
        manifestPlaceholders["enableImpeller"] = wenyouEnableImpeller
    }

    signingConfigs {
        if (releaseSigningConfigured) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        getByName("debug") {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
            manifestPlaceholders["appLabel"] = "温油站 Debug"
        }
        getByName("release") {
            signingConfig = signingConfigs.findByName("release")
        }
    }

}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 1.19.0 requires AGP 9.1; keep this aligned with the project's AGP 9.0.1.
    implementation("androidx.core:core:1.18.0")
}
