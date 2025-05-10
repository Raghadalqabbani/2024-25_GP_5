import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart'; // <--- ✅ ADD THIS

class DangerAlertPage extends StatefulWidget {
  const DangerAlertPage({super.key});

  @override
  State<DangerAlertPage> createState() => _DangerAlertPageState();
}

class _DangerAlertPageState extends State<DangerAlertPage> {
  @override
  void initState() {
    super.initState();
    _vibrateOnAlert();
  }


// Future<void> _vibrateOnAlert() async {
//   if (await Vibration.hasVibrator() ?? false) {
//     Vibration.vibrate(
//       pattern: [0, 500, 1000, 500, 500],
//       intensities: [255, 255, 255, 255, 255], // 💥 same length = 5 intensities
//     );
//   } else {
//     print('❌ No vibrator available.');
//   }
// }

Future<void> _vibrateOnAlert() async {
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(
      pattern: [
        0,    // Start immediately
        1500, // Vibrate 1.5 sec
        500,  // Pause 0.5 sec
        1500, // Vibrate 1.5 sec
        500,  // Pause 0.5 sec
        1500, // Vibrate 1.5 sec
        500,  // Pause 0.5 sec
        3000, // Vibrate 3 sec
        1000, // Pause 1 sec
        3000, // Vibrate 3 sec
        1000, // Pause 1 sec
        3000, // Vibrate 3 sec
      ],
      intensities: [
        0,    // No vibration at the start
        255,  // Vibrate strong
        0,    // Pause
        255,  // Vibrate strong
        0,    // Pause
        255,  // Vibrate strong
        0,    // Pause
        255,  // Vibrate strong
        0,    // Pause
        255,  // Vibrate strong
        0,    // Pause
        255,  // Vibrate strong
      ],
    );
  } else {
    print('❌ No vibrator available.');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 100),
              const SizedBox(height: 20),
              Text(
                "⚠️ Danger Sound Detected!",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Please check your surroundings immediately.\n"
                "A possible danger has been detected near you.",
                style: TextStyle(color: Colors.white70, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                    await Vibration.cancel(); // ⛔ Stop vibration
                  context.go('/');
                },
                child: const Text("I'm Safe, Dismiss"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart'; // Required for context.go()

// class DangerAlertPage extends StatelessWidget {
//   const DangerAlertPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.red[900],
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.warning_amber_rounded, color: Colors.white, size: 100),
//               const SizedBox(height: 20),
//               Text(
//                 "⚠️ Danger Sound Detected!",
//                 style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 "Please check your surroundings immediately.\n"
//                 "A possible danger has been detected near you.",
//                 style: TextStyle(color: Colors.white70, fontSize: 18),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 40),
//               ElevatedButton(
//                 onPressed: () {
//                   // Go back to home or safe page
//                   context.go('/');
//                 },
//                 child: const Text("I'm Safe, Dismiss"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   textStyle: const TextStyle(fontSize: 16),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
