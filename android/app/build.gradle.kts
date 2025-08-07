plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tease_new"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    
    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.tease_new"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Prevent crashes on low-memory devices
        multiDexEnabled = true
        
        // Optimize for mobile devices
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a")
        }
        
        // Add build config fields for crash prevention
        buildConfigField("boolean", "ENABLE_CRASH_REPORTING", "true")
        buildConfigField("String", "BUILD_TYPE", "\"release\"")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // Disable R8/ProGuard obfuscation to prevent crashes
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            
            // Enable debugging for release builds to track crashes
            isDebuggable = false
            isJniDebuggable = false
            
            // Optimize for performance
            isShrinkResources = false
            isZipAlignEnabled = true
        }
        
        debug {
            // Enable debugging for debug builds
            isDebuggable = true
            isMinifyEnabled = false
        }
    }
}

flutter {
    source = "../.."
}
