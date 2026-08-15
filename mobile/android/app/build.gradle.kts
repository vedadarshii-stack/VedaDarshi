import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release (upload) signing credentials. GITIGNORED, and the `storeFile` it
// names lives OUTSIDE the repo — see android/key.properties.
//
// Absent on a machine that has not been given the keystore, which is a
// supported state: debug builds are unaffected, and a release build then
// produces an UNSIGNED artifact rather than silently falling back to the
// debug key. That fallback is what this file used to do, and it is a trap —
// a debug-signed AAB is rejected by Play, but a debug-signed APK installs
// happily and looks fine right up until you try to ship it.
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
val keystoreProperties = Properties().apply {
    if (hasReleaseKeystore) {
        FileInputStream(keystorePropertiesFile).use { load(it) }
    }
}

android {
    namespace = "com.gosewealth.vedadarshi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications requires core library desugaring
        // (its Android implementation uses java.time APIs backported to
        // older API levels) — without this the build fails at
        // :app:checkDebugAarMetadata.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.gosewealth.vedadarshi"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // firebase_auth requires minSdk 23 — this Flutter SDK's default
        // flutter.minSdkVersion (24) already satisfies that, so no explicit
        // override is needed. (An explicit `minSdk = 23` pin was tried, but
        // Flutter's Gradle tooling rewrites this file to the template form
        // on every build and discards it — if a future Flutter SDK ever
        // lowers the default below 23, pin it explicitly here instead.)
        // Also comfortably covers firebase_messaging/flutter_local_notifications
        // (minSdk 21) and the POST_NOTIFICATIONS runtime permission, which the
        // manifest declares but which is only enforced by the OS on API 33+ —
        // nothing extra needed here for that either.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // Null when key.properties is missing → unsigned release output,
            // which fails loudly at upload time instead of quietly shipping a
            // debug-signed build. See the comment above the property load.
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

// Surfaced at configuration time so it appears on every build, not only when
// someone happens to read the artifact name.
if (!hasReleaseKeystore) {
    logger.warn(
        "WARNING: android/key.properties not found — release builds will be " +
            "UNSIGNED and Play will reject them. Copy the keystore and " +
            "key.properties from the project's secure backup."
    )
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
    // Required by compileOptions.isCoreLibraryDesugaringEnabled above.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
