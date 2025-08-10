# Project-specific ProGuard rules
# Keep Flutter embedding
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Keep Flutter plugins
-keep class io.flutter.plugin.** { *; }
-dontwarn io.flutter.plugin.**

# Add any additional rules below as needed
