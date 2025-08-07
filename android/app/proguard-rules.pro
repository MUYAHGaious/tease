# Flutter specific rules to prevent crashes on release builds

# Keep all Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep all model classes and data classes
-keep class * implements android.os.Parcelable { *; }
-keep class * extends java.lang.Exception { *; }

# Keep all Dart/Flutter generated classes
-keep class **.GeneratedPluginRegistrant { *; }
-keep class **.MainActivity { *; }

# Preserve line numbers for debugging
-keepattributes LineNumberTable
-keepattributes SourceFile

# Keep all annotations
-keepattributes *Annotation*

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all reflection-based code
-keep class * {
    public <init>(...);
}

# Keep all Timer and Handler related classes
-keep class java.util.Timer { *; }
-keep class java.util.TimerTask { *; }
-keep class android.os.Handler { *; }

# Keep all animation related classes
-keep class android.animation.** { *; }
-keep class androidx.animation.** { *; }

# Prevent obfuscation of critical system classes
-keep class android.content.Context { *; }
-keep class android.app.Activity { *; }
-keep class androidx.fragment.app.Fragment { *; }

# Keep all BuildContext and State related classes
-keep class ** extends android.app.Activity { *; }
-keep class ** extends androidx.fragment.app.Fragment { *; }

# Don't obfuscate any async operations
-keep class java.util.concurrent.** { *; }
-keep class java.lang.Runnable { *; }

# Keep all custom exceptions and error handling
-keep class java.lang.RuntimeException { *; }
-keep class java.lang.Exception { *; }

# Additional Flutter and Dart specific rules
-dontwarn io.flutter.**
-dontwarn dart.**

# Keep all JSON/serialization related classes
-keep class com.google.gson.** { *; }
-keep class org.json.** { *; }

# Keep all location and GPS related classes if any
-keep class android.location.** { *; }
-keep class com.google.android.gms.location.** { *; }

# Prevent crashes from reflection-based operations
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Don't optimize away important method signatures
-keepattributes Signature
-keepattributes Exceptions