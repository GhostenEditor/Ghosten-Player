package com.ghosten.player

import android.annotation.TargetApi
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.provider.Settings
import android.window.BackEvent
import androidx.annotation.RequiresApi
import io.flutter.Build.API_LEVELS
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainFragment : FlutterFragment() {
    private var deeplink: String? = null
    private var pipChannel: EventChannel? = null
    private var pipSink: EventChannel.EventSink? = null
    private var screenChannel: EventChannel? = null
    private var screenSink: EventChannel.EventSink? = null
    private var deeplinkChannel: EventChannel? = null
    private var deeplinkSink: EventChannel.EventSink? = null
    private val screenStateReceiver = ScreenStateReceiver()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        pipChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, "$PLUGIN_NAMESPACE/pip")
        pipChannel!!.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
                pipSink = sink
            }

            override fun onCancel(args: Any?) {
                pipSink?.endOfStream()
                pipSink = null
            }
        })
        screenChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, "$PLUGIN_NAMESPACE/screen")
        screenChannel!!.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
                screenSink = sink
                screenSink?.success(SCREEN_MODE_PRESENT)
            }

            override fun onCancel(args: Any?) {
                screenSink?.endOfStream()
                screenSink = null
            }
        })
        deeplinkChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, "$PLUGIN_NAMESPACE/deeplink")
        deeplinkChannel!!.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
                deeplinkSink = sink
                deeplinkSink?.success(deeplink)
            }

            override fun onCancel(args: Any?) {
                deeplinkSink?.endOfStream()
                deeplinkSink = null
            }
        })
    }

    override fun onFlutterUiDisplayed() {
        if (Settings.Global.getFloat(
                context.contentResolver,
                Settings.Global.TRANSITION_ANIMATION_SCALE,
                1.0f
            ) == 0.0f
        ) {
            flutterEngine?.accessibilityChannel?.setAccessibilityFeatures(0)
        }
        super.onFlutterUiDisplayed()
    }

    override fun onResume() {
        super.onResume()
        val mScreenStatusFilter = IntentFilter()
        mScreenStatusFilter.addAction(Intent.ACTION_SCREEN_ON)
        mScreenStatusFilter.addAction(Intent.ACTION_SCREEN_OFF)
        mScreenStatusFilter.addAction(Intent.ACTION_USER_PRESENT)
        context.registerReceiver(screenStateReceiver, mScreenStatusFilter)
    }

    override fun onNewIntent(intent: Intent) {
        if (intent.scheme == "ghosten") {
            deeplink = intent.data?.toString()
            deeplinkSink?.success(deeplink)
        }
        super.onNewIntent(intent)
    }

    override fun onPause() {
        super.onPause()
        context.unregisterReceiver(screenStateReceiver)
    }

    @TargetApi(API_LEVELS.API_34)
    @RequiresApi(API_LEVELS.API_34)
    fun startBackGesture(backEvent: BackEvent) {
        ensureAlive()
        if (flutterEngine != null) {
            flutterEngine!!.backGestureChannel.startBackGesture(backEvent)
        }
    }

    @TargetApi(API_LEVELS.API_34)
    @RequiresApi(API_LEVELS.API_34)
    fun updateBackGestureProgress(backEvent: BackEvent) {
        ensureAlive()
        if (flutterEngine != null) {
            flutterEngine!!.backGestureChannel.updateBackGestureProgress(backEvent)
        }
    }

    @TargetApi(API_LEVELS.API_34)
    @RequiresApi(API_LEVELS.API_34)
    fun commitBackGesture() {
        ensureAlive()
        if (flutterEngine != null) {
            flutterEngine!!.backGestureChannel.commitBackGesture()
        }
    }

    @TargetApi(API_LEVELS.API_34)
    @RequiresApi(API_LEVELS.API_34)
    fun cancelBackGesture() {
        ensureAlive()
        if (flutterEngine != null) {
            flutterEngine!!.backGestureChannel.cancelBackGesture()
        }
    }

    private fun ensureAlive() {
        checkNotNull(host) { "Cannot execute method on a destroyed FlutterActivityAndFragmentDelegate." }
    }

    fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        pipSink?.success(isInPictureInPictureMode)
    }

    inner class ScreenStateReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val action = intent?.action
            if (Intent.ACTION_SCREEN_ON == action) {
                screenSink?.success(SCREEN_MODE_ON)
            } else if (Intent.ACTION_SCREEN_OFF == action) {
                screenSink?.success(SCREEN_MODE_OFF)
            } else if (Intent.ACTION_USER_PRESENT == action) {
                screenSink?.success(SCREEN_MODE_PRESENT)
            }
        }
    }

    companion object {
        const val PLUGIN_NAMESPACE = "com.ghosten.player"
        const val SCREEN_MODE_ON = "on"
        const val SCREEN_MODE_OFF = "off"
        const val SCREEN_MODE_PRESENT = "present"
    }
}