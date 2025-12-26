package com.example.blue_key

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothHidDevice
import android.bluetooth.BluetoothHidDeviceAppQosSettings
import android.bluetooth.BluetoothHidDeviceAppSdpSettings
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.blue_key/bluetooth"
    private var hidDevice: BluetoothHidDevice? = null
    private var hostDevice: BluetoothDevice? = null

    // تعريف هوية الماوس
    private val MOUSE_ID = 2.toByte()
    private val MOUSE_REPORT_DESC = byteArrayOf(
        0x05, 0x01, 0x09, 0x02, 0xA1.toByte(), 0x01, 0x09, 0x01, 0xA1.toByte(), 0x00,
        0x85.toByte(), MOUSE_ID, 0x05, 0x09, 0x19, 0x01, 0x29, 0x03, 0x15, 0x00, 0x25, 0x01,
        0x95.toByte(), 0x03, 0x75, 0x01, 0x81.toByte(), 0x02, 0x95.toByte(), 0x01, 0x75, 0x05,
        0x81.toByte(), 0x03, 0x05, 0x01, 0x09, 0x30, 0x09, 0x31, 0x15, 0x81.toByte(), 0x25, 0x7F,
        0x75, 0x08, 0x95.toByte(), 0x02, 0x81.toByte(), 0x06, 0xC0.toByte(), 0xC0.toByte()
    )

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val bluetoothAdapter = bluetoothManager.adapter

        bluetoothAdapter?.getProfileProxy(this, object : BluetoothProfile.ServiceListener {
            override fun onServiceConnected(profile: Int, proxy: BluetoothProfile) {
                if (profile == BluetoothProfile.HID_DEVICE) {
                    hidDevice = proxy as BluetoothHidDevice
                    registerApp()
                }
            }
            override fun onServiceDisconnected(profile: Int) {}
        }, BluetoothProfile.HID_DEVICE)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendMouse") {
                val dx = call.argument<Int>("dx") ?: 0
                val dy = call.argument<Int>("dy") ?: 0
                val leftClick = call.argument<Boolean>("left") ?: false
                val rightClick = call.argument<Boolean>("right") ?: false
                sendMouseReport(dx, dy, leftClick, rightClick)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun registerApp() {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) return
        
        val sdp = BluetoothHidDeviceAppSdpSettings("BlueKey Mouse", "Mobile Mouse", "Flutter", 0x00, MOUSE_REPORT_DESC)
        val qos = BluetoothHidDeviceAppQosSettings(BluetoothHidDeviceAppQosSettings.SERVICE_GUARANTEED, 800, 9, 0, 11250, -1)
        
        // تم حذف السطر المسبب للمشكلة (AppOpAttr)
        
        hidDevice?.registerApp(sdp, qos, qos, Executors.newCachedThreadPool(), object : BluetoothHidDevice.Callback() {
            override fun onConnectionStateChanged(device: BluetoothDevice?, state: Int) {
                if (state == BluetoothProfile.STATE_CONNECTED) hostDevice = device
            }
        })
    }

    private fun sendMouseReport(dx: Int, dy: Int, left: Boolean, right: Boolean) {
        if (hostDevice != null && hidDevice != null) {
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) return
            
            var buttons = 0
            if (left) buttons = buttons or 1
            if (right) buttons = buttons or 2
            
            val report = ByteArray(3)
            report[0] = buttons.toByte()
            report[1] = dx.toByte()
            report[2] = dy.toByte()

            hidDevice?.sendReport(hostDevice!!, MOUSE_ID.toInt(), report)
        }
    }
}
