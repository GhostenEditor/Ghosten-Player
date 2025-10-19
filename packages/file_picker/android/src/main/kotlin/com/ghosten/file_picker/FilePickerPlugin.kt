package com.ghosten.file_picker

import android.content.Context
import android.os.Build
import android.os.Environment
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

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
            "downloadPath" -> result.success(
                Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_DOWNLOADS
                ).path
            )

            "cachePath" -> result.success(context.cacheDir.path)
            "filePath" -> result.success(context.filesDir.path)
            "externalUsbStorages" -> result.success(getUniversalUSBPath())
            else -> result.notImplemented()
        }
    }

    private fun getUniversalUSBPath(): List<HashMap<String, String>> {
        val storageManager = context.getSystemService(Context.STORAGE_SERVICE) as StorageManager
        val storageVolumes: List<StorageVolume> = storageManager.storageVolumes
        val list = mutableListOf<HashMap<String, String>>()

        for (volume in storageVolumes) {
            if (volume.isRemovable && volume.state == Environment.MEDIA_MOUNTED) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    list.add(HashMap<String, String>().apply {
                        this["path"] = volume.directory!!.absolutePath
                        this["desc"] = volume.getDescription(context)
                    })
                } else {
                    try {
                        val getPath = volume.javaClass.getMethod("getPath")
                        list.add(HashMap<String, String>().apply {
                            this["path"] = getPath.invoke(volume) as String
                            this["desc"] = ""
                        })
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
        }
        return list
    }
}
