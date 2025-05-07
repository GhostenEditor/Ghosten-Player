package com.ghosten.api

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.Environment
import android.os.IBinder
import androidx.annotation.Keep
import java.io.File
import java.io.IOException
import java.net.ServerSocket

@Keep
interface ApiMethodHandler {
    fun onApiMethodUpdate(data: String)
}


class ApiService : Service() {
    private external fun apiStart(
        port: Int,
        dbPath: String,
        downloadPath: String,
        cachePath: String,
        logPath: String
    ): Boolean

    private external fun apiStop()
    private external fun apiInitialized(): Boolean

    external fun call(method: String, data: String, params: String): ByteArray
    external fun callWithCallback(method: String, data: String, params: String, callback: ApiMethodHandler): ByteArray
    external fun log(level: Int, message: String)

    private var apiThread: ProxyThread? = null
    private val binder = LocalBinder()
    private var loaded = false
    private var port = 38916

    val databasePath: File
        get() {
            return applicationContext.getDatabasePath(DB_NAME)
        }

    inner class LocalBinder : Binder() {
        fun getService(): ApiService? = if (loaded) this@ApiService else null
    }

    override fun onCreate() {
        try {
            System.loadLibrary(LIB_NAME)
        } catch (e: UnsatisfiedLinkError) {
            return
        }
        val databaseDir = databasePath.parentFile
        if (databaseDir?.exists() != true) {
            databaseDir!!.mkdirs()
        }
        port = ServerSocket(0).use { serverSocket ->
            serverSocket.localPort
        }
        loaded = true
        apiThread = ProxyThread()
        apiThread?.start()
        super.onCreate()
    }

    override fun onDestroy() {
        super.onDestroy()
        apiThread?.cancel()
    }

    override fun onBind(intent: Intent): IBinder {
        return binder
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return super.onStartCommand(intent, flags, startId)
    }

    fun syncData(filePath: String) {
        val file = File(filePath)
        if (file.exists()) {
            val oldFile = databasePath
            if (oldFile.exists()) {
                oldFile.renameTo(applicationContext.getDatabasePath(DB_BACKUP_NAME))
            }
            file.renameTo(oldFile)
            apiThread?.restart()
        } else {
            throw IOException("File of path '${filePath}' is not exists")
        }
    }

    fun rollbackData() {
        val backupFile = applicationContext.getDatabasePath(DB_BACKUP_NAME)
        if (backupFile.exists()) {
            backupFile.renameTo(databasePath)
            apiThread?.restart()
        } else {
            throw IOException("There's no data to rollback")
        }
    }

    fun resetData() {
        val oldFile = databasePath
        if (oldFile.exists()) {
            if (oldFile.delete()) {
                apiThread?.restart()
            } else {
                throw IOException("Reset Failed")
            }
        }
    }

    public fun apiInitializedPort(): Int? {
        if (apiInitialized()) {
            return port
        } else {
            return null
        }
    }

    private inner class ProxyThread : Thread() {
        private var shouldLoop = true
        override fun run() {
            while (shouldLoop) {
                val cacheFolder =
                    Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS.plus('/' + APP_NAME))
                if (!cacheFolder.exists()) {
                    cacheFolder.mkdir()
                }
                if (!apiStart(
                        port,
                        databasePath.path,
                        Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES).path,
                        cacheFolder.path,
                        applicationContext.cacheDir.path + "/logs",
                    )
                ) {
                    shouldLoop = false
                }
            }
        }

        fun restart() {
            apiStop()
        }

        fun cancel() {
            shouldLoop = false
            apiStop()
        }
    }

    companion object {
        const val DB_NAME = "data"
        const val APP_NAME = "Ghosten Player"
        const val DB_BACKUP_NAME = "data.bak"
        const val LIB_NAME = "api"
    }
}