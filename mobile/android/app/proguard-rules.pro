# Reglas de R8 para la versión de release (código reducido y ofuscado).
# Flutter y sus plugins traen sus propias reglas; aquí solo lo que hace falta además.

# Firebase Cloud Messaging (avisos push)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# flutter_secure_storage (Keystore / EncryptedSharedPreferences)
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Play Core (componentes diferidos de Flutter; no se usan)
-dontwarn com.google.android.play.core.**
