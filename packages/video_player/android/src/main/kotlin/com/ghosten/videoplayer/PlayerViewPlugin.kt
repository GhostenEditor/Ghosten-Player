package com.ghosten.videoplayer

import android.app.Activity
import android.app.PictureInPictureParams
import android.content.pm.PackageManager
import android.os.Build
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
    private var mPlayerView: BasePlayerView? = null
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
                        if (mPlayerView == null)
                            mPlayerView = Media3PlayerView(
                                activity.applicationContext,
                                activity,
                                mChannel,
                                call.argument("extensionRendererMode"),
                                call.argument("enableDecoderFallback"),
                                call.argument("language"),
                                call.argument("subtitleStyle"),
                                call.argument("width"),
                                call.argument("height"),
                                call.argument("top"),
                                call.argument("left"),
                                call.argument("autoPip") ?: true,
                            )
                    }

                    else -> {
                        when (call.method) {
                            "play" -> mPlayerView?.play()
                            "pause" -> mPlayerView?.pause()
                            "next" -> mPlayerView?.next(call.arguments as Int)
                            "seekTo" -> mPlayerView?.seekTo((call.arguments as Int).toLong())
                            "updateSource" -> mPlayerView?.updateSource(
                                call.argument("source")!!,
                                call.argument("index")!!
                            )

                            "setSource" -> mPlayerView?.setSource(call.arguments as HashMap<String, Any>?)
                            "setTransform" -> mPlayerView?.setTransform(call.argument("matrix")!!)
                            "setAspectRatio" -> mPlayerView?.setAspectRatio((call.arguments as Double?)?.toFloat())
                            "fullscreen" -> mPlayerView?.fullscreen(call.arguments as Boolean)
                            "dispose" -> {
                                mPlayerView?.dispose()
                                mPlayerView = null
                            }

                            "setTrack" -> mPlayerView?.setTrack(
                                call.argument<String>("type"),
                                call.argument<String?>("id")
                            )

                            "getVideoThumbnail" -> return mPlayerView!!.getVideoThumbnail(
                                result,
                                call.argument<Long>("position")!!
                            )

                            "setPlaybackSpeed" -> mPlayerView?.setPlaybackSpeed((call.arguments as Double).toFloat())
                            "setPlayerOption" -> mPlayerView?.setPlayerOption(
                                call.argument("name")!!,
                                call.argument("value")!!
                            )

                            "setSubtitleStyle" -> mPlayerView?.setSubtitleStyle(call.argument("style")!!)

                            else -> return result.notImplemented()
                        }
                    }


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
                PictureInPictureParams.Builder().setAutoEnterEnabled(true).build()
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
