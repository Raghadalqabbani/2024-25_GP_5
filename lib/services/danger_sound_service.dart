import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:mic_stream/mic_stream.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class DangerSoundService {
  final double decibelThreshold;
  final int recordingDuration;
  final String flaskUrl;

  static String? fcmToken; // ✅ Static token accessible across instances

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  StreamSubscription<List<int>>? _micSubscription;
  final List<File> savedRecordings = [];

  DangerSoundService({
    this.decibelThreshold = -15.0,
    this.recordingDuration = 3,
    required this.flaskUrl,
  });

  static void setFcmToken(String token) {
    fcmToken = token;
    print("✅ Static FCM token set: $token");
  }

  Future<void> startMonitoring() async {
    print("🔁 Starting DangerSoundService...");

    if (!(await Permission.microphone.request().isGranted)) {
      print("❌ Microphone permission denied");
      return;
    }

    final stream = await MicStream.microphone(
      audioSource: AudioSource.DEFAULT,
      sampleRate: 44100,
      channelConfig: ChannelConfig.CHANNEL_IN_MONO,
      audioFormat: AudioFormat.ENCODING_PCM_16BIT,
    );

    if (stream != null) {
      _micSubscription = stream.listen(_processAudio);
      print("🎧 Mic stream listening...");
    } else {
      print("❌ Mic stream initialization failed.");
    }
  }

  void _processAudio(List<int> rawSamples) async {
    final byteBuffer = Int8List.fromList(rawSamples).buffer;
    final int16Samples = Int16List.view(byteBuffer);
    final List<double> floats = int16Samples.map((s) => s / 32768.0).toList();
    final rms =
        sqrt(floats.map((x) => x * x).reduce((a, b) => a + b) / floats.length);
    final dB = 20 * log(rms) / ln10;

    if (dB.isNaN || dB == double.negativeInfinity) return;
    // print("🔊 dB: ${dB.toStringAsFixed(2)}");

    if (dB > decibelThreshold && !_isRecording) {
      print("📢 Threshold exceeded! Start recording...");
      await _recordAndSend();
    }
  }

  Future<void> stopMonitoring() async {
  try {
    await _micSubscription?.cancel();
    _micSubscription = null; // Important to reset to null
    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    }
  } catch (e) {
    print('❌ Error stopping monitoring: $e');
  }
  print("🛑 Monitoring stopped.");
}


  // Future<void> _recordAndSend() async {
  //   _isRecording = true;

  //   try {
  //     final dir = Directory('/storage/emulated/0/Download/danger_sounds');
  //     if (!(await dir.exists())) await dir.create(recursive: true);

  //     final timestamp = DateTime.now().millisecondsSinceEpoch;
  //     final filePath = '${dir.path}/danger_sound_$timestamp.wav';

  //     await _recorder.openRecorder();
  //     await _recorder.startRecorder(toFile: filePath, codec: Codec.pcm16WAV);
  //     await Future.delayed(Duration(seconds: recordingDuration));
  //     await _recorder.stopRecorder();
  //     await _recorder.closeRecorder();

  //     final file = File(filePath);
  //     print("✅ Saved: $filePath");

  //     savedRecordings.add(file);
  //     await _sendToFlask(file);
  //   } catch (e) {
  //     print("❌ Recording error: $e");
  //   }

  //   _isRecording = false;
  // }


Future<void> _recordAndSend() async {
  _isRecording = true;

  try {
    // ✅ Use app-safe storage directory (no need for storage permission)
    final parentDir = await getExternalStorageDirectory();
    if (parentDir == null) {
      print("❌ Failed to get safe external directory");
      _isRecording = false;
      return;
    }

    // ✅ Create 'danger_sounds' folder inside the safe app-specific path
    final dir = Directory('${parentDir.path}/danger_sounds');
    if (!(await dir.exists())) await dir.create(recursive: true);

    // ✅ File path
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${dir.path}/danger_sound_$timestamp.wav';

    // ✅ Start recording
    await _recorder.openRecorder();
    await _recorder.startRecorder(toFile: filePath, codec: Codec.pcm16WAV);
    await Future.delayed(Duration(seconds: recordingDuration));
    await _recorder.stopRecorder();
    await _recorder.closeRecorder();

    final file = File(filePath);
    print("✅ Saved: $filePath");

    savedRecordings.add(file);
    await _sendToFlask(file);
  } catch (e) {
    print("❌ Recording error: $e");
  }

  _isRecording = false;
}

  Future<void> _sendToFlask(File audioFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(flaskUrl),
      );
      request.files
          .add(await http.MultipartFile.fromPath('audio', audioFile.path));
      var response = await request.send();
      final respBody = await response.stream.bytesToString();
      print("✅ Flask response: $respBody");

      // Parse JSON response
      final Map<String, dynamic> decoded = json.decode(respBody);
      final prediction = decoded['prediction']['prediction'];
      final confidence = decoded['prediction']['confidence'];

      print("🧠 Prediction: $prediction | 🎯 Confidence: $confidence");

      if (prediction == 1) {
        print("🚨 Danger Detected! Sending FCM alert...");
        await _sendFcmNotification();
      }
    } catch (e) {
      print("❌ Upload or parse error: $e");
    }
  }

  Future<void> _sendFcmNotification() async {
    if (fcmToken == null) {
      print("❌ FCM token not set. Cannot send personalized alert.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://danger-alert-service-50b9c2a02653.herokuapp.com/send_alert'), // Flask FCM API
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          
          'data': {'navigate': 'danger'},
          'token': fcmToken, // Send to specific device
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Personalized FCM alert sent.");
      } else {
        print("❌ FCM error: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception sending FCM: $e");
    }
  }

  List<File> getAllSavedRecordings() => savedRecordings;
}



// import 'dart:async';
// import 'dart:math';
// import 'dart:typed_data';
// import 'dart:io';
// import 'package:mic_stream/mic_stream.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;

// class DangerSoundService {
//   final double decibelThreshold;
//   final int recordingDuration;

//   /// ✅ Your backend Flask server URL (replace IP with your computer's IP)
//   final String flaskUrl;

//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   bool _isRecording = false;
//   StreamSubscription<List<int>>? _micSubscription;
//   final List<File> savedRecordings = [];

//   DangerSoundService({
//     this.decibelThreshold = -30.0,
//     this.recordingDuration = 3,
//     required this.flaskUrl,
//   });

//   Future<void> startMonitoring() async {
//     print("🔁 Starting DangerSoundService with mic_stream...");

//     if (!(await Permission.microphone.request().isGranted)) {
//       print("❌ Microphone permission denied");
//       return;
//     }

//     final stream = await MicStream.microphone(
//       audioSource: AudioSource.DEFAULT,
//       sampleRate: 44100,
//       channelConfig: ChannelConfig.CHANNEL_IN_MONO,
//       audioFormat: AudioFormat.ENCODING_PCM_16BIT,
//     );

//     if (stream != null) {
//       _micSubscription = stream.listen(_processAudio);
//       print("🎧 Started mic_stream listening...");
//     } else {
//       print("❌ Failed to initialize mic stream.");
//     }
//   }

//   void _processAudio(List<int> rawSamples) async {
//     final byteBuffer = Int8List.fromList(rawSamples).buffer;
//     final int16Samples = Int16List.view(byteBuffer);
//     final List<double> floats = int16Samples.map((s) => s / 32768.0).toList();
//     final rms = sqrt(floats.map((x) => x * x).reduce((a, b) => a + b) / floats.length);
//     final dB = 20 * log(rms) / ln10;

//     if (dB.isNaN || dB == double.negativeInfinity) return;
//     print("🔊 dB: ${dB.toStringAsFixed(2)}");

//     if (dB > decibelThreshold && !_isRecording) {
//       print("📢 Threshold exceeded! Starting recording...");
//       await _recordAndSend();
//     }
//   }

//   Future<void> stopMonitoring() async {
//     await _micSubscription?.cancel();
//     await _recorder.stopRecorder();
//     print("🛑 Mic stream and recording stopped.");
//   }

//   Future<void> _recordAndSend() async {
//     _isRecording = true;

//     try {
//       final dir = Directory('/storage/emulated/0/Download/danger_sounds');
//       if (!(await dir.exists())) await dir.create(recursive: true);

//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final filePath = '${dir.path}/danger_sound_$timestamp.wav';

//       await _recorder.openRecorder();
//       await _recorder.startRecorder(toFile: filePath, codec: Codec.pcm16WAV);
//       await Future.delayed(Duration(seconds: recordingDuration));
//       await _recorder.stopRecorder();
//       await _recorder.closeRecorder();

//       final file = File(filePath);
//       print("✅ Recorded & Saved: $filePath");

//       savedRecordings.add(file);
//       await _sendToFlask(file);
//     } catch (e) {
//       print("❌ Recording error: $e");
//     }

//     _isRecording = false;
//   }

//   Future<void> _sendToFlask(File audioFile) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(flaskUrl), // Full endpoint including /upload_audio
//       );
//       request.files.add(await http.MultipartFile.fromPath('audio', audioFile.path));
//       var response = await request.send();
//       final respBody = await response.stream.bytesToString();
//       print("✅ Flask response: $respBody");
//     } catch (e) {
//       print("❌ Upload error: $e");
//     }
//   }
// // 
//   List<File> getAllSavedRecordings() => savedRecordings;
// }
