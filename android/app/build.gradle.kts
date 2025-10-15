import org.gradle.api.tasks.compile.JavaCompile
import java.io.File
import java.util.Properties

// === 1. LOAD THE PROPERTIES FILE ===
// This block reads the key.properties file located in the 'android' directory.
// We use 'project.rootDir' (which is the 'android' directory) for the base path.
val localPropertiesFile = File(project.rootDir, "key.properties")
val localProperties = Properties()

if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { input ->
        localProperties.load(input)
    }
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "de.bssb.meinbssb"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    // Suppress obsolete Java version warnings
    tasks.withType<JavaCompile>().configureEach {
        options.compilerArgs.addAll(listOf("-Xlint:-options"))
    }

    // === 2. DEFINE THE SIGNING CONFIGURATION ===
    signingConfigs {
        create("release") {
            // Retrieve values from the localProperties variable loaded above
            storeFile = file(localProperties.get("storeFile") as String)
            storePassword = localProperties.get("storePassword") as String
            keyAlias = localProperties.get("keyAlias") as String
            keyPassword = localProperties.get("keyPassword") as String
        }
    }
    
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "de.bssb.meinbssb"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // === 3. APPLY THE RELEASE CONFIG (MODIFIED LINE) ===
            // This tells the release build process to use our defined 'release' signing credentials.
            signingConfig = signingConfigs.getByName("release")
            
            // Standard settings for release builds (recommended):
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
    
    // Note: The redundant 'signingConfigs' and 'buildTypes' blocks you had at the end were removed.

}

flutter {
    source = "../.."
}
