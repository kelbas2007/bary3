allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // Принудительно устанавливаем Java 17 для всех проектов, включая Flutter плагины
    // Используем afterEvaluate для применения после загрузки плагинов
    afterEvaluate {
        // Для Android библиотек (включая device_calendar и другие плагины)
        extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
        
        // Для Android приложений
        extensions.findByType<com.android.build.gradle.AppExtension>()?.apply {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
    
    // Принудительно устанавливаем Java 17 для всех подпроектов (включая Flutter плагины)
    // Используем configureEach для ленивой настройки задач, что работает даже после оценки проекта
    
    // Подавляем предупреждения об устаревших опциях Java для всех задач компиляции
    // Это применяется ко всем подпроектам, включая Flutter плагины
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
        options.compilerArgs.add("-Xlint:-options")
    }
    
    // Устанавливаем JVM target для всех Kotlin задач компиляции (новый DSL для Kotlin 2.2+)
    // Это применяется ко всем подпроектам, включая Flutter плагины
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
