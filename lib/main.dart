import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(home: BlueKeyHome()));
}

class BlueKeyHome extends StatefulWidget {
  const BlueKeyHome({super.key});

  @override
  State<BlueKeyHome> createState() => _BlueKeyHomeState();
}

class _BlueKeyHomeState extends State<BlueKeyHome> {
  String status = "اضغط للاتصال";
  static const platform = MethodChannel('com.example.blue_key/bluetooth');

  Future<void> requestPermissions() async {
    await [Permission.bluetooth, Permission.bluetoothConnect].request();
  }

  Future<void> openBluetoothSettings() async {
    try {
      await platform.invokeMethod('openSettings');
      setState(() { status = "جاري فتح البلوتوث..."; });
    } catch (e) {
      setState(() { status = "فشل: $e"; });
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("BlueKey V2 🚀", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrange, // لون جديد
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            status,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          Center(
            child: ElevatedButton.icon(
              onPressed: openBluetoothSettings,
              icon: const Icon(Icons.bluetooth),
              label: const Text("ربط بالبلوتوث"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange, // زر برتقالي لتميز التحديث
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
