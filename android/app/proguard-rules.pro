## BouncyCastle (for SSL)
#-keep class org.bouncycastle.** { *; }
#
## Conscrypt (used internally by okhttp)
#-keep class org.conscrypt.** { *; }
#
## OpenJSSE
#-keep class org.openjsse.** { *; }
#
## OkHttp reflection usage
#-keep class okhttp3.** { *; }
#-dontwarn okhttp3.internal.platform.**
#
## Kotlin metadata
#-keep class kotlin.Metadata { *; }
#
## Flutter plugin generated classes
#-keep class io.flutter.** { *; }
#
#
## Flutter deferred components (optional feature modules)
#-keep class com.google.android.play.** { *; }
#-dontwarn com.google.android.play.**
#
#-keep class com.google.android.play.core.splitcompat.** { *; }
#-keep class com.google.android.play.core.splitinstall.** { *; }
#-keep class com.google.android.play.core.tasks.** { *; }


#
-dontwarn org.bouncycastle.jsse.BCSSLParameters
-dontwarn org.bouncycastle.jsse.BCSSLSocket
-dontwarn org.bouncycastle.jsse.provider.BouncyCastleJsseProvider
-dontwarn org.conscrypt.Conscrypt$Version
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.ConscryptHostnameVerifier
-dontwarn org.openjsse.javax.net.ssl.SSLParameters
-dontwarn org.openjsse.javax.net.ssl.SSLSocket
-dontwarn org.openjsse.net.ssl.OpenJSSE