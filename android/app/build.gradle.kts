import org.gradle.api.tasks.compile.JavaCompile
import java.io.File
import java.util.Properties

// === 1. LOAD THE PROPERTIES FILE ===
// This block reads the key.properties file located in the 'android' directory.
val localPropertiesFile = File(project.rootDir, "key.properties")
val localProperties = Properties()

if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { input ->
        localProperties.load(input)
    }
}

// === HELPER FUNCTION TO GET PROPERTY OR ENV VARIABLE ===
// This function prioritizes localProperties (for dev) then environment variables (for CI/CD).
fun getSecret(key: String, envVar: String): String {
    // 1. Check local key.properties
    val value = localProperties.getProperty(key)
    
    // 2. If null, check environment variables (used by GitHub Actions)
    if (value.isNullOrEmpty()) {
        val envValue = System.getenv(envVar)
        if (envValue.isNullOrEmpty()) {
            throw GradleException("Missing required signing property: '$key'. Please ensure it's in key.properties (local) or set as the environment variable '$envVar' (CI/CD).")
        }
        return envValue
    }
    return value
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
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    // Suppress obsolete Java version warnings
    tasks.withType<JavaCompile>().configureEach {
        options.compilerArgs.addAll(listOf("-Xlint:-options"))
    }

    // === 2. DEFINE THE SIGNING CONFIGURATION (FIXED) ===
    signingConfigs {
        create("release") {
            // NOTE: The file path must be accessible in CI/CD. Often, the keystore file needs 
            // to be uploaded and saved as a file inside the workflow before this step runs.
            storeFile = file(getSecret("storeFile", "KEY_STORE_FILE"))
            storePassword = getSecret("storePassword", "KEY_STORE_PASSWORD")
            keyAlias = getSecret("keyAlias", "KEY_ALIAS")
            keyPassword = getSecret("keyPassword", "KEY_KEY_PASSWORD")
        }
    }
    
    defaultConfig {
        applicationId = "de.bssb.meinbssb"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // === 3. APPLY THE RELEASE CONFIG ===
            signingConfig = signingConfigs.getByName("release")
            
            // Standard settings for release builds (recommended):
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

flutter {
    source = "../.."
}

subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            project.android.compileSdkVersion = "36"
        }
    }
}

dependencies {
    implementation("androidx.activity:activity-ktx:1.9.3")
}
