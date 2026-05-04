package com.example.project_tweety



import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "project_tweety/system_text_settings",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openTextSettings" -> result.success(openTextSettings())
                else -> result.notImplemented()
            }
        }
    }

    private fun openTextSettings(): Boolean {
        val intents = listOf(
            Intent(Settings.ACTION_DISPLAY_SETTINGS),
            Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS),
        )

        for (intent in intents) {
            if (intent.resolveActivity(packageManager) != null) {
                startActivity(intent)
                return true
            }
        }

        return false
    }
}
