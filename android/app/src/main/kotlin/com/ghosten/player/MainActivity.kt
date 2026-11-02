package com.ghosten.player

import android.app.Activity
import android.app.Application
import android.app.PictureInPictureParams
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.TransparencyMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class MainActivity : FlutterActivity(), MethodCallHandler, Application.ActivityLifecycleCallbacks {
    private var methodChannel: MethodChannel? = null
    private var deeplink: String? = null
    private var pipChannel: EventChannel? = null
    private var pipSink: EventChannel.EventSink? = null
    private var screenChannel: EventChannel? = null
    private var screenSink: EventChannel.EventSink? = null
    private var deeplinkChannel: EventChannel? = null
    private var deeplinkSink: EventChannel.EventSink? = null
    private val screenStateReceiver = ScreenStateReceiver()
    private var notification: Notification? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        application.registerActivityLifecycleCallbacks(this)
        notification = Notification(activity, flutterEngine.dartExecutor.binaryMessenger)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PLUGIN_NAMESPACE)
        methodChannel!!.setMethodCallHandler(this)
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

    override fun onMethodCall(
        call: MethodCall, result: MethodChannel.Result
    ) {
        when (call.method) {
            "initialized" -> result.success(
                if (intent.scheme == "content") {
                    listOf(androidDeviceType().toString(), intent.data?.toString())
                } else {
                    listOf(androidDeviceType().toString())
                }
            )

            "requestPip" -> result.success(requestPip())
            "canPip" -> result.success(activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE))
            "arch" -> result.success(arch())
            else -> result.notImplemented()
        }
    }

    override fun getTransparencyMode(): TransparencyMode {
        return TransparencyMode.transparent
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        pipSink?.success(isInPictureInPictureMode)
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
    }

    override fun onResume() {
        super.onResume()
        val mScreenStatusFilter = IntentFilter()
        mScreenStatusFilter.addAction(Intent.ACTION_SCREEN_ON)
        mScreenStatusFilter.addAction(Intent.ACTION_SCREEN_OFF)
        mScreenStatusFilter.addAction(Intent.ACTION_USER_PRESENT)
        context.registerReceiver(screenStateReceiver, mScreenStatusFilter)
    }


    override fun onPause() {
        super.onPause()
        context.unregisterReceiver(screenStateReceiver)
    }


    override fun onNewIntent(intent: Intent) {
        if (intent.scheme == "ghosten") {
            deeplink = intent.data?.toString()
            deeplinkSink?.success(deeplink)
        }
        super.onNewIntent(intent)
    }

    private fun androidDeviceType(): Int {
        return if (resources.configuration.screenLayout and Configuration.SCREENLAYOUT_SIZE_MASK >= Configuration.SCREENLAYOUT_SIZE_LARGE) {
            DEVICE_TYPE_PAD
        } else {
            DEVICE_TYPE_PHONE
        }
    }


    private fun arch(): String {
        return if (Build.SUPPORTED_ABIS.isNotEmpty()) {
            Build.SUPPORTED_ABIS[0]
        } else {
            "unknown"
        }
    }

    private fun requestPip(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE) && activity.enterPictureInPictureMode(
            PictureInPictureParams.Builder()
                .build()
        )
    }

    override fun onActivityCreated(p0: Activity, p1: Bundle?) {
    }

    override fun onActivityStarted(p0: Activity) {
    }

    override fun onActivityResumed(p0: Activity) {
//        play()
    }

    override fun onActivityPaused(p0: Activity) {
//        pause()
    }

    override fun onActivityStopped(p0: Activity) {
    }

    override fun onActivitySaveInstanceState(p0: Activity, p1: Bundle) {
    }

    override fun onActivityDestroyed(p0: Activity) {
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
        private const val PLUGIN_NAMESPACE = "com.ghosten.player"
        private const val DEVICE_TYPE_PHONE = 0
        private const val DEVICE_TYPE_PAD = 1
        private const val SCREEN_MODE_ON = "on"
        private const val SCREEN_MODE_OFF = "off"
        private const val SCREEN_MODE_PRESENT = "present"
    }
}
