plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
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

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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
    // Required by compileOptions.isCoreLibraryDesugaringEnabled above.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
