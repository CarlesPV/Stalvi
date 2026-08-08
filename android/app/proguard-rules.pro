# =============================================================================
# Stalvi – ProGuard / R8 Rules
# =============================================================================
# These rules keep the reflection-sensitive parts of the Flutter embedding,
# SQLCipher, Drift and biometrics intact while allowing R8 to shrink and
# obfuscate all application code.
# =============================================================================

# ---------------------------------------------------------------------------
# Flutter embedding
# ---------------------------------------------------------------------------
# (Relying on built-in rules from Flutter embedding AAR)

# ---------------------------------------------------------------------------
# SQLCipher / SQLite JNI bridge
# ---------------------------------------------------------------------------
# SQLCipher loads its native library and accesses the JNI layer via reflection.
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }
-dontwarn net.sqlcipher.**

# Keep SQLite native open helpers used by sqlcipher_flutter_libs / sqlite3
-keep class org.sqlite.** { *; }
-dontwarn org.sqlite.**

# ---------------------------------------------------------------------------
# Drift ORM (Dart/Java interop stubs)
# ---------------------------------------------------------------------------
# Drift generates companion classes that are loaded reflectively by the
# Dart FFI bridge on Android. Preserve all generated suffixes.
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }

# ---------------------------------------------------------------------------
# Flutter Secure Storage (EncryptedSharedPreferences / Keystore)
# ---------------------------------------------------------------------------
# (Relying on built-in rules from AndroidX Security)

# ---------------------------------------------------------------------------
# Local Auth / Biometrics
# ---------------------------------------------------------------------------
# (Relying on built-in rules from AndroidX Biometric)

# ---------------------------------------------------------------------------
# General Android / Jetpack
# ---------------------------------------------------------------------------
# Keep View constructors used by layouts (required for any XML-inflated views).
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Keep Parcelable implementations (used by Android IPC).
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Keep serialization members (for any Java serializable helpers).
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ---------------------------------------------------------------------------
# Suppress common harmless warnings from transitive dependencies
# ---------------------------------------------------------------------------
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
-dontwarn kotlin.reflect.jvm.internal.**

# ---------------------------------------------------------------------------
# WorkManager / Room (Fix for Release Mode crash)
# ---------------------------------------------------------------------------
# (Relying on built-in rules from AndroidX Work, Startup, and Room)
