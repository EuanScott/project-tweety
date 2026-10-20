package dev.euanscott.projecttweety

import android.app.PendingIntent
import android.content.Intent
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

/**
 * Quick Settings tile that opens the log entry editor.
 *
 * It sends the same action as the home screen shortcut, so
 * MainActivity.holdShortcut hands it to Dart. A locked device unlocks first.
 */
class NewLogTileService : TileService() {
    override fun onStartListening() {
        super.onStartListening()
        qsTile?.apply {
            state = Tile.STATE_INACTIVE
            updateTile()
        }
    }

    override fun onClick() {
        super.onClick()
        if (isLocked) {
            unlockAndRun { launch() }
        } else {
            launch()
        }
    }

    private fun launch() {
        val intent = Intent(this, MainActivity::class.java)
            .setAction("$packageName.action.createLog")
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        startActivityAndCollapse(pendingIntent)
    }
}
