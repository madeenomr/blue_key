import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: MousePadScreen()));
}

class MousePadScreen extends StatefulWidget {
  const MousePadScreen({super.key});

  @override
  State<MousePadScreen> createState() => _MousePadScreenState();
}

class _MousePadScreenState extends State<MousePadScreen> {
  // متغيرات لحفظ حركة الإصبع وعرضها على الشاشة للتجربة
  double moveX = 0;
  double moveY = 0;
  String status = "حرك إصبعك في المربع بالأسفل";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // خلفية داكنة
      appBar: AppBar(
        title: const Text("BlueKey Mouse 🖱️", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // شاشة عرض المعلومات (مؤقتة للتأكد أن اللمس يعمل)
          Container(
            padding: const EdgeInsets.all(20),
            height: 150,
            width: double.infinity,
            color: Colors.black54,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(status, style: const TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 20),
                Text("Horizontal (X): ${moveX.toStringAsFixed(2)}", style: const TextStyle(color: Colors.greenAccent)),
                Text("Vertical (Y): ${moveY.toStringAsFixed(2)}", style: const TextStyle(color: Colors.greenAccent)),
              ],
            ),
          ),
          
          // منطقة الماوس (Trackpad Area)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 2),
              ),
              // هنا السحر: كاشف الحركة
              child: GestureDetector(
                // هذه الدالة تعمل عندما تحرك إصبعك (Dragging)
                onPanUpdate: (details) {
                  setState(() {
                    // details.delta تعطينا الفرق في الحركة منذ آخر لحظة
                    moveX = details.delta.dx; 
                    moveY = details.delta.dy;
                    status = "جاري التحريك...";
                    // ملاحظة: هنا مستقبلاً سنضع كود إرسال البلوتوث
                  });
                },
                // هذه الدالة تعمل عندما ترفع إصبعك
                onPanEnd: (details) {
                  setState(() {
                    moveX = 0;
                    moveY = 0;
                    status = "توقف التحريك";
                  });
                },
                child: const Center(
                  child: Icon(Icons.touch_app, size: 50, color: Colors.white24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
