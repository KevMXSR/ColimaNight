# ==============================================================================
# 🛡️ COLIMANIGHT — REGLAS DE OFUSCACIÓN Y DUREZA R8 / PROGUARD
# ==============================================================================
# Protege el código compilado de Flutter y plugins contra desensamblado / decompilación.

# Reglas base para Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.**  { *; }

# Mantener clases de atributos y anotaciones necesarias
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Ofuscar nombres de métodos, variables y clases internas no exportadas
-repackageclasses ''
-allowaccessmodification

# Descartar registros de log de depuración en compilaciones de producción
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
}

# Plugins específicos (Geolocator, SharedPreferences, etc.)
-dontwarn com.baseflow.geolocator.**
-keep class com.baseflow.geolocator.** { *; }
