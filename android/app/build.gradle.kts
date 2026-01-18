plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.bary3"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    // Используем новый DSL для Kotlin 2.2+
    // kotlinOptions устарел, но пока оставляем для совместимости с Flutter plugin
    // JVM target устанавливается через tasks.withType<KotlinCompile> ниже

    defaultConfig {
        // TODO: ⚠️ ВАЖНО: Замените на свой уникальный Application ID перед публикацией!
        // После первой публикации в Play Store изменить нельзя!
        // Пример: com.yourcompany.bary3 или com.yourname.bary3
        // Документация: https://developer.android.com/studio/build/application-id.html
        applicationId = "com.bary3.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Поддержка нативных библиотек для llama.cpp
        ndk {
            abiFilters += listOf("arm64-v8a", "x86_64")
        }
    }
    
    // Включаем jniLibs для нативных библиотек
    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("src/main/jniLibs")
        }
    }

    buildTypes {
        release {
            // TODO: ⚠️ КРИТИЧНО: Настройте Release Signing перед публикацией в Play Store!
            // 
            // 1. Создайте release-ключ:
            //    keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
            //
            // 2. Создайте файл android/key.properties:
            //    storePassword=<ваш пароль>
            //    keyPassword=<ваш пароль>
            //    keyAlias=upload
            //    storeFile=<путь к upload-keystore.jks>
            //
            // 3. Раскомментируйте и настройте signingConfig ниже
            //
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // Раскомментируйте после настройки key.properties:
            // val keystoreProperties = Properties()
            // val keystorePropertiesFile = rootProject.file("key.properties")
            // if (keystorePropertiesFile.exists()) {
            //     keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            // }
            // signingConfigs {
            //     create("release") {
            //         keyAlias = keystoreProperties["keyAlias"] as String
            //         keyPassword = keystoreProperties["keyPassword"] as String
            //         storeFile = file(keystoreProperties["storeFile"] as String)
            //         storePassword = keystoreProperties["storePassword"] as String
            //     }
            // }
            // signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    
    // ML Kit GenAI для Gemini Nano
    // TODO: Раскомментировать, когда SDK будет доступен
    // implementation("com.google.mlkit:genai:1.0.0")
}

// Унифицированные настройки Java/Kotlin для всех задач компиляции
tasks.withType<JavaCompile>().configureEach {
    sourceCompatibility = "17"
    targetCompatibility = "17"
    options.compilerArgs.add("-Xlint:-options")
    options.isFork = true // Используем отдельный процесс для компиляции
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}
