import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(home: MouseScreen()));
}

class MouseScreen extends StatefulWidget {
  const MouseScreen({super.key});
  @override
  State<MouseScreen> createState() => _MouseScreenState();
}

class _MouseScreenState extends State<MouseScreen> {
  static const platform = MethodChannel('com.example.blue_key/bluetooth');
  String status = "1. اقترن بالهاتف الآخر\n2. حرك إصبعك هنا";

  // طلب الأذونات عند التشغيل
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise
    ].request();
  }

  // دالة إرسال الحركة للكود الأصلي
  void sendMove(double x, double y) {
    // تقليل الحساسية قليلاً وإرسالها كأرقام صحيحة
    int dx = (x * 2.5).toInt(); // سرعة الماوس
    int dy = (y * 2.5).toInt();
    
    // إرسال فقط إذا كانت هناك حركة فعلية
    if (dx != 0 || dy != 0) {
      platform.invokeMethod('sendMouse', {
        "dx": dx,
        "dy": dy,
        "left": false, // سنبرمج الأزرار لاحقاً
        "right": false
      }).catchError((e) {
        // تجاهل الأخطاء لعدم إزعاج المستخدم
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("BlueKey Mouse 🖱️"), backgroundColor: Colors.blueGrey),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white10,
            width: double.infinity,
            child: Text(status, style: const TextStyle(color: Colors.greenAccent), textAlign: TextAlign.center),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueGrey),
              ),
              child: GestureDetector(
                onPanUpdate: (details) {
                  sendMove(details.delta.dx, details.delta.dy);
                  setState(() => status = "جاري الإرسال...");
                },
                onPanEnd: (details) => setState(() => status = "متصل - جاهز"),
                child: const Center(
                  child: Icon(Icons.touch_app, size: 60, color: Colors.white12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
