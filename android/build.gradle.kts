plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")    // ⚡ version hata diya, kyunki settings.gradle.kts handle karega
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.note_vault_frontend"   // ⚡ namespace add karna zaruri hai latest Gradle ke liye
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.note_vault_frontend"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}