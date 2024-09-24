package com.ghosten.file_picker

import android.content.Context
import android.os.Environment
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class FilePickerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.ghosten.file_picker")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "externalStoragePath" -> result.success(Environment.getExternalStorageDirectory().path)
            "moviePath" -> result.success(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES).path)
            "musicPath" -> result.success(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC).path)
            "downloadPath" -> result.success(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).path)
            "cachePath" -> result.success(context.cacheDir.path)
            else -> result.notImplemented()
        }
    }
}
