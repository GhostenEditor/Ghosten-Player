package com.ghosten.player_view

import android.app.Activity
import android.app.PictureInPictureParams
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.media3.common.C
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.net.InetAddress
import java.net.NetworkInterface
import java.util.*

class PlayerViewFactory(private val channel: MethodChannel) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    lateinit var mPlayerView: PlayerView
    lateinit var activity: Activity
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        mPlayerView = PlayerView(
            context,
            activity,
            channel,
            (args as HashMap<*, *>)["extensionRendererMode"] as Int?,
            args["enableDecoderFallback"] as Boolean?,
            args["language"] as String?,
        )
        return mPlayerView
    }
}

class PlayerViewPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var mChannel: MethodChannel
    private lateinit var mPlayerViewFactory: PlayerViewFactory
    private lateinit var activity: Activity
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mChannel = MethodChannel(binding.binaryMessenger, "com.ghosten.player_view")
        mChannel.setMethodCallHandler(this)
        mPlayerViewFactory = PlayerViewFactory(mChannel)
        binding.platformViewRegistry.registerViewFactory("<video-player-view>", mPlayerViewFactory)
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
                val mPlayerView = mPlayerViewFactory.mPlayerView
                when (call.method) {
                    "play" -> mPlayerView.play()
                    "pause" -> mPlayerView.pause()
                    "next" -> mPlayerView.next(call.arguments as Int)
                    "previous" -> mPlayerView.previous()
                    "seekTo" -> mPlayerView.seekTo((call.arguments as Int).toLong())
                    "setSources" -> mPlayerView.setSources(call.argument("playlist")!!, call.argument("index")!!)
                    "updateSource" -> mPlayerView.updateSource(call.argument("source")!!, call.argument("index")!!)
                    "hide" -> return mPlayerView.hide(result)
                    "setVolume" -> mPlayerView.setVolume((call.arguments as Double).toFloat())
                    "setTrack" -> mPlayerView.setTrack(
                        when (call.argument<String>("type")) {
                            "video" -> C.TRACK_TYPE_VIDEO
                            "audio" -> C.TRACK_TYPE_AUDIO
                            "sub" -> C.TRACK_TYPE_TEXT
                            else -> return result.notImplemented()
                        }, call.argument("id")
                    )

                    "setSkipPosition" ->
                        mPlayerView.setSkipPosition(
                            call.argument("type")!!,
                            call.argument("list")!!
                        )

                    "getVideoThumbnail" -> return mPlayerView.getVideoThumbnail(
                        result,
                        call.argument<Long>("position")!!
                    )

                    "setPlaybackSpeed" -> mPlayerView.setPlaybackSpeed((call.arguments as Double).toFloat())
                    else -> return result.notImplemented()
                }
                result.success(null)
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        mPlayerViewFactory.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        mPlayerViewFactory.activity = binding.activity
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
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (!activity.packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)) {
                return false
            }
            if (!mPlayerViewFactory.mPlayerView.canEnterPictureInPicture()) {
                return false
            }
            val params = mPlayerViewFactory.mPlayerView.getPictureInPictureParams()
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
