import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase: avisos push
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Llave de firma de la versión para tiendas: android/key.properties (NUNCA se sube a git, ver .gitignore).
// Contiene storeFile, storePassword, keyAlias y keyPassword. Sin ese archivo, la versión final no se firma
// con la llave de pruebas: la compilación de release falla con un mensaje que explica qué falta.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKey = keystoreProperties.getProperty("storeFile") != null

android {
    namespace = "mx.zugar.homiz"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "mx.zugar.homiz"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKey) {
                signingConfig = signingConfigs.getByName("release")
            }
            // Código reducido y ofuscado (R8) y sin recursos sin usar
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

// API_URL que Flutter pasa con --dart-define (llega en base64, separado por comas, en -Pdart-defines)
val apiUrl: String = run {
    val raw: String = project.findProperty("dart-defines")?.toString() ?: ""
    var found = ""
    for (part: String in raw.split(",")) {
        if (part.isBlank()) continue
        val define: String = Base64.getDecoder().decode(part).toString(Charsets.UTF_8)
        if (define.startsWith("API_URL=")) found = define.removePrefix("API_URL=")
    }
    found
}

// La versión de release no se firma con la llave de pruebas ni apunta a un servidor de desarrollo:
// si falta algo, se detiene con instrucciones (Google rechaza una app que no funciona)
gradle.taskGraph.whenReady {
    if (allTasks.none { it.name.contains("Release") && (it.name.startsWith("assemble") || it.name.startsWith("bundle")) }) return@whenReady
    if (!hasReleaseKey) {
        throw GradleException(
            "Falta android/key.properties con la llave de firma de la app (ver docs/produccion.md). " +
                "La versión para la tienda no se firma con la llave de pruebas.",
        )
    }
    val dev = Regex("localhost|127\\.0\\.0\\.1|10\\.0\\.2\\.2|192\\.168\\.|trycloudflare\\.com|devtunnels\\.ms", RegexOption.IGNORE_CASE)
    if (!apiUrl.startsWith("https://") || dev.containsMatchIn(apiUrl)) {
        throw GradleException(
            "La versión para la tienda necesita la API de producción en HTTPS. Compila con " +
                "--dart-define=API_URL=https://<tu-servidor>/api/v1 (ver docs/produccion.md). Recibido: '" + apiUrl + "'.",
        )
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
