package com.ghosten.api

import android.Manifest
import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.os.Build
import android.os.IBinder
import android.view.WindowManager
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.IOException
import java.net.InetAddress
import java.net.NetworkInterface
import java.util.*

class ApiPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ServiceConnection,
    PluginRegistry.RequestPermissionsResultListener {
    private lateinit var channel: MethodChannel
    private lateinit var binaryMessenger: BinaryMessenger
    private lateinit var activity: Activity
    private var apiService: ApiService? = null
    private val eventSinkMap: MutableMap<String, EventChannel.EventSink> = mutableMapOf()
    private var methodCallResult: Result? = null
    private var serviceConnected = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        binaryMessenger = flutterPluginBinding.binaryMessenger
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, PLUGIN_NAMESPACE)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "arch" -> result.success(arch())
            "supportedHdrTypes" -> result.success(getSupportedHdrTypes())
            "getLocalIpAddress" -> result.success(getLocalIpAddress())
            "requestStoragePermission" -> requestStoragePermission(result)
            "databasePath" -> result.success(apiService?.databasePath?.path)
            "initialized" -> {
                if (serviceConnected) {
                    result.success(apiService?.apiInitialized())
                } else {
                    methodCallResult = result
                }
            }

            "syncData" -> {
                try {
                    apiService?.syncData(call.arguments as String)
                } catch (e: IOException) {
                    result.error(TAG, "Sync Data Failed", e)
                }
            }

            "rollbackData" -> {
                try {
                    apiService?.rollbackData()
                    result.success(null)
                } catch (e: IOException) {
                    result.error(TAG, "Rollback Data Failed", e)
                }
            }

            "resetData" -> {
                try {
                    apiService?.resetData()
                    result.success(null)
                } catch (e: IOException) {
                    result.error(TAG, "Reset Failed", e)
                }
            }


            else -> {
                if (apiService == null) {
                    return result.error("500", resolveErrorCode("500"), "Service Start Failed");
                }
                Thread {
                    if (call.method.endsWith("/cb")) {
                        val id = UUID.randomUUID().toString()
                        activity.runOnUiThread {
                            result.success("{ \"id\": \"$id\" }")
                        }
                        val eventChannel = EventChannel(binaryMessenger, "$PLUGIN_NAMESPACE/update/$id")
                        var finished = false
                        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
                            override fun onListen(args: Any?, eventSink: EventChannel.EventSink?) {
                                if (eventSink != null) {
                                    if (finished) {
                                        eventSink.endOfStream()
                                    } else {
                                        eventSinkMap[id] = eventSink
                                    }
                                }
                            }

                            override fun onCancel(args: Any?) {
                                activity.runOnUiThread {
                                    eventSinkMap.remove(id)?.endOfStream()
                                }
                            }
                        })

                        apiService?.callWithCallback(
                            call.method,
                            call.argument<String>("data")!!,
                            call.argument<String>("params")!!,
                            object : ApiMethodHandler {
                                override fun onApiMethodUpdate(data: String) {
                                    activity.runOnUiThread {
                                        eventSinkMap[id]?.success(data)
                                    }
                                }
                            })
                        activity.runOnUiThread {
                            eventSinkMap.remove(id)?.endOfStream()
                        }
                        finished = true
                    } else {
                        val data = apiService?.call(
                            call.method,
                            call.argument<String>("data")!!,
                            call.argument<String>("params")!!,
                        )
                        if (data == null) {
                            activity.runOnUiThread {
                                result.success(null)
                            }
                        } else {
                            val code = data.substring(0, 3)
                            val resp = data.substring(3)
                            activity.runOnUiThread {
                                if (code == "200") {
                                    result.success(resp)
                                } else {
                                    result.error(code, resolveErrorCode(code), resp)
                                }
                            }
                        }
                    }
                }.start()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        val intent = Intent(binding.activity.applicationContext, ApiService::class.java)
        activity.startService(intent)
        activity.bindService(intent, this, Context.BIND_AUTO_CREATE)
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
        activity.unbindService(this)
    }

    override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
        val binder = service as ApiService.LocalBinder
        apiService = binder.getService()
        serviceConnected = true
        methodCallResult?.success(apiService?.apiInitialized())
        methodCallResult = null
    }

    override fun onServiceDisconnected(name: ComponentName?) {
        serviceConnected = false
        apiService = null
    }

    override fun onRequestPermissionsResult(requestCode: Int, resultCode: Array<out String>, data: IntArray): Boolean {
        return when (requestCode) {
            REQUEST_STORAGE_PERMISSION -> {
                methodCallResult?.success(data.all { it == PackageManager.PERMISSION_GRANTED })
                methodCallResult = null
                true
            }

            else -> false
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun arch(): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && Build.SUPPORTED_ABIS.contains("arm64-v8a")) {
            "arm64"
        } else {
            "arm"
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

    private fun getSupportedHdrTypes(): IntArray {
        val wm = activity.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val display = wm.defaultDisplay
        return display.hdrCapabilities.supportedHdrTypes
    }

    private fun resolveErrorCode(code: String): String? {
        val message = when (code) {
            "300" -> R.string.api_response_multiple_choices
            "400" -> R.string.api_response_bad_request
            "401" -> R.string.api_response_unauthorized
            "403" -> R.string.api_response_forbidden
            "404" -> R.string.api_response_not_found
            "405" -> R.string.api_response_method_not_allowed
            "408" -> R.string.api_response_timeout
            "429" -> R.string.api_response_too_many_requests
            "500" -> R.string.api_response_internal_error
            "501" -> R.string.api_response_not_implemented
            "504" -> R.string.api_response_not_implemented
            else -> null
        }
        return if (message != null) activity.getString(message) else null
    }

    fun requestStoragePermission(result: Result) {
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.S_V2 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (activity.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED ||
                activity.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
            ) {
                val permissions = arrayOf(
                    Manifest.permission.READ_EXTERNAL_STORAGE,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE,
                )
                methodCallResult = result
                return activity.requestPermissions(permissions, REQUEST_STORAGE_PERMISSION)
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (activity.checkSelfPermission(Manifest.permission.READ_MEDIA_VIDEO) != PackageManager.PERMISSION_GRANTED
            ) {
                val permissions = arrayOf(
                    Manifest.permission.READ_MEDIA_VIDEO,
                )
                methodCallResult = result
                return activity.requestPermissions(permissions, REQUEST_STORAGE_PERMISSION)
            }
        }
        result.success(true)
    }

    companion object {
        const val PLUGIN_NAMESPACE = "com.ghosten.player/api"
        const val REQUEST_STORAGE_PERMISSION = 7454
        const val TAG = "API Error"
    }
}
