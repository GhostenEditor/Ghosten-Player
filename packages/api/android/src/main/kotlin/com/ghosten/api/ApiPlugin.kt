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
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
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
    private val coroutineScope = CoroutineScope(Dispatchers.Main + Job())

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        binaryMessenger = flutterPluginBinding.binaryMessenger
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, PLUGIN_NAMESPACE)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "arch" -> result.success(arch())
            "getLocalIpAddress" -> result.success(getLocalIpAddress())
            "requestStoragePermission" -> requestStoragePermission(result)
            "databasePath" -> result.success(apiService?.databasePath?.path)
            "initialized" -> {
                if (serviceConnected) {
                    result.success(apiService?.apiInitializedPort())
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

            "log" -> {
                apiService?.log(call.argument<Int>("level")!!, call.argument<String>("message")!!)
            }

            else -> {
                if (apiService == null) {
                    return result.error("50000", "Service Start Failed", null);
                }
                coroutineScope.launch(Dispatchers.Main) {
                    if (call.method.endsWith("/cb")) {
                        val id = UUID.randomUUID().toString()
                        result.success("{ \"id\": \"$id\" }")
                        val eventChannel = EventChannel(binaryMessenger, "$PLUGIN_NAMESPACE/update/$id")
                        var finished = false
                        var errorResp: ApiData? = null
                        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
                            override fun onListen(args: Any?, eventSink: EventChannel.EventSink?) {
                                if (eventSink != null) {
                                    if (finished) {
                                        if (errorResp != null) {
                                            if (errorResp!!.isOk()) {
                                                result.success(errorResp!!.msg)
                                            } else {
                                                result.error(
                                                    errorResp!!.code.toString(),
                                                    errorResp!!.msg,
                                                    null
                                                )
                                            }
                                        }
                                        eventSink.endOfStream()
                                    } else {
                                        eventSinkMap[id] = eventSink
                                    }
                                }
                            }

                            override fun onCancel(args: Any?) {
                                eventSinkMap.remove(id)?.endOfStream()
                            }
                        })

                        val data = withContext(Dispatchers.IO) {
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
                        }
                        if (data == null) {
                            eventSinkMap.remove(id)?.endOfStream()
                        } else {
                            val apiData = ApiData(data)
                            if (apiData.isOk()) {
                                eventSinkMap.remove(id)?.endOfStream()
                            } else {
                                if (eventSinkMap[id] != null) {
                                    eventSinkMap[id]?.error(apiData.code.toString(), apiData.msg, null)
                                } else {
                                    errorResp = apiData
                                }
                                eventSinkMap.remove(id)?.endOfStream()
                            }
                        }
                        finished = true
                    } else {
                        val data = withContext(Dispatchers.IO) {
                            apiService?.call(
                                call.method,
                                call.argument<String>("data")!!,
                                call.argument<String>("params")!!,
                            )
                        }
                        if (data == null) {
                            result.success(null)
                        } else {
                            val apiData = ApiData(data)
                            if (apiData.isOk()) {
                                result.success(apiData.msg)
                            } else {
                                result.error(apiData.code.toString(), apiData.msg, null)
                            }
                        }
                    }
                }.start()
            }
        }
    }

    inner class ApiData(val data: ByteArray) {
        val code: Int
        val msg: String

        init {
            code = parse_u8(data.get(0)) shl 8 or parse_u8(data.get(1))
            msg = data.copyOfRange(2, data.size).toString(Charsets.UTF_8)
        }

        fun isOk(): Boolean {
            return code / 10000 == 2
        }

        fun parse_u8(b: Byte): Int {
            return b.let {
                if (it < 0) {
                    it.toInt() + 256
                } else {
                    it.toInt()
                }
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
        methodCallResult?.success(apiService?.apiInitializedPort())
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

    fun requestStoragePermission(result: Result) {
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.S_V2 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (activity.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED || activity.checkSelfPermission(
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
                ) != PackageManager.PERMISSION_GRANTED
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
            if (activity.checkSelfPermission(Manifest.permission.READ_MEDIA_VIDEO) != PackageManager.PERMISSION_GRANTED) {
                val permissions = arrayOf(
                    Manifest.permission.READ_MEDIA_VIDEO,
                    Manifest.permission.READ_MEDIA_AUDIO,
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
