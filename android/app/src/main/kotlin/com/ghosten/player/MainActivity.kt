package com.ghosten.player

import android.app.UiModeManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
    private var externalUrl: String? = null
    private var deeplink: String? = null
    private var channel: MethodChannel? = null
    private var pipChannel: EventChannel? = null
    private var pipSink: EventChannel.EventSink? = null
    private var screenChannel: EventChannel? = null
    private var screenSink: EventChannel.EventSink? = null
    private var deeplinkChannel: EventChannel? = null
    private var deeplinkSink: EventChannel.EventSink? = null
    private val screenStateReceiver = ScreenStateReceiver()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PLUGIN_NAMESPACE)
        channel!!.setMethodCallHandler(this)
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

    override fun onResume() {
        super.onResume()
        if (intent.scheme == "content") {
            externalUrl = intent.data?.toString()
        }
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

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration?) {
        pipSink?.success(isInPictureInPictureMode)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "androidDeviceType" -> result.success(androidDeviceType())
            "externalUrl" -> result.success(externalUrl)
            else -> result.notImplemented()
        }
    }

    private fun androidDeviceType(): Int {
        val uiModeManager = getSystemService(UI_MODE_SERVICE) as UiModeManager
        return if (uiModeManager.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION) {
            DEVICE_TYPE_TV
        } else if (context.resources.configuration.screenLayout and Configuration.SCREENLAYOUT_SIZE_MASK >= Configuration.SCREENLAYOUT_SIZE_LARGE) {
            DEVICE_TYPE_PAD
        } else {
            DEVICE_TYPE_PHONE
        }
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
        const val DEVICE_TYPE_TV = 0
        const val DEVICE_TYPE_PAD = 1
        const val DEVICE_TYPE_PHONE = 2
    }
}
