package com.ghosten.player_view

import android.app.Activity
import android.app.PictureInPictureParams
import android.content.pm.PackageManager
import android.os.Build
import androidx.media3.common.C
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.InetAddress
import java.net.NetworkInterface
import java.util.*

class PlayerViewPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var mChannel: MethodChannel
    private lateinit var activity: Activity
    private var mPlayerView: PlayerView? = null
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mChannel = MethodChannel(binding.binaryMessenger, "com.ghosten.player/player")
        mChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "canPip" -> result.success(activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE))
            "requestPip" -> result.success(requestPip())
            "getLocalIpAddress" -> result.success(getLocalIpAddress())
            else -> {
                when (call.method) {
                    "init" -> {
                        if (mPlayerView == null) mPlayerView = PlayerView(
                            activity.applicationContext,
                            activity,
                            mChannel,
                            call.argument("extensionRendererMode"),
                            call.argument("enableDecoderFallback"),
                            call.argument("language"),
                        )
                    }

                    "play" -> mPlayerView?.play()
                    "pause" -> mPlayerView?.pause()
                    "next" -> mPlayerView?.next(call.arguments as Int)
                    "previous" -> mPlayerView?.previous()
                    "seekTo" -> mPlayerView?.seekTo((call.arguments as Int).toLong())
                    "updateSource" -> mPlayerView?.updateSource(call.argument("source")!!, call.argument("index")!!)
                    "setSources" -> mPlayerView?.setSources(call.argument("playlist")!!, call.argument("index")!!)
                    "setTransform" -> mPlayerView?.setTransform(call.argument("matrix")!!)
                    "setAspectRatio" -> mPlayerView?.setAspectRatio((call.arguments as Double?)?.toFloat())
                    "dispose" -> {
                        mPlayerView?.dispose()
                        mPlayerView = null
                    }

                    "setVolume" -> mPlayerView?.setVolume((call.arguments as Double).toFloat())
                    "setTrack" -> mPlayerView?.setTrack(
                        when (call.argument<String>("type")) {
                            "video" -> C.TRACK_TYPE_VIDEO
                            "audio" -> C.TRACK_TYPE_AUDIO
                            "sub" -> C.TRACK_TYPE_TEXT
                            else -> return result.notImplemented()
                        }, call.argument("id")
                    )

                    "setSkipPosition" ->
                        mPlayerView?.setSkipPosition(
                            call.argument("type")!!,
                            call.argument("list")!!
                        )

                    "getVideoThumbnail" -> return mPlayerView!!.getVideoThumbnail(
                        result,
                        call.argument<Long>("position")!!
                    )

                    "setPlaybackSpeed" -> mPlayerView?.setPlaybackSpeed((call.arguments as Double).toFloat())
                    else -> return result.notImplemented()
                }
                result.success(null)
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            activity.setPictureInPictureParams(
                PictureInPictureParams.Builder()
                    .setAutoEnterEnabled(true)
                    .build()
            )
        }
    }

    fun requestPip(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (!activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)) {
                return false
            }
            if (mPlayerView?.canEnterPictureInPicture() != true) {
                return false
            }
            val params = mPlayerView?.getPictureInPictureParams()
            if (params != null) {
                return activity.enterPictureInPictureMode(params)
            } else {
                activity.enterPictureInPictureMode()
                return true
            }
        } else {
            return false
        }
    }

    private fun getLocalIpAddress(): String? {
        val interfaces = Collections.list(NetworkInterface.getNetworkInterfaces())
        for (intf in interfaces) {
            val addrs = Collections.list(intf.inetAddresses)
            for (addr in addrs) {
                if (!addr.isLoopbackAddress && addr is InetAddress) {
                    val sAddr = addr.hostAddress
                    if (sAddr != null && sAddr.indexOf(':') < 0) {
                        return sAddr
                    }
                }
            }
        }
        return null
    }
}
