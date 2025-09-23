package com.ghosten.openlist

import openlistlib.LogCallback
import openlistlib.Event
import openlistlib.Openlistlib
import android.content.Context
import android.content.res.AssetManager
import android.os.Build
import android.util.Log
import dalvik.system.DexClassLoader
import dalvik.system.InMemoryDexClassLoader
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileOutputStream
import java.nio.ByteBuffer
import java.util.Arrays
import java.util.zip.ZipFile

/** OpenlistPlugin */
class OpenlistPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        const val TAG = "OpenList"
    }

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var openlist: Openlist
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.ghosten.player/openlist")
        channel.setMethodCallHandler(this)
        openlist = Openlist(context.filesDir.path + "/openlist")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "init" -> openlist.init()
            "shutdown" -> openlist.shutdown()
            "setAdminPassword" -> openlist.setAdminPassword(call.arguments as String)
            "isRunning" -> return result.success(openlist.isRunning())
            else -> return result.notImplemented()
        }
        result.success(null)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    inner class Openlist(private val dataDir: String) : Event, LogCallback {

        fun init() {
            if (isRunning()) return
            runCatching {
                Openlistlib.setConfigData(dataDir)
                Openlistlib.setConfigLogStd(false)
                Openlistlib.setConfigDebug(false)
                Openlistlib.init(this, this)
                Openlistlib.start()
            }.onFailure {
                Log.e(TAG, "init:", it)
            }
        }

        fun setAdminPassword(pwd: String) {
            if (!isRunning()) init()
            Log.d(TAG, "setAdminPassword: $dataDir")
            Openlistlib.setConfigData(dataDir)
            Openlistlib.setAdminPassword(pwd)
        }

        fun isRunning(): Boolean {
            Log.d(TAG, Openlistlib.isRunning("http").toString())
            return Openlistlib.isRunning("http")
        }

        fun shutdown() {
            Log.d(TAG, "shutdown")
            runCatching {
                Openlistlib.shutdown(5000)
            }.onFailure {
            }
        }

        override fun onLog(p0: Short, p1: Long, p2: String?) {
        }

        override fun onProcessExit(p0: Long) {
        }

        override fun onShutdown(p0: String?) {
        }

        override fun onStartError(p0: String?, p1: String?) {
        }
    }
}
