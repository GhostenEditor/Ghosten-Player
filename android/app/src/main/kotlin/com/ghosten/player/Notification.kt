package com.ghosten.player

import android.Manifest
import android.app.Activity
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.RequiresPermission
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.roundToInt

class Notification(
    val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {

    init {
        createNotificationChannel()
        val methodChannel = MethodChannel(messenger, PLUGIN_NAMESPACE)
        methodChannel.setMethodCallHandler(this)
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    override fun onMethodCall(
        call: MethodCall, result: MethodChannel.Result
    ) {
        if (call.method == "progressCreate") requestNotificationPermissionIfNeeded()
        if (!canNotify()) return result.success(null)
        val id = call.argument<Int>("id")
        val title = call.argument<String>("title")
        val content = call.argument<String>("content")
        val progress = call.argument<Double>("progress")
        if (id == null) return result.success(null)
        when (call.method) {
            "progressCreate" -> progressCreate(id, title, content)
            "progressUpdate" -> progressUpdate(id, title, content, progress ?: 0.0)
            "progressComplete" -> progressComplete(id, title, content)
            "progressFail" -> progressFail(id, title, content)
            "progressCancel" -> progressCancel(id)
            else -> return result.notImplemented()
        }

        result.success(null)

    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID, NOTIFICATION_CHANNEL_NAME, NotificationManager.IMPORTANCE_HIGH
            ).apply {
                setShowBadge(true)
                enableVibration(true)
                setSound(null, null)
            }
            activity.getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun canNotify(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU || activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            activity.requestPermissions(
                arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1001
            )
        }
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    private fun progressCreate(id: Int, title: String?, content: String?) {
        val notification = NotificationCompat
            .Builder(activity, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setContentTitle(title)
            .setContentText(content)
            .setProgress(0, 0, true)
            .setOnlyAlertOnce(true)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
        NotificationManagerCompat.from(activity).notify(id, notification)
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    private fun progressUpdate(id: Int, title: String?, content: String?, progress: Double) {
        val notification = NotificationCompat
            .Builder(activity, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setContentTitle(title)
            .setContentText(content)
            .setProgress(100, (progress * 100).roundToInt(), false)
            .setOnlyAlertOnce(true)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
        NotificationManagerCompat.from(activity).notify(id, notification)
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    private fun progressComplete(id: Int, title: String?, content: String?) {
        val notification = NotificationCompat
            .Builder(activity, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_download_done)
            .setContentTitle(title)
            .setContentText(content)
            .setProgress(0, 0, false)
            .setOnlyAlertOnce(true)
            .setOngoing(false)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()
        NotificationManagerCompat.from(activity).notify(id, notification)
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    private fun progressFail(id: Int, title: String?, content: String?) {
        val notification = NotificationCompat
            .Builder(activity, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_notify_error)
            .setContentTitle(title)
            .setContentText(content)
            .setProgress(0, 0, false)
            .setAutoCancel(true)
            .setOngoing(false)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()
        NotificationManagerCompat.from(activity).notify(id, notification)
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    private fun progressCancel(id: Int) {
        NotificationManagerCompat.from(activity).cancel(id)
    }


    companion object {
        private const val PLUGIN_NAMESPACE = "com.ghosten.player/notification"
        private const val NOTIFICATION_CHANNEL_ID = "notification_channel_id"
        private const val NOTIFICATION_CHANNEL_NAME = "Download Progress"
    }
}
