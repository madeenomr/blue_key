import 'package:flutter/material.dart';
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
  String status = "غير متصل";

  // دالة طلب الإذن عند التشغيل
  Future<void> requestPermissions() async {
    // نطلب إذن البلوتوث للأجهزة الحديثة (Android 12+)
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.bluetoothScan,
    ].request();
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // لون داكن مثل الكيبورد
      appBar: AppBar(
        title: const Text("BlueKey ⌨️"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // شاشة الحالة
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black54,
            width: double.infinity,
            child: Text(
              status,
              style: const TextStyle(color: Colors.greenAccent, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          
          const Spacer(),
          
          // منطقة الماوس (Touchpad)
          Container(
            height: 200,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white24),
            ),
            child: const Center(
              child: Text("منطقة الماوس", style: TextStyle(color: Colors.white54)),
            ),
          ),
          
          const Spacer(),
          
          // أزرار الكيبورد
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey("ESC"),
              _buildKey("SPACE"),
              _buildKey("ENTER"),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildKey(String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          status = "تم ضغط: $label";
        });
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        backgroundColor: Colors.grey[700],
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
