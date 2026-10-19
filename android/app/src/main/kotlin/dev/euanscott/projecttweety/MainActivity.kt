package dev.euanscott.projecttweety



import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var shortcutChannel: MethodChannel? = null
    private var pendingShortcut: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // A restored activity or a relaunch from Recents carries the old
        // launch intent, which must not open its shortcut again.
        val isFreshLaunch = savedInstanceState == null &&
            intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY == 0
        if (isFreshLaunch) {
            holdShortcut(intent)
        }
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        holdShortcut(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        shortcutChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "project_tweety/home_screen_shortcuts",
        ).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "takePendingShortcut" -> {
                        result.success(pendingShortcut)
                        pendingShortcut = null
                    }
                    else -> result.notImplemented()
                }
            }
        }

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

    /**
     * Holds a home screen shortcut until Dart takes it, then signals Dart.
     *
     * res/xml/shortcuts.xml declares each action as
     * `<package>.action.<Dart type>`.
     */
    private fun holdShortcut(intent: Intent) {
        val prefix = "$packageName.action."
        val action = intent.action ?: return
        if (!action.startsWith(prefix)) {
            return
        }

        pendingShortcut = action.removePrefix(prefix)
        shortcutChannel?.invokeMethod("shortcutPending", null)
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
