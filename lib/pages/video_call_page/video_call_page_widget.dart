import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert' as convert;
import 'package:flutter_sound/flutter_sound.dart' as fs;

import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';


const appId = "ec8764a3a509482b9280f1e4d88311c4";
const backendUrl = "http://192.168.8.136:3002/upload";
const secondaryBackendUrl = "http://192.168.8.136:3001/frames";
const predictionApi = "http://192.168.8.136:5000/predict";
const authorizedDeviceModel = "samsung SM-G998B";
const getCallerSettingsApi =
    "https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/get-caller-settings";

class GoogleSpeechService {
  static Future<String> transcribeAudio(File audioFile, String languageCode) async {
    final response = await http.get(
      Uri.parse("https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/get-google-api-key"),
    );

    if (response.statusCode != 200) {
      return "Failed to load API key";
    }

    final apiKey = convert.jsonDecode(response.body)?['apiKey'];
    if (apiKey == null) return "API key is null";

    final apiUrl = 'https://speech.googleapis.com/v1/speech:recognize?key=$apiKey';
    final audioBytes = await audioFile.readAsBytes();
    final base64Audio = convert.base64Encode(audioBytes);

    final payload = {
      'config': {
        'encoding': 'LINEAR16',
        'sampleRateHertz': 16000,
        'languageCode': languageCode,
      },
      'audio': {'content': base64Audio},
    };

    final responseSTT = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: convert.jsonEncode(payload),
    );

    if (responseSTT.statusCode == 200) {
      final result = convert.jsonDecode(responseSTT.body);
      if (result['results'] != null && result['results'].isNotEmpty) {
        return result['results'][0]['alternatives'][0]['transcript'] ?? ".............";
      } else {
        return "......";
      }
    } else {
      return "Transcription failed: ${responseSTT.body}";
    }
  }
}


class VideoCallPageWidget extends StatefulWidget {
  final String channelName;
  final String token;
  final int uid;
  // final String callId;
  final String userId;
  const VideoCallPageWidget({
    Key? key,
    required this.channelName,
    required this.token,
    required this.uid,
    // required this.callId,
    required this.userId,
  }) : super(key: key);

  @override
  State<VideoCallPageWidget> createState() => _VideoCallPageWidgetState();
}

class _VideoCallPageWidgetState extends State<VideoCallPageWidget> {
  final GlobalKey _localVideoKey = GlobalKey();
  final GlobalKey _remoteVideoKey = GlobalKey();
  late FlutterSoundRecorder _recorder;
  Timer? _recordingTimer;
  final GoogleSpeechService _speechService = GoogleSpeechService();
  bool _isSigner = false;
bool _isRecording = false;
Timer? _arabicCaptureTimer;
bool _signLanguageEnabled = false;

  late RtcEngine _engine;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _muted = false;
  bool _cameraOff = false;
  bool _remoteCameraOff = false;

  Timer? _mainCaptureTimer;
  Timer? _englishCaptureTimer;

  bool isAuthorizedDevice = false;
  bool englishTriggered = false;

  String _selectedLanguage = 'English';
  String _predictedWord = '';
  Map<String, String> _subtitles = {
    'English': '',
    'Arabic': "",
  };

  @override
  void initState()  {
    super.initState();
    debugPrint(
        "👇👇👇👇 User ID passed to VideoCallPageWidget: ${widget.userId}");
    _fetchCallerSettingsAndInit();
 _fetchContactName().then((_) async {
      await _initializeEmptySubtitleDoc(); // ✅ Initialize empty subtitle document
    _listenToRemoteSubtitles();
        _listenForCallEnd(); // 👈 Add this line
  });  }

Future<void> _initializeEmptySubtitleDoc() async {
  final subtitleDoc = FirebaseFirestore.instance
      .collection('calls')
      .doc(widget.channelName)
      .collection('subtitles')
      .doc(widget.userId);

  final docSnapshot = await subtitleDoc.get();

  if (!docSnapshot.exists) {
    await subtitleDoc.set({
      _isSigner ? 'prediction' : 'transcript_local': '',
      'timestamp': FieldValue.serverTimestamp(),
    });
    debugPrint("📄 Initialized empty subtitles doc for ${widget.userId}");
  }
}



void _listenForCallEnd() {
  FirebaseFirestore.instance
      .collection('calls')
      .doc(widget.channelName)
      .snapshots()
      .listen((snapshot) {
    if (snapshot.exists && snapshot.data()?['callEnded'] == true) {
      debugPrint("📴 Call ended remotely. Leaving...");
      _onEndCall(); // Trigger end call for second user
    }
  });
}


// Future<void> _initializeData() async {
//   await _fetchContactName();
//   _listenToRemoteSubtitles();
// }

Future<void> _fetchCallerSettingsAndInit() async {
  try {
    final response = await http.post(
      Uri.parse(getCallerSettingsApi),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"callerId": widget.userId}),
    );

    if (response.statusCode == 200) {
      final settings = jsonDecode(response.body);
      final bool cameraNotEnabled = settings['cameraNotEnabled'] ?? false;
      final bool micNotEnabled = settings['micNotEnabled'] ?? false;
      final bool isSigner = settings['signer'] ?? false;

      setState(() {
        _cameraOff = cameraNotEnabled;
        _muted = micNotEnabled;
        _isSigner = isSigner;
        _signLanguageEnabled = isSigner; // sync switch ON if signer
      });

      // Signer → Start capture if switch is ON
      if (_signLanguageEnabled && _isSigner) {
        _restartCaptureBasedOnLanguage();
      }

      // Non-signer → Start speech transcription
      if (!_isSigner) {
        _startSpeechRecordingLoop();
      }
    }
  } catch (e) {
    debugPrint("❌ Error fetching caller settings: $e");
  }

  await initAgora();
  await _engine.muteLocalVideoStream(_cameraOff);
  await _engine.muteLocalAudioStream(_muted);
}

void _restartCaptureBasedOnLanguage() {
  _englishCaptureTimer?.cancel();
  _arabicCaptureTimer?.cancel();

  if (_signLanguageEnabled ) {
    if (_selectedLanguage == 'English') {
      _startEnglishCapture();
    } else if (_selectedLanguage == 'Arabic') {
      _startArabicCapture();
    }
  }
}

Future<void> _startSpeechRecordingLoop() async {
  if (_isRecording || _muted) return;

  _recorder = FlutterSoundRecorder();
  await _recorder.openRecorder();
  _isRecording = true;

  () async {
    while (mounted && !_muted) {
      try {
        Directory tempDir = await getTemporaryDirectory();
        String path = '${tempDir.path}/temp_audio.wav';

        // ✅ Start recording with print
        debugPrint("🎙️ [Recording] Started");
        await _recorder.startRecorder(
          toFile: path,
          codec: fs.Codec.pcm16WAV,
          sampleRate: 16000,
        );

        // ✅ Record for slightly longer to capture full sentence
        await Future.delayed(const Duration(seconds: 3));

        await _recorder.stopRecorder();
        debugPrint("🛑 [Recording] Stopped");

        final transcript = await GoogleSpeechService.transcribeAudio(
          File(path),
          _selectedLanguage == 'Arabic' ? 'ar-SA' : 'en-US',
        );

        // ✅ Print what was transcribed
        debugPrint("📝 [Transcript] $transcript");

        await FirebaseFirestore.instance
            .collection('calls')
            .doc(widget.channelName)
            .collection('subtitles')
            .doc(widget.userId)
            .set({
          'transcript_local': transcript,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Short delay before next recording
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        debugPrint("Recording loop error: $e");
      }
    }
    _isRecording = false;
  }();
}


String _contactName = "Other";
String _otherUserId = "";

Future<void> _fetchContactName() async {
  final response = await http.post(
    Uri.parse("https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/getContactNameFromCall"), // 🔁 Replace with your real URL
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "userId": widget.userId,
      "callId": widget.channelName, // channelName == callId
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁🔁$data");
    setState(() {
      _contactName = data['contactName'] ?? "Other";
      _otherUserId = data['otherUserId'] ?? "";
    });
  } else {
    debugPrint("❌ Failed to fetch contact name: ${response.body}");
  }
}


  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (_, __) => setState(() => _localUserJoined = true),
      onUserJoined: (_, uid, __) => setState(() => _remoteUid = uid),
      onUserOffline: (_, __, ___) => setState(() => _remoteUid = null),
      onUserMuteVideo: (_, uid, muted) {
        if (uid == _remoteUid) setState(() => _remoteCameraOff = muted);
      },
    ));
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.muteLocalVideoStream(_cameraOff);
    await _engine.muteLocalAudioStream(_muted);
    await _engine.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
        uid: widget.uid,
        options: const ChannelMediaOptions());
  }



int _frameCounter = 0; // 🆕 Add this at the top of your class (outside any function)

Future<void> _captureAndUpload(GlobalKey key, String url, {bool callPredict = false}) async {
  try {
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    final fileName = 'frame_${DateTime.now().millisecondsSinceEpoch}.png';

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..files.add(http.MultipartFile.fromBytes('file', pngBytes, filename: fileName));

    final response = await request.send();
    if (response.statusCode == 200) {
      _frameCounter++; // 🆕 Increase frame counter

      if (callPredict && _frameCounter >= 5) { // 🆕 If 5 frames uploaded
        _frameCounter = 0; // 🆕 Reset counter
        await _triggerPrediction(); // 🧠 Now trigger prediction
      }
    }
  } catch (e) {
    debugPrint('Screenshot error: $e');
  }
}




void _startArabicCapture() {
  _arabicCaptureTimer?.cancel(); // Just in case
  _arabicCaptureTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
    _captureAndUploadScreenshot(
      _localVideoKey, 
      'arabic_frame_${DateTime.now().millisecondsSinceEpoch}.png',
    );
  });
}



Future<void> _captureAndUploadScreenshot(
    GlobalKey key, String fileName) async {
  try {
    RenderRepaintBoundary boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Sending the image to the backend
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(backendUrl),
    )..files.add(http.MultipartFile.fromBytes(
        'file',
        pngBytes,
        filename: fileName,
      ));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      // Print the extracted keypoints and predicted sign
      if (jsonResponse['keypoints'] != null &&
          jsonResponse['predicted_sign'] != null &&
          jsonResponse['sign_arabic'] != null) {
        List<dynamic> keypoints = jsonResponse['keypoints'];
        String predictedSign = jsonResponse['predicted_sign'];
        String signArabic = jsonResponse['sign_arabic'];

        // setState(() {
        //   _predictedSign = signArabic; // Update the predicted sign locally
        // });

        debugPrint('✅ Extracted Keypoints: ${keypoints.toString()}');
        debugPrint('🤟 Predicted Sign: $predictedSign');
        debugPrint('🔡 Sign Arabic: $signArabic');

        // ✅ Save to Firestore just like English predictions
        await FirebaseFirestore.instance
            .collection('calls')
            .doc(widget.channelName)
            .collection('subtitles')
            .doc(widget.userId)
            .set({
          'prediction': signArabic,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

      } else {
        debugPrint('No hands detected or prediction failed!');
      }
    } else {
      debugPrint('❌ Failed to process image: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('🚨 Error capturing and uploading image: $e');
  }
}

Future<void> _triggerPrediction() async {
  try {
    final response = await http.post(Uri.parse(predictionApi));
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
              print("🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢$result");

      final prediction = result['prediction'];

      // 🔁 Save prediction to Firestore only
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.channelName)
          .collection('subtitles')
          .doc(widget.userId)
          .set({
        'prediction': prediction,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  } catch (e) {
    debugPrint("Prediction error: $e");
  }
}

// void _listenToRemoteSubtitles() {
//   FirebaseFirestore.instance
//       .collection('calls')
//       .doc(widget.channelName)
//       .collection('subtitles')
//       .snapshots()
//       .listen((snapshot) {
//     for (var doc in snapshot.docs) {
//       if (doc.id != widget.userId) {
//         final data = doc.data();

//         setState(() {
//           if (_isSigner) {
//             // signer sees the transcript of the other (non-signer)
//             _subtitles[_selectedLanguage] = data['transcript'] ?? '';
//           } else {
//             // non-signer sees the prediction of the other (signer)
//             _subtitles[_selectedLanguage] = data['prediction'] ?? '';
//           }
//         });
//       }
//     }
//   });
// }

void _listenToRemoteSubtitles() {
  FirebaseFirestore.instance
      .collection('calls')
      .doc(widget.channelName)
      .collection('subtitles')
      .snapshots()
      .listen((snapshot) {
    String myLine = "";
    String otherLine = "";

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (doc.id == widget.userId) {
        myLine = _isSigner
            ? "Me: ${data['prediction'] ?? ''}"
            : "Me: ${data['transcript_local'] ?? ''}";
      } else if (doc.id == _otherUserId) {
        otherLine = _isSigner
            ? "$_contactName: ${data['transcript_local'] ?? ''}"
            : "$_contactName: ${data['prediction'] ?? ''}";
      }
    }

    setState(() {
      _subtitles[_selectedLanguage] = "$myLine\n$otherLine";
    });
  });
}

// void _listenToRemoteSubtitles() {
//   FirebaseFirestore.instance
//       .collection('calls')
//       .doc(widget.channelName)
//       .collection('subtitles')
//       .snapshots()
//       .listen((snapshot) {
//     String myLine = "";
//     String otherLine = "";

//     for (var doc in snapshot.docs) {
//       final data = doc.data();
//       if (doc.id == widget.userId) {
//         myLine = "Me: ${data['transcript_local'] ?? ''}";
//       } else if (doc.id == _otherUserId) {
//         otherLine = "$_contactName: ${data['transcript_local'] ?? ''}";
//       }
//     }

//     setState(() {
//       _subtitles[_selectedLanguage] = "$myLine\n$otherLine";
//     });
//   });
// }



void _onLanguageChanged(String? newLang) {
  if (newLang == null) return;

  setState(() {
    _selectedLanguage = newLang;
    englishTriggered = _selectedLanguage == 'English';
    _subtitles['English'] = '';
    _subtitles['Arabic'] = '';
  });

  _restartCaptureBasedOnLanguage(); // ⬅️ restart correct one
}


void _startEnglishCapture() {
  _englishCaptureTimer?.cancel();
  _englishCaptureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (englishTriggered && _signLanguageEnabled) {
      _captureAndUpload(_localVideoKey, secondaryBackendUrl, callPredict: true);
    }
  });
}



  @override
  @override
  void dispose() {
    _mainCaptureTimer?.cancel();
    _englishCaptureTimer?.cancel();
    _recordingTimer?.cancel(); // for speech loop
    _arabicCaptureTimer?.cancel();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Video Call'),
          backgroundColor: const Color(0xFF7B78DA)),
      body: Stack(children: [
        Center(child: _remoteVideo()),
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 100,
            height: 150,
            child: RepaintBoundary(
              key: _localVideoKey,
              child: _localUserJoined
                  ? (_cameraOff
                      ? Container(color: Colors.black)
                      : AgoraVideoView(
                          controller: VideoViewController(
                              rtcEngine: _engine,
                              canvas: VideoCanvas(uid: widget.uid))))
                  : const CircularProgressIndicator(),
            ),
          ),
        ),
        // Control buttons under the local video
Positioned(
  top: 160,
  left: 10,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _languageSwitch(),
      const SizedBox(height: 10),
      _signLanguageSwitch(), // ← NEW
      const SizedBox(height: 10),
      _buildControlButton(
        icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
        onPressed: _toggleCamera
        ,        ),
      const SizedBox(height: 10),

      _buildControlButton(
        icon: Icons.cameraswitch, onPressed: _switchCamera),
      const SizedBox(height: 10),
      _buildControlButton(
        icon: _muted ? Icons.mic_off : Icons.mic,
        onPressed: _toggleMute,
                ),
        
    ],
  ),
),


Align(
  alignment: Alignment.bottomRight,
  child: Container(
    margin: const EdgeInsets.only(left: 40, bottom: 20,right: 20), // 👈 Added margin here
    child: _buildControlButton(
      icon: Icons.call_end,
      onPressed: _onEndCall,
      backgroundColor: Colors.red,
    ),
  ),
),




        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12)),
            child: Text(_subtitles[_selectedLanguage] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500)),
          ),
        )
      ]),
    );
  }

  Widget _buildControlButton(
      {required IconData icon,
      required VoidCallback onPressed,
      Color backgroundColor = Colors.grey}) {
    return Container(
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: IconButton(
          icon: Icon(icon, color: Colors.white), onPressed: onPressed),
    );
  }


Widget _languageSwitch() {
  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedLanguage = _selectedLanguage == 'English' ? 'Arabic' : 'English';
        englishTriggered = _selectedLanguage == 'English';

        _subtitles['English'] = '';
        _subtitles['Arabic'] = '';

        _englishCaptureTimer?.cancel();
        _arabicCaptureTimer?.cancel();

        if (_isSigner) {
          if (_selectedLanguage == 'English') {
            _startEnglishCapture();
          } else {
            _startArabicCapture();
          }
        }
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 80,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey, // Match other buttons
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selected language label
          Align(
            alignment: _selectedLanguage == 'English'
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                _selectedLanguage == 'English' ? 'EN' : 'AR',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Thumb with globe icon
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment: _selectedLanguage == 'English'
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF7B78DA), // purple thumb
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.language,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



// Widget _signLanguageSwitch() {
//   return GestureDetector(
//     onTap: () {
//       setState(() {
//         _signLanguageEnabled = !_signLanguageEnabled;
//       });

//       if (_signLanguageEnabled) {
//         _restartCaptureBasedOnLanguage(); // Start appropriate capture based on language
//       } else {
//         _englishCaptureTimer?.cancel();
//         _arabicCaptureTimer?.cancel();
//       }
//     },
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: 80,
//       height: 36,
//       decoration: BoxDecoration(
//         color: Colors.grey,
//         borderRadius: BorderRadius.circular(30),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 6),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // "On" or "Off" label
//           Align(
//             alignment: _signLanguageEnabled
//                 ? Alignment.centerLeft
//                 : Alignment.centerRight,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Text(
//                 _signLanguageEnabled ? 'On' : 'Off',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),

//           // Icon thumb
//           AnimatedAlign(
//             duration: const Duration(milliseconds: 300),
//             alignment: _signLanguageEnabled
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               width: 30,
//               height: 30,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Color(0xFF7B78DA),
//               ),
//               padding: const EdgeInsets.all(4),
//               child: Image.asset(
//                 'assets/images/Layer_1.png',
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

Widget _signLanguageSwitch() {
  return GestureDetector(
    onTap: () {
      setState(() {
        _signLanguageEnabled = !_signLanguageEnabled;
      });

      if (_signLanguageEnabled) {
        // ✅ Start capture based on current language
        _restartCaptureBasedOnLanguage();
      } else {
        // ✅ Stop all capture timers
        _englishCaptureTimer?.cancel();
        _arabicCaptureTimer?.cancel();
      }
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 80,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Label (On/Off)
          Align(
            alignment: _signLanguageEnabled
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _signLanguageEnabled ? 'On' : 'Off',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Icon thumb
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment: _signLanguageEnabled
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF7B78DA),
              ),
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/images/Layer_1.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return _remoteCameraOff
          ? Container(color: Colors.black)
          : RepaintBoundary(
              key: _remoteVideoKey,
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine,
                  canvas: VideoCanvas(uid: _remoteUid!),
                  connection: RtcConnection(channelId: widget.channelName),
                ),
              ),
            );
    } else {
      return const Text('Waiting for remote user...',
          style: TextStyle(color: Colors.grey));
    }
  }

  void _toggleCamera() => _onToggleCamera();
  void _switchCamera() => _onSwitchCamera();
  void _toggleMute() => _onToggleMute();

  void _onToggleCamera() async {
    setState(() => _cameraOff = !_cameraOff);
    await _engine.muteLocalVideoStream(_cameraOff);
  }

  void _onSwitchCamera() => _engine.switchCamera();

void _onToggleMute() async {
  setState(() => _muted = !_muted);
  await _engine.muteLocalAudioStream(_muted);

  if (_muted) {
    // Stop recording
    if (_isRecording) {
      await _recorder.stopRecorder();
      _isRecording = false;
      debugPrint("🎤 Recorder stopped because mic is muted");
    }
  } else {
    // Restart recording loop
    _startSpeechRecordingLoop();
    debugPrint("🎤 Recorder restarted because mic is unmuted");
  }
}

void _onEndCall() async {
  try {
    _mainCaptureTimer?.cancel();
    _englishCaptureTimer?.cancel();
    _arabicCaptureTimer?.cancel();
    _recordingTimer?.cancel();
await FirebaseFirestore.instance
    .collection('calls')
    .doc(widget.channelName)
    .set({'callEnded': true}, SetOptions(merge: true));

    setState(() {
      _subtitles['English'] = '';
      _subtitles['Arabic'] = '';
    });

    if (!_isSigner) {
      try {
        await _recorder.stopRecorder();
      } catch (e) {
        debugPrint("🎤 Stop recorder error (maybe already stopped): $e");
      }
      try {
        await _recorder.closeRecorder();
      } catch (e) {
        debugPrint("🎤 Close recorder error (maybe already closed): $e");
      }
    }

    await FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.channelName)
        .collection('subtitles')
        .doc(widget.userId)
        .set({
      _isSigner ? 'prediction' : 'transcript': '.......',
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _engine.leaveChannel();
    await _engine.release();

    if (mounted) {
      context.go('/homePage');
    }
  } catch (e) {
    debugPrint("❌ Error during call end cleanup: $e");
  }
}
}
// import 'package:flutter_sound/public/flutter_sound_recorder.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:convert' as convert;
// import 'package:flutter_sound/flutter_sound.dart' as fs;

// import '/flutter_flow/flutter_flow_util.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/rendering.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:http/http.dart' as http;
// import 'dart:ui';
// import 'dart:convert';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';


// const appId = "ec8764a3a509482b9280f1e4d88311c4";
// const backendUrl = "http://192.168.8.136:3002/upload";
// const secondaryBackendUrl = "http://192.168.8.136:3001/frames";
// const predictionApi = "http://192.168.8.136:5000/predict";
// const authorizedDeviceModel = "samsung SM-G998B";
// const getCallerSettingsApi =
//     "https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/get-caller-settings";

// class GoogleSpeechService {
//   static Future<String> transcribeAudio(File audioFile, String languageCode) async {
//     final response = await http.get(
//       Uri.parse("https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/get-google-api-key"),
//     );

//     if (response.statusCode != 200) {
//       return "Failed to load API key";
//     }

//     final apiKey = convert.jsonDecode(response.body)?['apiKey'];
//     if (apiKey == null) return "API key is null";

//     final apiUrl = 'https://speech.googleapis.com/v1/speech:recognize?key=$apiKey';
//     final audioBytes = await audioFile.readAsBytes();
//     final base64Audio = convert.base64Encode(audioBytes);

//     final payload = {
//       'config': {
//         'encoding': 'LINEAR16',
//         'sampleRateHertz': 16000,
//         'languageCode': languageCode,
//       },
//       'audio': {'content': base64Audio},
//     };

//     final responseSTT = await http.post(
//       Uri.parse(apiUrl),
//       headers: {'Content-Type': 'application/json'},
//       body: convert.jsonEncode(payload),
//     );

//     if (responseSTT.statusCode == 200) {
//       final result = convert.jsonDecode(responseSTT.body);
//       if (result['results'] != null && result['results'].isNotEmpty) {
//         return result['results'][0]['alternatives'][0]['transcript'] ?? ".............";
//       } else {
//         return "......";
//       }
//     } else {
//       return "Transcription failed: ${responseSTT.body}";
//     }
//   }
// }


// class VideoCallPageWidget extends StatefulWidget {
//   final String channelName;
//   final String token;
//   final int uid;
//   // final String callId;
//   final String userId;
//   const VideoCallPageWidget({
//     Key? key,
//     required this.channelName,
//     required this.token,
//     required this.uid,
//     // required this.callId,
//     required this.userId,
//   }) : super(key: key);

//   @override
//   State<VideoCallPageWidget> createState() => _VideoCallPageWidgetState();
// }

// class _VideoCallPageWidgetState extends State<VideoCallPageWidget> {
//   final GlobalKey _localVideoKey = GlobalKey();
//   final GlobalKey _remoteVideoKey = GlobalKey();
//   late FlutterSoundRecorder _recorder;
//   Timer? _recordingTimer;
//   final GoogleSpeechService _speechService = GoogleSpeechService();
//   bool _isSigner = false;
// bool _isRecording = false;
// Timer? _arabicCaptureTimer;
// bool _signLanguageEnabled = false;

//   late RtcEngine _engine;
//   bool _localUserJoined = false;
//   int? _remoteUid;
//   bool _muted = false;
//   bool _cameraOff = false;
//   bool _remoteCameraOff = false;

//   Timer? _mainCaptureTimer;
//   Timer? _englishCaptureTimer;

//   bool isAuthorizedDevice = false;
//   bool englishTriggered = false;

//   String _selectedLanguage = 'English';
//   String _predictedWord = '';
//   Map<String, String> _subtitles = {
//     'English': '',
//     'Arabic': "",
//   };

//   @override
//   void initState() {
//     super.initState();
//     debugPrint(
//         "👇👇👇👇 User ID passed to VideoCallPageWidget: ${widget.userId}");
//     _fetchCallerSettingsAndInit();
//     _listenToRemoteSubtitles();
//   }



// Future<void> _fetchCallerSettingsAndInit() async {
//   try {
//     final response = await http.post(
//       Uri.parse(getCallerSettingsApi),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"callerId": widget.userId}),
//     );

//     if (response.statusCode == 200) {
//       final settings = jsonDecode(response.body);
//       final bool cameraNotEnabled = settings['cameraNotEnabled'] ?? false;
//       final bool micNotEnabled = settings['micNotEnabled'] ?? false;
//       final bool isSigner = settings['signer'] ?? false;

//       setState(() {
//         _cameraOff = cameraNotEnabled;
//         _muted = micNotEnabled;
//         _isSigner = isSigner;
//         _signLanguageEnabled = isSigner; // sync switch ON if signer
//       });

//       // Signer → Start capture if switch is ON
//       if (_signLanguageEnabled && _isSigner) {
//         _restartCaptureBasedOnLanguage();
//       }

//       // Non-signer → Start speech transcription
//       if (!_isSigner) {
//         _startSpeechRecordingLoop();
//       }
//     }
//   } catch (e) {
//     debugPrint("❌ Error fetching caller settings: $e");
//   }

//   await initAgora();
//   await _engine.muteLocalVideoStream(_cameraOff);
//   await _engine.muteLocalAudioStream(_muted);
// }

// void _restartCaptureBasedOnLanguage() {
//   _englishCaptureTimer?.cancel();
//   _arabicCaptureTimer?.cancel();

//   if (_signLanguageEnabled && _isSigner) {
//     if (_selectedLanguage == 'English') {
//       _startEnglishCapture();
//     } else if (_selectedLanguage == 'Arabic') {
//       _startArabicCapture();
//     }
//   }
// }

// Future<void> _startSpeechRecordingLoop() async {
//   if (_isRecording || _muted) return;

//   _recorder = FlutterSoundRecorder();
//   await _recorder.openRecorder();
//   _isRecording = true;

//   () async {
//     while (mounted && !_muted) {
//       try {
//         Directory tempDir = await getTemporaryDirectory();
//         String path = '${tempDir.path}/temp_audio.wav';

//         // ✅ Start recording with print
//         debugPrint("🎙️ [Recording] Started");
//         await _recorder.startRecorder(
//           toFile: path,
//           codec: fs.Codec.pcm16WAV,
//           sampleRate: 16000,
//         );

//         // ✅ Record for slightly longer to capture full sentence
//         await Future.delayed(const Duration(seconds: 3));

//         await _recorder.stopRecorder();
//         debugPrint("🛑 [Recording] Stopped");

//         final transcript = await GoogleSpeechService.transcribeAudio(
//           File(path),
//           _selectedLanguage == 'Arabic' ? 'ar-SA' : 'en-US',
//         );

//         // ✅ Print what was transcribed
//         debugPrint("📝 [Transcript] $transcript");

//         await FirebaseFirestore.instance
//             .collection('calls')
//             .doc(widget.channelName)
//             .collection('subtitles')
//             .doc(widget.userId)
//             .set({
//           'transcript': transcript,
//           'timestamp': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));

//         // Short delay before next recording
//         await Future.delayed(const Duration(milliseconds: 100));
//       } catch (e) {
//         debugPrint("Recording loop error: $e");
//       }
//     }
//     _isRecording = false;
//   }();
// }


//   Future<void> initAgora() async {
//     await [Permission.microphone, Permission.camera].request();
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(RtcEngineContext(
//         appId: appId,
//         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));
//     _engine.registerEventHandler(RtcEngineEventHandler(
//       onJoinChannelSuccess: (_, __) => setState(() => _localUserJoined = true),
//       onUserJoined: (_, uid, __) => setState(() => _remoteUid = uid),
//       onUserOffline: (_, __, ___) => setState(() => _remoteUid = null),
//       onUserMuteVideo: (_, uid, muted) {
//         if (uid == _remoteUid) setState(() => _remoteCameraOff = muted);
//       },
//     ));
//     await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//     await _engine.enableVideo();
//     await _engine.startPreview();
//     await _engine.muteLocalVideoStream(_cameraOff);
//     await _engine.muteLocalAudioStream(_muted);
//     await _engine.joinChannel(
//         token: widget.token,
//         channelId: widget.channelName,
//         uid: widget.uid,
//         options: const ChannelMediaOptions());
//   }



// int _frameCounter = 0; // 🆕 Add this at the top of your class (outside any function)

// Future<void> _captureAndUpload(GlobalKey key, String url, {bool callPredict = false}) async {
//   try {
//     final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary;
//     final image = await boundary.toImage(pixelRatio: 3.0);
//     final byteData = await image.toByteData(format: ImageByteFormat.png);
//     final pngBytes = byteData!.buffer.asUint8List();
//     final fileName = 'frame_${DateTime.now().millisecondsSinceEpoch}.png';

//     final request = http.MultipartRequest('POST', Uri.parse(url))
//       ..files.add(http.MultipartFile.fromBytes('file', pngBytes, filename: fileName));

//     final response = await request.send();
//     if (response.statusCode == 200) {
//       _frameCounter++; // 🆕 Increase frame counter

//       if (callPredict && _frameCounter >= 5) { // 🆕 If 5 frames uploaded
//         _frameCounter = 0; // 🆕 Reset counter
//         await _triggerPrediction(); // 🧠 Now trigger prediction
//       }
//     }
//   } catch (e) {
//     debugPrint('Screenshot error: $e');
//   }
// }




// void _startArabicCapture() {
//   _arabicCaptureTimer?.cancel(); // Just in case
//   _arabicCaptureTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
//     _captureAndUploadScreenshot(
//       _localVideoKey, 
//       'arabic_frame_${DateTime.now().millisecondsSinceEpoch}.png',
//     );
//   });
// }



// Future<void> _captureAndUploadScreenshot(
//     GlobalKey key, String fileName) async {
//   try {
//     RenderRepaintBoundary boundary =
//         key.currentContext?.findRenderObject() as RenderRepaintBoundary;
//     var image = await boundary.toImage(pixelRatio: 3.0);
//     ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
//     Uint8List pngBytes = byteData!.buffer.asUint8List();

//     // Sending the image to the backend
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse(backendUrl),
//     )..files.add(http.MultipartFile.fromBytes(
//         'file',
//         pngBytes,
//         filename: fileName,
//       ));

//     var response = await request.send();

//     if (response.statusCode == 200) {
//       var responseData = await response.stream.bytesToString();
//       var jsonResponse = json.decode(responseData);

//       // Print the extracted keypoints and predicted sign
//       if (jsonResponse['keypoints'] != null &&
//           jsonResponse['predicted_sign'] != null &&
//           jsonResponse['sign_arabic'] != null) {
//         List<dynamic> keypoints = jsonResponse['keypoints'];
//         String predictedSign = jsonResponse['predicted_sign'];
//         String signArabic = jsonResponse['sign_arabic'];

//         // setState(() {
//         //   _predictedSign = signArabic; // Update the predicted sign locally
//         // });

//         debugPrint('✅ Extracted Keypoints: ${keypoints.toString()}');
//         debugPrint('🤟 Predicted Sign: $predictedSign');
//         debugPrint('🔡 Sign Arabic: $signArabic');

//         // ✅ Save to Firestore just like English predictions
//         await FirebaseFirestore.instance
//             .collection('calls')
//             .doc(widget.channelName)
//             .collection('subtitles')
//             .doc(widget.userId)
//             .set({
//           'prediction': signArabic,
//           'timestamp': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));

//       } else {
//         debugPrint('No hands detected or prediction failed!');
//       }
//     } else {
//       debugPrint('❌ Failed to process image: ${response.statusCode}');
//     }
//   } catch (e) {
//     debugPrint('🚨 Error capturing and uploading image: $e');
//   }
// }

// Future<void> _triggerPrediction() async {
//   try {
//     final response = await http.post(Uri.parse(predictionApi));
//     if (response.statusCode == 200) {
//       final result = jsonDecode(response.body);
//               print("🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢$result");

//       final prediction = result['prediction'];

//       // 🔁 Save prediction to Firestore only
//       await FirebaseFirestore.instance
//           .collection('calls')
//           .doc(widget.channelName)
//           .collection('subtitles')
//           .doc(widget.userId)
//           .set({
//         'prediction': prediction,
//         'timestamp': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//     }
//   } catch (e) {
//     debugPrint("Prediction error: $e");
//   }
// }

// void _listenToRemoteSubtitles() {
//   FirebaseFirestore.instance
//       .collection('calls')
//       .doc(widget.channelName)
//       .collection('subtitles')
//       .snapshots()
//       .listen((snapshot) {
//     for (var doc in snapshot.docs) {
//       if (doc.id != widget.userId) {
//         final data = doc.data();

//         setState(() {
//           if (_isSigner) {
//             // signer sees the transcript of the other (non-signer)
//             _subtitles[_selectedLanguage] = data['transcript'] ?? '';
//           } else {
//             // non-signer sees the prediction of the other (signer)
//             _subtitles[_selectedLanguage] = data['prediction'] ?? '';
//           }
//         });
//       }
//     }
//   });
// }



// void _onLanguageChanged(String? newLang) {
//   if (newLang == null) return;

//   setState(() {
//     _selectedLanguage = newLang;
//     englishTriggered = _selectedLanguage == 'English';
//     _subtitles['English'] = '';
//     _subtitles['Arabic'] = '';
//   });

//   _restartCaptureBasedOnLanguage(); // ⬅️ restart correct one
// }


// void _startEnglishCapture() {
//   _englishCaptureTimer?.cancel();
//   _englishCaptureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//     if (englishTriggered && _signLanguageEnabled) {
//       _captureAndUpload(_localVideoKey, secondaryBackendUrl, callPredict: true);
//     }
//   });
// }



//   @override
//   @override
//   void dispose() {
//     _mainCaptureTimer?.cancel();
//     _englishCaptureTimer?.cancel();
//     _recordingTimer?.cancel(); // for speech loop
//     _arabicCaptureTimer?.cancel();
//     _engine.leaveChannel();
//     _engine.release();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: const Text('Video Call'),
//           backgroundColor: const Color(0xFF7B78DA)),
//       body: Stack(children: [
//         Center(child: _remoteVideo()),
//         Align(
//           alignment: Alignment.topLeft,
//           child: SizedBox(
//             width: 100,
//             height: 150,
//             child: RepaintBoundary(
//               key: _localVideoKey,
//               child: _localUserJoined
//                   ? (_cameraOff
//                       ? Container(color: Colors.black)
//                       : AgoraVideoView(
//                           controller: VideoViewController(
//                               rtcEngine: _engine,
//                               canvas: VideoCanvas(uid: widget.uid))))
//                   : const CircularProgressIndicator(),
//             ),
//           ),
//         ),
//         // Control buttons under the local video
// Positioned(
//   top: 160,
//   left: 10,
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       _languageSwitch(),
//       const SizedBox(height: 10),
//       _signLanguageSwitch(), // ← NEW
//       const SizedBox(height: 10),
//       _buildControlButton(
//         icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
//         onPressed: _toggleCamera
//         ,        ),
//       const SizedBox(height: 10),

//       _buildControlButton(
//         icon: Icons.cameraswitch, onPressed: _switchCamera),
//       const SizedBox(height: 10),
//       _buildControlButton(
//         icon: _muted ? Icons.mic_off : Icons.mic,
//         onPressed: _toggleMute,
//                 ),
        
//     ],
//   ),
// ),


// Align(
//   alignment: Alignment.bottomRight,
//   child: Container(
//     margin: const EdgeInsets.only(left: 40, bottom: 20,right: 20), // 👈 Added margin here
//     child: _buildControlButton(
//       icon: Icons.call_end,
//       onPressed: _onEndCall,
//       backgroundColor: Colors.red,
//     ),
//   ),
// ),




//         Positioned(
//           bottom: 100,
//           left: 0,
//           right: 0,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             margin: const EdgeInsets.symmetric(horizontal: 10),
//             decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(12)),
//             child: Text(_subtitles[_selectedLanguage] ?? '',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500)),
//           ),
//         )
//       ]),
//     );
//   }

//   Widget _buildControlButton(
//       {required IconData icon,
//       required VoidCallback onPressed,
//       Color backgroundColor = Colors.grey}) {
//     return Container(
//       decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
//       child: IconButton(
//           icon: Icon(icon, color: Colors.white), onPressed: onPressed),
//     );
//   }


// Widget _languageSwitch() {
//   return GestureDetector(
//     onTap: () {
//       setState(() {
//         _selectedLanguage = _selectedLanguage == 'English' ? 'Arabic' : 'English';
//         englishTriggered = _selectedLanguage == 'English';

//         _subtitles['English'] = '';
//         _subtitles['Arabic'] = '';

//         _englishCaptureTimer?.cancel();
//         _arabicCaptureTimer?.cancel();

//         if (_isSigner) {
//           if (_selectedLanguage == 'English') {
//             _startEnglishCapture();
//           } else {
//             _startArabicCapture();
//           }
//         }
//       });
//     },
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: 80,
//       height: 36,
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey, // Match other buttons
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Selected language label
//           Align(
//             alignment: _selectedLanguage == 'English'
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: Text(
//                 _selectedLanguage == 'English' ? 'EN' : 'AR',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           // Thumb with globe icon
//           AnimatedAlign(
//             duration: const Duration(milliseconds: 300),
//             alignment: _selectedLanguage == 'English'
//                 ? Alignment.centerLeft
//                 : Alignment.centerRight,
//             child: Container(
//               width: 30,
//               height: 30,
//               decoration: const BoxDecoration(
//                 color: Color(0xFF7B78DA), // purple thumb
//                 shape: BoxShape.circle,
//               ),
//               child: const Center(
//                 child: Icon(
//                   Icons.language,
//                   size: 16,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }



// Widget _signLanguageSwitch() {
//   return GestureDetector(
//     onTap: () {
//       setState(() {
//         _signLanguageEnabled = !_signLanguageEnabled;
//       });

//       if (_signLanguageEnabled) {
//         _restartCaptureBasedOnLanguage(); // Start appropriate capture based on language
//       } else {
//         _englishCaptureTimer?.cancel();
//         _arabicCaptureTimer?.cancel();
//       }
//     },
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: 80,
//       height: 36,
//       decoration: BoxDecoration(
//         color: Colors.grey,
//         borderRadius: BorderRadius.circular(30),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 6),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // "On" or "Off" label
//           Align(
//             alignment: _signLanguageEnabled
//                 ? Alignment.centerLeft
//                 : Alignment.centerRight,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Text(
//                 _signLanguageEnabled ? 'On' : 'Off',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),

//           // Icon thumb
//           AnimatedAlign(
//             duration: const Duration(milliseconds: 300),
//             alignment: _signLanguageEnabled
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               width: 30,
//               height: 30,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Color(0xFF7B78DA),
//               ),
//               padding: const EdgeInsets.all(4),
//               child: Image.asset(
//                 'assets/images/Layer_1.png',
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }



//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return _remoteCameraOff
//           ? Container(color: Colors.black)
//           : RepaintBoundary(
//               key: _remoteVideoKey,
//               child: AgoraVideoView(
//                 controller: VideoViewController.remote(
//                   rtcEngine: _engine,
//                   canvas: VideoCanvas(uid: _remoteUid!),
//                   connection: RtcConnection(channelId: widget.channelName),
//                 ),
//               ),
//             );
//     } else {
//       return const Text('Waiting for remote user...',
//           style: TextStyle(color: Colors.grey));
//     }
//   }

//   void _toggleCamera() => _onToggleCamera();
//   void _switchCamera() => _onSwitchCamera();
//   void _toggleMute() => _onToggleMute();

//   void _onToggleCamera() async {
//     setState(() => _cameraOff = !_cameraOff);
//     await _engine.muteLocalVideoStream(_cameraOff);
//   }

//   void _onSwitchCamera() => _engine.switchCamera();

// void _onToggleMute() async {
//   setState(() => _muted = !_muted);
//   await _engine.muteLocalAudioStream(_muted);

//   if (_muted) {
//     // Stop recording
//     if (_isRecording) {
//       await _recorder.stopRecorder();
//       _isRecording = false;
//       debugPrint("🎤 Recorder stopped because mic is muted");
//     }
//   } else {
//     // Restart recording loop
//     _startSpeechRecordingLoop();
//     debugPrint("🎤 Recorder restarted because mic is unmuted");
//   }
// }

// void _onEndCall() async {
//   try {
//     _mainCaptureTimer?.cancel();
//     _englishCaptureTimer?.cancel();
//     _arabicCaptureTimer?.cancel();
//     _recordingTimer?.cancel();

//     setState(() {
//       _subtitles['English'] = '';
//       _subtitles['Arabic'] = '';
//     });

//     if (!_isSigner) {
//       try {
//         await _recorder.stopRecorder();
//       } catch (e) {
//         debugPrint("🎤 Stop recorder error (maybe already stopped): $e");
//       }
//       try {
//         await _recorder.closeRecorder();
//       } catch (e) {
//         debugPrint("🎤 Close recorder error (maybe already closed): $e");
//       }
//     }

//     await FirebaseFirestore.instance
//         .collection('calls')
//         .doc(widget.channelName)
//         .collection('subtitles')
//         .doc(widget.userId)
//         .set({
//       _isSigner ? 'prediction' : 'transcript': '.......',
//       'timestamp': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     await _engine.leaveChannel();
//     await _engine.release();

//     if (mounted) {
//       context.go('/homePage');
//     }
//   } catch (e) {
//     debugPrint("❌ Error during call end cleanup: $e");
//   }
// }
// }


// import 'package:flutter_sound/public/flutter_sound_recorder.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:convert' as convert;
// import 'package:flutter_sound/flutter_sound.dart' as fs;

// import '/flutter_flow/flutter_flow_util.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/rendering.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:http/http.dart' as http;
// import 'dart:ui';
// import 'dart:convert';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';


// const appId = "ec8764a3a509482b9280f1e4d88311c4";
// const backendUrl = "http://192.168.8.136:3002/upload";
// const secondaryBackendUrl = "http://192.168.8.136:3001/frames";
// const predictionApi = "http://192.168.8.136:5000/predict";
// const authorizedDeviceModel = "samsung SM-G998B";
// const getCallerSettingsApi =
//     "https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/get-caller-settings";

// class GoogleSpeechService {
//   static Future<String> transcribeAudio(File audioFile, String languageCode) async {
//     final response = await http.get(
//       Uri.parse("https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/get-google-api-key"),
//     );

//     if (response.statusCode != 200) {
//       return "Failed to load API key";
//     }

//     final apiKey = convert.jsonDecode(response.body)?['apiKey'];
//     if (apiKey == null) return "API key is null";

//     final apiUrl = 'https://speech.googleapis.com/v1/speech:recognize?key=$apiKey';
//     final audioBytes = await audioFile.readAsBytes();
//     final base64Audio = convert.base64Encode(audioBytes);

//     final payload = {
//       'config': {
//         'encoding': 'LINEAR16',
//         'sampleRateHertz': 16000,
//         'languageCode': languageCode,
//       },
//       'audio': {'content': base64Audio},
//     };

//     final responseSTT = await http.post(
//       Uri.parse(apiUrl),
//       headers: {'Content-Type': 'application/json'},
//       body: convert.jsonEncode(payload),
//     );

//     if (responseSTT.statusCode == 200) {
//       final result = convert.jsonDecode(responseSTT.body);
//       if (result['results'] != null && result['results'].isNotEmpty) {
//         return result['results'][0]['alternatives'][0]['transcript'] ?? ".............";
//       } else {
//         return "......";
//       }
//     } else {
//       return "Transcription failed: ${responseSTT.body}";
//     }
//   }
// }


// class VideoCallPageWidget extends StatefulWidget {
//   final String channelName;
//   final String token;
//   final int uid;
//   // final String callId;
//   final String userId;
//   const VideoCallPageWidget({
//     Key? key,
//     required this.channelName,
//     required this.token,
//     required this.uid,
//     // required this.callId,
//     required this.userId,
//   }) : super(key: key);

//   @override
//   State<VideoCallPageWidget> createState() => _VideoCallPageWidgetState();
// }

// class _VideoCallPageWidgetState extends State<VideoCallPageWidget> {
//   final GlobalKey _localVideoKey = GlobalKey();
//   final GlobalKey _remoteVideoKey = GlobalKey();
//   late FlutterSoundRecorder _recorder;
//   Timer? _recordingTimer;
//   final GoogleSpeechService _speechService = GoogleSpeechService();
//   bool _isSigner = false;
// bool _isRecording = false;
// Timer? _arabicCaptureTimer;
// bool _signLanguageEnabled = false;

//   late RtcEngine _engine;
//   bool _localUserJoined = false;
//   int? _remoteUid;
//   bool _muted = false;
//   bool _cameraOff = false;
//   bool _remoteCameraOff = false;

//   Timer? _mainCaptureTimer;
//   Timer? _englishCaptureTimer;

//   bool isAuthorizedDevice = false;
//   bool englishTriggered = false;

//   String _selectedLanguage = 'English';
//   String _predictedWord = '';
//   Map<String, String> _subtitles = {
//     'English': '',
//     'Arabic': "",
//   };

//   @override
//   void initState() {
//     super.initState();
//     debugPrint(
//         "👇👇👇👇 User ID passed to VideoCallPageWidget: ${widget.userId}");
//     _fetchCallerSettingsAndInit();
//     _listenToRemoteSubtitles();
//   }

// Future<void> _fetchCallerSettingsAndInit() async {
//   try {
//     final response = await http.post(
//       Uri.parse(getCallerSettingsApi),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"callerId": widget.userId}),
//     );

//     if (response.statusCode == 200) {
//       final settings = jsonDecode(response.body);
//       final bool cameraNotEnabled = settings['cameraNotEnabled'] ?? false;
//       final bool micNotEnabled = settings['micNotEnabled'] ?? false;
//       final bool isSigner = settings['signer'] ?? false;
//       _signLanguageEnabled = _isSigner; // initial value from API

//       setState(() {
//         _cameraOff = cameraNotEnabled;
//         _muted = micNotEnabled;
//         _isSigner = isSigner;
//         _signLanguageEnabled=isSigner;
//       });

//       if (!_isSigner) {
//         // Non-signer => Start speech transcription only
//         _startSpeechRecordingLoop();
//       }
//     }
//   } catch (e) {
//     debugPrint("❌ Error fetching caller settings: $e");
//   }

//   await initAgora();
//   await _engine.muteLocalVideoStream(_cameraOff);
//   await _engine.muteLocalAudioStream(_muted);
// }


// Future<void> _startSpeechRecordingLoop() async {
//   if (_isRecording || _muted) return;

//   _recorder = FlutterSoundRecorder();
//   await _recorder.openRecorder();
//   _isRecording = true;

//   () async {
//     while (mounted && !_muted) {
//       try {
//         Directory tempDir = await getTemporaryDirectory();
//         String path = '${tempDir.path}/temp_audio.wav';

//         await _recorder.startRecorder(
//           toFile: path,
//           codec: fs.Codec.pcm16WAV,
//           sampleRate: 16000,
//         );

//         await Future.delayed(const Duration(seconds: 2));
//         await _recorder.stopRecorder();

//         final transcript = await GoogleSpeechService.transcribeAudio(
//           File(path),
//           _selectedLanguage == 'Arabic' ? 'ar-SA' : 'en-US',
//         );

//         await FirebaseFirestore.instance
//             .collection('calls')
//             .doc(widget.channelName)
//             .collection('subtitles')
//             .doc(widget.userId)
//             .set({
//           'transcript': transcript,
//           'timestamp': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));

//         await Future.delayed(const Duration(milliseconds: 200));
//       } catch (e) {
//         debugPrint("Recording loop error: $e");
//       }
//     }
//     _isRecording = false;
//   }();
// }

//   // Future<void> _checkAuthorizationAndStartCapture() async {
//   //   final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   //   String model = 'Unknown';
//   //   if (Platform.isAndroid) {
//   //     final androidInfo = await deviceInfo.androidInfo;
//   //     model = '${androidInfo.manufacturer} ${androidInfo.model}';
//   //   } else if (Platform.isIOS) {
//   //     final iosInfo = await deviceInfo.iosInfo;
//   //     model = iosInfo.utsname.machine ?? 'iOS Device';
//   //   }
//   //   isAuthorizedDevice =
//   //       model.toLowerCase() == authorizedDeviceModel.toLowerCase();

//   //   if (isAuthorizedDevice) {
//   //     _mainCaptureTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
//   //       _captureAndUpload(_localVideoKey, backendUrl);
//   //     });
//   //   }
//   // }

//   Future<void> initAgora() async {
//     await [Permission.microphone, Permission.camera].request();
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(RtcEngineContext(
//         appId: appId,
//         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting));
//     _engine.registerEventHandler(RtcEngineEventHandler(
//       onJoinChannelSuccess: (_, __) => setState(() => _localUserJoined = true),
//       onUserJoined: (_, uid, __) => setState(() => _remoteUid = uid),
//       onUserOffline: (_, __, ___) => setState(() => _remoteUid = null),
//       onUserMuteVideo: (_, uid, muted) {
//         if (uid == _remoteUid) setState(() => _remoteCameraOff = muted);
//       },
//     ));
//     await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//     await _engine.enableVideo();
//     await _engine.startPreview();
//     await _engine.muteLocalVideoStream(_cameraOff);
//     await _engine.muteLocalAudioStream(_muted);
//     await _engine.joinChannel(
//         token: widget.token,
//         channelId: widget.channelName,
//         uid: widget.uid,
//         options: const ChannelMediaOptions());
//   }

//   // Future<void> _captureAndUpload(GlobalKey key, String url,
//   //     {bool callPredict = false}) async {
//   //   try {
//   //     final boundary =
//   //         key.currentContext?.findRenderObject() as RenderRepaintBoundary;
//   //     final image = await boundary.toImage(pixelRatio: 3.0);
//   //     final byteData = await image.toByteData(format: ImageByteFormat.png);
//   //     final pngBytes = byteData!.buffer.asUint8List();
//   //     final fileName = 'frame_${DateTime.now().millisecondsSinceEpoch}.png';

//   //     final request = http.MultipartRequest('POST', Uri.parse(url))
//   //       ..files.add(
//   //           http.MultipartFile.fromBytes('file', pngBytes, filename: fileName));

//   //     final response = await request.send();
//   //     if (response.statusCode == 200 && callPredict) {
//   //       await _triggerPrediction();
//   //     }
//   //   } catch (e) {
//   //     debugPrint('Screenshot error: $e');
//   //   }
//   // }

// int _frameCounter = 0; // 🆕 Add this at the top of your class (outside any function)

// Future<void> _captureAndUpload(GlobalKey key, String url, {bool callPredict = false}) async {
//   try {
//     final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary;
//     final image = await boundary.toImage(pixelRatio: 3.0);
//     final byteData = await image.toByteData(format: ImageByteFormat.png);
//     final pngBytes = byteData!.buffer.asUint8List();
//     final fileName = 'frame_${DateTime.now().millisecondsSinceEpoch}.png';

//     final request = http.MultipartRequest('POST', Uri.parse(url))
//       ..files.add(http.MultipartFile.fromBytes('file', pngBytes, filename: fileName));

//     final response = await request.send();
//     if (response.statusCode == 200) {
//       _frameCounter++; // 🆕 Increase frame counter

//       if (callPredict && _frameCounter >= 5) { // 🆕 If 5 frames uploaded
//         _frameCounter = 0; // 🆕 Reset counter
//         await _triggerPrediction(); // 🧠 Now trigger prediction
//       }
//     }
//   } catch (e) {
//     debugPrint('Screenshot error: $e');
//   }
// }




// void _startArabicCapture() {
//   _arabicCaptureTimer?.cancel(); // Just in case
//   _arabicCaptureTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
//     _captureAndUploadScreenshot(
//       _localVideoKey, 
//       'arabic_frame_${DateTime.now().millisecondsSinceEpoch}.png',
//     );
//   });
// }



// Future<void> _captureAndUploadScreenshot(
//     GlobalKey key, String fileName) async {
//   try {
//     RenderRepaintBoundary boundary =
//         key.currentContext?.findRenderObject() as RenderRepaintBoundary;
//     var image = await boundary.toImage(pixelRatio: 3.0);
//     ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
//     Uint8List pngBytes = byteData!.buffer.asUint8List();

//     // Sending the image to the backend
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse(backendUrl),
//     )..files.add(http.MultipartFile.fromBytes(
//         'file',
//         pngBytes,
//         filename: fileName,
//       ));

//     var response = await request.send();

//     if (response.statusCode == 200) {
//       var responseData = await response.stream.bytesToString();
//       var jsonResponse = json.decode(responseData);

//       // Print the extracted keypoints and predicted sign
//       if (jsonResponse['keypoints'] != null &&
//           jsonResponse['predicted_sign'] != null &&
//           jsonResponse['sign_arabic'] != null) {
//         List<dynamic> keypoints = jsonResponse['keypoints'];
//         String predictedSign = jsonResponse['predicted_sign'];
//         String signArabic = jsonResponse['sign_arabic'];

//         // setState(() {
//         //   _predictedSign = signArabic; // Update the predicted sign locally
//         // });

//         debugPrint('✅ Extracted Keypoints: ${keypoints.toString()}');
//         debugPrint('🤟 Predicted Sign: $predictedSign');
//         debugPrint('🔡 Sign Arabic: $signArabic');

//         // ✅ Save to Firestore just like English predictions
//         await FirebaseFirestore.instance
//             .collection('calls')
//             .doc(widget.channelName)
//             .collection('subtitles')
//             .doc(widget.userId)
//             .set({
//           'prediction': signArabic,
//           'timestamp': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));

//       } else {
//         debugPrint('No hands detected or prediction failed!');
//       }
//     } else {
//       debugPrint('❌ Failed to process image: ${response.statusCode}');
//     }
//   } catch (e) {
//     debugPrint('🚨 Error capturing and uploading image: $e');
//   }
// }

// Future<void> _triggerPrediction() async {
//   try {
//     final response = await http.post(Uri.parse(predictionApi));
//     if (response.statusCode == 200) {
//       final result = jsonDecode(response.body);
//               print("🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢$result");

//       final prediction = result['prediction'];

//       // 🔁 Save prediction to Firestore only
//       await FirebaseFirestore.instance
//           .collection('calls')
//           .doc(widget.channelName)
//           .collection('subtitles')
//           .doc(widget.userId)
//           .set({
//         'prediction': prediction,
//         'timestamp': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//     }
//   } catch (e) {
//     debugPrint("Prediction error: $e");
//   }
// }

// void _listenToRemoteSubtitles() {
//   FirebaseFirestore.instance
//       .collection('calls')
//       .doc(widget.channelName)
//       .collection('subtitles')
//       .snapshots()
//       .listen((snapshot) {
//     for (var doc in snapshot.docs) {
//       if (doc.id != widget.userId) {
//         final data = doc.data();

//         setState(() {
//           if (_isSigner) {
//             // signer sees the transcript of the other (non-signer)
//             _subtitles[_selectedLanguage] = data['transcript'] ?? '';
//           } else {
//             // non-signer sees the prediction of the other (signer)
//             _subtitles[_selectedLanguage] = data['prediction'] ?? '';
//           }
//         });
//       }
//     }
//   });
// }

// void _onLanguageChanged(String? newLang) {
//   if (newLang == null) return;
  
//   setState(() {
//     _selectedLanguage = newLang;
//     englishTriggered = newLang == 'English';
    
//     // ✅ Clear the subtitle text when switching language
//     _subtitles['English'] = '';
//     _subtitles['Arabic'] = '';
//   });

//   // Cancel previous timers first
//   _englishCaptureTimer?.cancel();
//   _arabicCaptureTimer?.cancel();

//   if (_isSigner) {
//     if (newLang == 'English') {
//       _startEnglishCapture();
//     } else if (newLang == 'Arabic') {
//       _startArabicCapture();
//     }
//   }
// }






//   void _startEnglishCapture() {
//     _englishCaptureTimer?.cancel();
//     _englishCaptureTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
//       if (englishTriggered) {
//         _captureAndUpload(_localVideoKey, secondaryBackendUrl,
//             callPredict: true);
//       }
//     });
//   }

//   @override
//   @override
//   void dispose() {
//     _mainCaptureTimer?.cancel();
//     _englishCaptureTimer?.cancel();
//     _recordingTimer?.cancel(); // for speech loop
//     _arabicCaptureTimer?.cancel();
//     _engine.leaveChannel();
//     _engine.release();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: const Text('Video Call'),
//           backgroundColor: const Color(0xFF7B78DA)),
//       body: Stack(children: [
//         Center(child: _remoteVideo()),
//         Align(
//           alignment: Alignment.topLeft,
//           child: SizedBox(
//             width: 100,
//             height: 150,
//             child: RepaintBoundary(
//               key: _localVideoKey,
//               child: _localUserJoined
//                   ? (_cameraOff
//                       ? Container(color: Colors.black)
//                       : AgoraVideoView(
//                           controller: VideoViewController(
//                               rtcEngine: _engine,
//                               canvas: VideoCanvas(uid: widget.uid))))
//                   : const CircularProgressIndicator(),
//             ),
//           ),
//         ),
//         // Control buttons under the local video
// Positioned(
//   top: 160,
//   left: 10,
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       _languageSwitch(),
//       const SizedBox(height: 10),
//       _signLanguageSwitch(), // ← NEW
//       const SizedBox(height: 10),
//       _buildControlButton(
//         icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
//         onPressed: _toggleCamera),
//       const SizedBox(height: 10),
//       _buildControlButton(
//         icon: Icons.cameraswitch, onPressed: _switchCamera),
//       const SizedBox(height: 10),
//       _buildControlButton(
//         icon: _muted ? Icons.mic_off : Icons.mic,
//         onPressed: _toggleMute),
//     ],
//   ),
// ),


// // Keep End Call button at bottom center
// Align(
//   alignment: Alignment.bottomCenter,
//   child: Padding(
//     padding: const EdgeInsets.only(bottom: 20),
//     child: _buildControlButton(
//       icon: Icons.call_end,
//       onPressed: _onEndCall,
//       backgroundColor: Colors.red),
//   ),
// ),






//         Positioned(
//           bottom: 100,
//           left: 0,
//           right: 0,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             margin: const EdgeInsets.symmetric(horizontal: 10),
//             decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(12)),
//             child: Text(_subtitles[_selectedLanguage] ?? '',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500)),
//           ),
//         )
//       ]),
//     );
//   }

//   Widget _buildControlButton(
//       {required IconData icon,
//       required VoidCallback onPressed,
//       Color backgroundColor = Colors.grey}) {
//     return Container(
//       decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
//       child: IconButton(
//           icon: Icon(icon, color: Colors.white), onPressed: onPressed),
//     );
//   }


// Widget _languageSwitch() {
//   return GestureDetector(
//     onTap: () {
//       setState(() {
//         _selectedLanguage = _selectedLanguage == 'English' ? 'Arabic' : 'English';
//         englishTriggered = _selectedLanguage == 'English';

//         _subtitles['English'] = '';
//         _subtitles['Arabic'] = '';

//         _englishCaptureTimer?.cancel();
//         _arabicCaptureTimer?.cancel();

//         if (_isSigner) {
//           if (_selectedLanguage == 'English') {
//             _startEnglishCapture();
//           } else {
//             _startArabicCapture();
//           }
//         }
//       });
//     },
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: 80,
//       height: 36,
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey, // Match other buttons
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Selected language label
//           Align(
//             alignment: _selectedLanguage == 'English'
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: Text(
//                 _selectedLanguage == 'English' ? 'EN' : 'AR',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           // Thumb with globe icon
//           AnimatedAlign(
//             duration: const Duration(milliseconds: 300),
//             alignment: _selectedLanguage == 'English'
//                 ? Alignment.centerLeft
//                 : Alignment.centerRight,
//             child: Container(
//               width: 30,
//               height: 30,
//               decoration: const BoxDecoration(
//                 color: Color(0xFF7B78DA), // purple thumb
//                 shape: BoxShape.circle,
//               ),
//               child: const Center(
//                 child: Icon(
//                   Icons.language,
//                   size: 16,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }


// Widget _signLanguageSwitch() {
//   return GestureDetector(
//     onTap: () {
//       setState(() {
//         _signLanguageEnabled = !_signLanguageEnabled;
//       });
//     },
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: 80,
//       height: 36,
//       decoration: BoxDecoration(
//         color: Colors.grey, // dark enough to contrast the white image
//         borderRadius: BorderRadius.circular(30),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 6),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // "On" or "Off" label
//           Align(
//             alignment: _signLanguageEnabled
//                 ? Alignment.centerLeft
//                 : Alignment.centerRight,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Text(
//                 _signLanguageEnabled ? 'On' : 'Off',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),

//           // Icon switch thumb
//           AnimatedAlign(
//             duration: const Duration(milliseconds: 300),
//             alignment: _signLanguageEnabled
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               width: 30,
//               height: 30,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Color(0xFF7B78DA), // match light gray background of image
//               ),
//               padding: const EdgeInsets.all(4),
//               child: Image.asset(
//                 'assets/images/Layer_1.png',
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }







//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return _remoteCameraOff
//           ? Container(color: Colors.black)
//           : RepaintBoundary(
//               key: _remoteVideoKey,
//               child: AgoraVideoView(
//                 controller: VideoViewController.remote(
//                   rtcEngine: _engine,
//                   canvas: VideoCanvas(uid: _remoteUid!),
//                   connection: RtcConnection(channelId: widget.channelName),
//                 ),
//               ),
//             );
//     } else {
//       return const Text('Waiting for remote user...',
//           style: TextStyle(color: Colors.grey));
//     }
//   }

//   void _toggleCamera() => _onToggleCamera();
//   void _switchCamera() => _onSwitchCamera();
//   void _toggleMute() => _onToggleMute();

//   void _onToggleCamera() async {
//     setState(() => _cameraOff = !_cameraOff);
//     await _engine.muteLocalVideoStream(_cameraOff);
//   }

//   void _onSwitchCamera() => _engine.switchCamera();

// void _onToggleMute() async {
//   setState(() => _muted = !_muted);
//   await _engine.muteLocalAudioStream(_muted);

//   if (_muted) {
//     // Stop recording
//     if (_isRecording) {
//       await _recorder.stopRecorder();
//       _isRecording = false;
//       debugPrint("🎤 Recorder stopped because mic is muted");
//     }
//   } else {
//     // Restart recording loop
//     _startSpeechRecordingLoop();
//     debugPrint("🎤 Recorder restarted because mic is unmuted");
//   }
// }

// void _onEndCall() async {
//   try {
//     _mainCaptureTimer?.cancel();
//     _englishCaptureTimer?.cancel();
//     _arabicCaptureTimer?.cancel();
//     _recordingTimer?.cancel();

//     setState(() {
//       _subtitles['English'] = '';
//       _subtitles['Arabic'] = '';
//     });

//     if (!_isSigner) {
//       try {
//         await _recorder.stopRecorder();
//       } catch (e) {
//         debugPrint("🎤 Stop recorder error (maybe already stopped): $e");
//       }
//       try {
//         await _recorder.closeRecorder();
//       } catch (e) {
//         debugPrint("🎤 Close recorder error (maybe already closed): $e");
//       }
//     }

//     await FirebaseFirestore.instance
//         .collection('calls')
//         .doc(widget.channelName)
//         .collection('subtitles')
//         .doc(widget.userId)
//         .set({
//       _isSigner ? 'prediction' : 'transcript': '.......',
//       'timestamp': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     await _engine.leaveChannel();
//     await _engine.release();

//     if (mounted) {
//       context.go('/homePage');
//     }
//   } catch (e) {
//     debugPrint("❌ Error during call end cleanup: $e");
//   }
// }
// }

