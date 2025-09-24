package com.ghosten.bluetooth

import android.Manifest
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothServerSocket
import android.bluetooth.BluetoothSocket
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import java.io.DataInputStream
import java.io.DataOutputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.UUID

class BluetoothPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var discoveryChannel: EventChannel
    private lateinit var connectionChannel: EventChannel
    private lateinit var connectedChannel: EventChannel
    private lateinit var mBluetooth: Bluetooth

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = flutterPluginBinding.binaryMessenger
        channel = MethodChannel(messenger, "$PLUGIN_NAMESPACE/methods")
        discoveryChannel = EventChannel(messenger, "$PLUGIN_NAMESPACE/discovery")
        connectionChannel = EventChannel(messenger, "$PLUGIN_NAMESPACE/connection")
        connectedChannel = EventChannel(messenger, "$PLUGIN_NAMESPACE/connected")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (mBluetooth.bluetoothAdapter == null) {
            result.error(Bluetooth.TAG, "Init Failed", NullPointerException("No BluetoothAdapter"))
            return
        }
        when (call.method) {
            "requestEnable" -> {
                mBluetooth.methodCallResult = result
                mBluetooth.requestEnable()
            }

            "startServer" -> {
                mBluetooth.startServer()
                result.success(null)
            }

            "stopServer" -> {
                mBluetooth.stopServer()
                result.success(null)
            }

            "connect" -> {
                mBluetooth.methodCallResult = result
                mBluetooth.connect(call.arguments as String)
            }

            "disconnect" -> {
                mBluetooth.methodCallResult = result
                mBluetooth.disconnect()
            }

            "getBondedDevices" -> {
                mBluetooth.methodCallResult = result
                mBluetooth.getBondedDevices()
            }

            "startDiscovery" -> {
                mBluetooth.methodCallResult = result
                mBluetooth.startDiscovery()
            }

            "isDiscoverable" -> result.success(mBluetooth.isDiscoverable())
            "requestDiscoverable" -> {
                mBluetooth.methodCallResult = result
                mBluetooth.requestDiscoverable(call.arguments as Int)
            }

            "requestPermission" -> {
                mBluetooth.methodCallResult = result
                mBluetooth.requestPermission()
            }

            "writeFile" -> {
                mBluetooth.methodCallResult = result
                mBluetooth.writeFile(call.arguments as String)
            }

            "writeText" -> {
                mBluetooth.methodCallResult = result
                mBluetooth.writeText(call.arguments as String)
            }

            "openSettings" -> {
                mBluetooth.openSettings()
                result.success(null)
            }

            "close" -> {
                mBluetooth.close()
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mBluetooth = Bluetooth(
            binding.activity,
            discoveryChannel,
            connectionChannel,
            connectedChannel
        )
        binding.addActivityResultListener(mBluetooth)
        binding.addRequestPermissionsResultListener(mBluetooth)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }

    companion object {
        const val PLUGIN_NAMESPACE = "com.ghosten.bluetooth"
    }
}

internal class Bluetooth(
    private val activity: Activity,
    discoveryChannel: EventChannel,
    connectionChannel: EventChannel,
    connectedChannel: EventChannel
) : StreamHandler, BroadcastReceiver(), ActivityResultListener, RequestPermissionsResultListener {
    private val bluetoothManager: BluetoothManager =
        activity.getSystemService(BluetoothManager::class.java)
    var bluetoothAdapter: BluetoothAdapter? = bluetoothManager.adapter
    private var discoverySink: EventSink? = null
    private var connectionSink: EventSink? = null
    private var acceptSink: EventSink? = null
    private var connectThread: ConnectThread? = null
    private var acceptThread: AcceptThread? = null
    private var connectionThread: ConnectedThread? = null
    var methodCallResult: Result? = null

    init {
        discoveryChannel.setStreamHandler(this)
        connectionChannel.setStreamHandler(object : StreamHandler {
            override fun onListen(args: Any?, eventSink: EventSink?) {
                connectionSink = eventSink
            }

            override fun onCancel(args: Any?) {
                if (connectionSink != null) {
                    connectionSink!!.endOfStream()
                    connectionSink = null
                }
            }
        })
        connectedChannel.setStreamHandler(object : StreamHandler {
            override fun onListen(args: Any?, eventSink: EventSink?) {
                acceptSink = eventSink
            }

            override fun onCancel(args: Any?) {
                if (acceptSink != null) {
                    acceptSink!!.endOfStream()
                    acceptSink = null
                }
            }
        })
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        val action: String? = intent!!.action
        when (action) {
            BluetoothDevice.ACTION_FOUND -> {
                try {
                    val device: BluetoothDevice =
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)!!
                    if (device.type == BluetoothDevice.DEVICE_TYPE_CLASSIC || device.type == BluetoothDevice.DEVICE_TYPE_DUAL) {
                        discoverySink!!.success(device.toMap())
                    }
                } catch (_: NullPointerException) {
                }

            }

            BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                try {
                    activity.unregisterReceiver(this)
                } catch (_: IllegalArgumentException) {
                }
                bluetoothAdapter!!.cancelDiscovery()
                if (discoverySink != null) {
                    discoverySink!!.endOfStream()
                    discoverySink = null
                }
            }

        }
    }

    override fun onListen(args: Any?, eventSink: EventSink?) {
        discoverySink = eventSink
    }

    override fun onCancel(args: Any?) {
        try {
            activity.unregisterReceiver(this)
        } catch (_: IllegalArgumentException) {
        }

        bluetoothAdapter!!.cancelDiscovery()

        if (discoverySink != null) {
            discoverySink!!.endOfStream()
            discoverySink = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return when (requestCode) {

            REQUEST_ENABLE_BLUETOOTH -> {
                when (resultCode) {
                    Activity.RESULT_OK -> {
                        methodCallResult?.success(true)
                    }

                    Activity.RESULT_CANCELED -> {
                        methodCallResult?.success(false)
                    }

                    else -> {
                        methodCallResult?.success(false)
                    }
                }
                methodCallResult = null
                true
            }

            REQUEST_DISCOVERABLE_BLUETOOTH -> {
                when (resultCode) {
                    Activity.RESULT_CANCELED -> {
                        methodCallResult?.success(0)
                    }

                    else -> {
                        methodCallResult?.success(resultCode)
                    }
                }
                methodCallResult = null
                true
            }

            else -> false
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        resultCode: Array<out String>,
        data: IntArray
    ): Boolean {
        return when (requestCode) {
            REQUEST_BLUETOOTH_PERMISSION -> {
                methodCallResult?.success(data.all { it == PackageManager.PERMISSION_GRANTED })
                methodCallResult = null
                true
            }

            else -> false
        }
    }

    fun requestPermission() {
        val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_ADVERTISE,
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT
            )
        } else {
            arrayOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_ADMIN,
                Manifest.permission.ACCESS_FINE_LOCATION
            )
        }
        activity.requestPermissions(permissions, REQUEST_BLUETOOTH_PERMISSION)
    }

    fun requestEnable() {
        if (!bluetoothAdapter!!.isEnabled) {
            val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            activity.startActivityForResult(enableBtIntent, REQUEST_ENABLE_BLUETOOTH)
        } else {
            methodCallResult?.success(true)
            methodCallResult = null
        }
    }

    fun isDiscoverable(): Boolean {
        return bluetoothAdapter!!.scanMode == BluetoothAdapter.SCAN_MODE_CONNECTABLE_DISCOVERABLE
    }

    fun requestDiscoverable(duration: Int) {
        if (isDiscoverable()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                methodCallResult?.success(bluetoothAdapter!!.discoverableTimeout?.seconds ?: 0)
            } else {
                methodCallResult?.success(1)
            }
            methodCallResult = null
        } else {
            val discoverableIntent: Intent =
                Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE).apply {
                    putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, duration)
                }
            activity.startActivityForResult(discoverableIntent, REQUEST_DISCOVERABLE_BLUETOOTH)
        }

    }

    fun getBondedDevices() {
        val pairedDevices = bluetoothAdapter!!.bondedDevices
        methodCallResult?.success(pairedDevices.filter { it.type == BluetoothDevice.DEVICE_TYPE_CLASSIC || it.type == BluetoothDevice.DEVICE_TYPE_DUAL }
            .map { it.toMap() })
        methodCallResult = null
    }

    fun startDiscovery() {
        if (bluetoothAdapter!!.isDiscovering) {
            methodCallResult?.error(
                TAG,
                "Bluetooth is Discovering",
                Exception("Bluetooth is Discovering")
            )
        } else {
            val intent = IntentFilter()
            intent.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
            intent.addAction(BluetoothDevice.ACTION_FOUND)
            activity.registerReceiver(this, intent)
            if (bluetoothAdapter!!.startDiscovery()) {
                methodCallResult?.success(null)
            } else {
                methodCallResult?.error(
                    TAG,
                    "StartDiscovery Failed",
                    IOException("StartDiscovery Failed")
                )
            }
        }
        methodCallResult = null
    }

    fun startServer() {
        if (acceptThread?.isAlive != true) {
            acceptThread = AcceptThread()
            acceptThread?.start()
        }
    }

    fun stopServer() {
        if (acceptThread?.isAlive == true) {
            acceptThread?.cancel()
            acceptThread = null
        }
    }

    fun connect(address: String) {
        connectThread?.cancel()
        val device = bluetoothAdapter!!.getRemoteDevice(address)
        connectThread = ConnectThread(device)
        connectThread?.start()
    }

    fun disconnect() {
        connectThread?.cancel()
        connectThread = null
        methodCallResult?.success(null)
        methodCallResult = null
    }

    fun writeText(data: String) {
        if (connectionThread == null) {
            methodCallResult?.error(TAG, "No Connection", IOException("not connected"))
            methodCallResult = null
        } else {
            connectionThread!!.writeText(data)
        }
    }

    fun writeFile(filePath: String) {
        if (connectionThread == null) {
            methodCallResult?.error(TAG, "No Connection", IOException("not connected"))
            methodCallResult = null
        } else {
            val file = File(filePath)
            if (!file.exists()) {
                methodCallResult?.error(TAG, "File Not Existed", IOException(filePath))
                methodCallResult = null
            } else {
                connectionThread!!.writeFile(file)
            }
        }
    }

    fun openSettings() {
        activity.startActivity(
            Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.fromParts("package", activity.applicationContext.packageName, null)
            )
        )
    }

    fun close() {
        stopServer()
        discoverySink?.endOfStream()
        discoverySink = null
        connectThread?.cancel()
        connectThread = null
        connectionThread?.cancel()
        connectionThread = null
        methodCallResult = null
        bluetoothAdapter!!.cancelDiscovery()
    }

    private inner class AcceptThread : Thread() {
        var shouldLoop = true
        private val mmServerSocket: BluetoothServerSocket? by lazy(LazyThreadSafetyMode.NONE) {
            bluetoothAdapter!!.listenUsingInsecureRfcommWithServiceRecord(NAME, MY_UUID)
        }

        override fun run() {
            while (shouldLoop) {
                val socket: BluetoothSocket? = try {
                    mmServerSocket?.accept()
                } catch (e: IOException) {
                    Log.e(TAG, "Bluetooth Server accept Failed")
                    shouldLoop = false
                    null
                }
                activity.runOnUiThread {
                    if (socket?.remoteDevice != null) {
                        acceptSink?.success(socket.remoteDevice.toMap())
                    }
                }
                socket?.also {
                    manageMyConnectedSocket(it)
                    mmServerSocket?.close()
                    shouldLoop = false
                }
            }
            acceptThread?.cancel()
            acceptThread = null
        }

        fun cancel() {
            shouldLoop = false
            try {
                mmServerSocket?.close()
            } catch (e: IOException) {
                Log.e(TAG, "Bluetooth Server Closed Failed", e)
            }
            activity.runOnUiThread {
                acceptSink?.endOfStream()
                acceptSink = null
            }
        }

        fun manageMyConnectedSocket(socket: BluetoothSocket) {
            connectionThread = ConnectedThread(socket)
            connectionThread!!.start()
        }
    }

    private inner class ConnectThread(device: BluetoothDevice) : Thread() {
        private val mmSocket: BluetoothSocket? by lazy(LazyThreadSafetyMode.NONE) {
            device.createRfcommSocketToServiceRecord(MY_UUID)
        }

        override fun run() {
            mmSocket?.let { socket ->
                try {
                    socket.connect()
                    methodCallResult?.success(true)
                    methodCallResult = null
                    manageMyConnectedSocket(socket)
                } catch (e: IOException) {
                    Log.e(TAG, "Bluetooth Client Connect to a Server Failed", e)
                    methodCallResult?.error(TAG, "Bluetooth Client Connect to a Server Failed", e)
                    methodCallResult = null
                }
            }
        }

        fun cancel() {
            try {
                mmSocket?.close()
            } catch (e: IOException) {
                Log.e(TAG, "Bluetooth Client Cancel to Connect to a Server Failed", e)
            }
            activity.runOnUiThread {
                connectionThread?.cancel()
                connectionThread = null
            }
        }

        fun manageMyConnectedSocket(socket: BluetoothSocket) {
            connectionThread = ConnectedThread(socket)
            connectionThread!!.start()
        }
    }

    inner class ConnectedThread(private val mmSocket: BluetoothSocket) : Thread() {

        private val mmInStream: InputStream = mmSocket.inputStream
        private val mmOutStream: OutputStream = mmSocket.outputStream
        private val mIn: DataInputStream = DataInputStream(mmInStream)
        private val mOut: DataOutputStream = DataOutputStream(mmOutStream)
        private val mmBuffer: ByteArray = ByteArray(1024)
        private var shouldLoop = true

        override fun run() {
            while (shouldLoop) {
                try {
                    when (mIn.readInt()) {
                        FLAG_TEXT -> {
                            val msg = mIn.readUTF()
                            activity.runOnUiThread {
                                connectionSink?.success(listOf<Any>(FLAG_TEXT, msg))
                            }
                        }

                        FLAG_FILE -> {
                            val filename: String = mIn.readUTF()
                            val fileSize: Long = mIn.readLong()

                            var len = 0
                            var r: Int
                            val filePath =
                                activity.applicationContext.cacheDir.path + "/" + filename
                            val out = FileOutputStream(filePath)
                            while ((mIn.read(mmBuffer).also { r = it }) != -1) {
                                out.write(mmBuffer, 0, r)
                                len += r
                                if (len >= fileSize) {
                                    activity.runOnUiThread {
                                        connectionSink?.success(listOf<Any>(FLAG_FILE, filePath))
                                    }
                                    break
                                }
                            }
                        }
                    }
                } catch (e: IOException) {
                    Log.e(TAG, "Bluetooth Connection Read Failed", e)
                    break
                }
            }
            shouldLoop = false
            connectionThread?.cancel()
            connectionThread = null
        }

        fun writeText(data: String) {
            try {
                mOut.writeInt(FLAG_TEXT)
                mOut.writeUTF(data)
                methodCallResult?.success(null)
                methodCallResult = null
            } catch (e: IOException) {
                Log.e(TAG, "Bluetooth Connection Write Text Failed, Text: $data", e)
                methodCallResult?.error(
                    TAG,
                    "Bluetooth Connection Write Text Failed, Text: $data",
                    e
                )
                methodCallResult = null
                return
            }
        }

        fun writeFile(file: File) {
            val filStream = FileInputStream(file)
            try {
                mOut.writeInt(FLAG_FILE)
                mOut.writeUTF(file.name)
                mOut.writeLong(file.length())
                var r: Int
                val b = ByteArray(4 * 1024)
                while ((filStream.read(b).also { r = it }) != -1) {
                    mOut.write(b, 0, r)
                }
                methodCallResult?.success(null)
                methodCallResult = null
            } catch (e: IOException) {
                Log.e(TAG, "Bluetooth Connection Write File Failed, Filename: ${file.name}", e)
                methodCallResult?.error(
                    TAG,
                    "Bluetooth Connection Write File Failed, Filename: ${file.name}",
                    e
                )
                methodCallResult = null
                return
            }
        }

        fun cancel() {
            shouldLoop = false
            try {
                mmOutStream.flush()
                mmSocket.close()
            } catch (e: IOException) {
                Log.e(TAG, "Bluetooth Connection Close Failed", e)
            }
        }
    }

    companion object {
        val MY_UUID: UUID = UUID.fromString("026badfe-70c3-4fbc-b6ba-06fea8d70a51")
        const val NAME: String = "Ghosten Player Server"
        const val REQUEST_ENABLE_BLUETOOTH = 3124
        const val REQUEST_DISCOVERABLE_BLUETOOTH = 4522
        const val REQUEST_BLUETOOTH_PERMISSION = 5233
        const val TAG = "BLUETOOTH"
        const val FLAG_TEXT = 0
        const val FLAG_FILE = 1
//        const val MESSAGE_READ: Int = 0
//        const val MESSAGE_WRITE: Int = 1
//        const val MESSAGE_TOAST: Int = 2
    }
}

fun BluetoothDevice.toMap(): HashMap<String, Any?> {
    val device = this
    return HashMap<String, Any?>().apply {
        this["address"] = device.address
        this["name"] = device.name
        this["type"] = device.type
        this["bondState"] = device.bondState
        this["isConnected"] = device.javaClass.getMethod("isConnected").invoke(device)
    }
}