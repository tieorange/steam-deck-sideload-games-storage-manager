package com.example.game_size_manager

import android.app.usage.StorageStatsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Process
import android.os.storage.StorageManager
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.tieorange.game_size_manager/games"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    try {
                        val apps = getInstalledAppsWithSizes()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, e.stackTraceToString())
                    }
                }
                "uninstallApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        try {
                            uninstallApp(packageName)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNINSTALL_ERROR", e.message, e.stackTraceToString())
                        }
                    } else {
                        result.error("INVALID_ARGS", "packageName is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Launch Android's uninstall dialog for the given package
     */
    private fun uninstallApp(packageName: String) {
        val intent = Intent(Intent.ACTION_DELETE).apply {
            data = Uri.parse("package:$packageName")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    private fun getInstalledAppsWithSizes(): String {
        val pm = packageManager
        val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val jsonArray = JSONArray()

        val storageStatsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            getSystemService(Context.STORAGE_STATS_SERVICE) as? StorageStatsManager
        } else null

        val storageManager = getSystemService(Context.STORAGE_SERVICE) as StorageManager
        val storageUuid = StorageManager.UUID_DEFAULT

        for (appInfo in packages) {
            // Skip system apps without launcher (keep user-visible system apps)
            if (appInfo.flags and ApplicationInfo.FLAG_SYSTEM != 0) {
                val launchIntent = pm.getLaunchIntentForPackage(appInfo.packageName)
                if (launchIntent == null) continue
            }

            val appName = pm.getApplicationLabel(appInfo).toString()
            val packageName = appInfo.packageName

            // Determine source
            val installerPackage = try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    pm.getInstallSourceInfo(packageName).installingPackageName
                } else {
                    @Suppress("DEPRECATION")
                    pm.getInstallerPackageName(packageName)
                }
            } catch (e: Exception) { null }

            val source = when (installerPackage) {
                "com.oculus.ocms", "com.oculus.mobilestore", "com.meta.mobilestore" -> "META_STORE"
                null, "com.android.shell", "com.android.packageinstaller" -> "SIDELOADED"
                "com.android.vending" -> "PLAY_STORE"
                else -> "OTHER"
            }

            // Get sizes using StorageStatsManager (API 26+)
            var totalBytes: Long = 0
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && storageStatsManager != null) {
                try {
                    val stats = storageStatsManager.queryStatsForPackage(
                        storageUuid,
                        packageName,
                        Process.myUserHandle()
                    )
                    totalBytes = stats.appBytes + stats.dataBytes + stats.cacheBytes
                } catch (e: Exception) {
                    // Usage stats permission not granted - fallback to APK size
                    try {
                        val apkFile = java.io.File(appInfo.sourceDir)
                        totalBytes = apkFile.length()
                    } catch (_: Exception) {}
                }
            } else {
                // Fallback for older API levels
                try {
                    val apkFile = java.io.File(appInfo.sourceDir)
                    totalBytes = apkFile.length()
                } catch (_: Exception) {}
            }

            // Get app icon as base64
            val iconBase64 = try {
                val drawable = pm.getApplicationIcon(appInfo)
                drawableToBase64(drawable)
            } catch (e: Exception) { null }

            val appJson = JSONObject().apply {
                put("appName", appName)
                put("packageName", packageName)
                put("source", source)
                put("totalBytes", totalBytes)
                if (iconBase64 != null) {
                    put("iconBase64", iconBase64)
                }
            }
            jsonArray.put(appJson)
        }

        return jsonArray.toString()
    }

    /**
     * Convert a Drawable to base64 PNG string
     */
    private fun drawableToBase64(drawable: Drawable): String? {
        return try {
            val bitmap = when (drawable) {
                is BitmapDrawable -> drawable.bitmap
                is AdaptiveIconDrawable -> {
                    // Handle adaptive icons (Android 8.0+)
                    val bitmap = Bitmap.createBitmap(
                        drawable.intrinsicWidth.coerceAtLeast(1),
                        drawable.intrinsicHeight.coerceAtLeast(1),
                        Bitmap.Config.ARGB_8888
                    )
                    val canvas = Canvas(bitmap)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                    bitmap
                }
                else -> {
                    // Generic drawable conversion
                    val width = drawable.intrinsicWidth.coerceAtLeast(1)
                    val height = drawable.intrinsicHeight.coerceAtLeast(1)
                    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                    val canvas = Canvas(bitmap)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                    bitmap
                }
            }

            // Scale down to 64x64 for efficiency
            val scaledBitmap = Bitmap.createScaledBitmap(bitmap, 64, 64, true)
            
            val stream = ByteArrayOutputStream()
            scaledBitmap.compress(Bitmap.CompressFormat.PNG, 90, stream)
            val byteArray = stream.toByteArray()
            Base64.encodeToString(byteArray, Base64.NO_WRAP)
        } catch (e: Exception) {
            null
        }
    }
}
