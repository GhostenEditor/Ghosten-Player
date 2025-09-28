package com.ghosten.videoplayer

import android.app.Activity
import android.app.Application
import android.app.PictureInPictureParams
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.media3.common.util.UnstableApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.InetAddress
import java.net.NetworkInterface
import java.util.Collections

class PlayerViewPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
    Application.ActivityLifecycleCallbacks {
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

    @UnstableApi
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "canPip" -> result.success(activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE))
            "requestPip" -> result.success(requestPip())
            "getLocalIpAddress" -> result.success(getLocalIpAddress())
            else -> {
                when (call.method) {
                    "init" -> {
                        if (mPlayerView == null)
                            when (call.argument("type") as String?) {
                                "media3" -> {
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

                                "mpv" -> {
                                    try {
                                        mPlayerView = MPVPlayerView(
                                            activity.applicationContext,
                                            activity,
                                            mChannel,
                                            true,
                                            call.argument("language"),
                                            call.argument("width"),
                                            call.argument("height"),
                                            call.argument("top"),
                                            call.argument("left"),
                                            call.argument("mpvVersion") ?: "",
                                        )
                                    } catch (e: Exception) {
                                        return result.error(e.toString(), e.message, null)
                                    }
                                }
                            }
                    }

                    else -> {
                        when (call.method) {
                            "play" -> mPlayerView?.play()
                            "pause" -> mPlayerView?.pause()
                            "next" -> mPlayerView?.next(call.arguments as Int)
                            "seekTo" -> mPlayerView?.seekTo((call.arguments as Int).toLong())
                            "updateSource" -> mPlayerView?.updateSource(call.argument("source")!!)
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
        activity.application.registerActivityLifecycleCallbacks(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity.application.unregisterActivityLifecycleCallbacks(this)
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

    private fun requestPip(): Boolean {
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

    override fun onActivityCreated(p0: Activity, p1: Bundle?) {
    }

    override fun onActivityStarted(p0: Activity) {
    }

    override fun onActivityResumed(p0: Activity) {
        mPlayerView?.play()
    }

    override fun onActivityPaused(p0: Activity) {
        mPlayerView?.pause()
    }

    override fun onActivityStopped(p0: Activity) {
    }

    override fun onActivitySaveInstanceState(p0: Activity, p1: Bundle) {
    }

    override fun onActivityDestroyed(p0: Activity) {
    }
}
