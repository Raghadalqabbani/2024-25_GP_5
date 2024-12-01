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


// Agora app ID
const appId = "ec8764a3a509482b9280f1e4d88311c4";

// Backend server URL
const backendUrl = "http://192.168.0.202:3002/upload";

class VideoCallPageWidget extends StatefulWidget {
  final String channelName; // Dynamic channel name
  final String token; // Dynamic token

  const VideoCallPageWidget({
    Key? key,
    required this.channelName,
    required this.token,
  }) : super(key: key);

  @override
  State<VideoCallPageWidget> createState() => _VideoCallPageWidgetState();
}

class _VideoCallPageWidgetState extends State<VideoCallPageWidget> {
  final GlobalKey _localVideoKey = GlobalKey(); // Key for capturing local video
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _muted = false;
  bool _cameraOff = false;
  bool _remoteCameraOff = false;
  late RtcEngine _engine;
  Timer? _captureTimer; // Timer for periodic screenshots

  @override
  void initState() {
    super.initState();
    initAgora();

    // Start periodic screenshots of the local video
    _captureTimer = Timer.periodic(
      const Duration(seconds: 3), // Take a screenshot every 3 seconds
      (timer) {
        _captureAndUploadScreenshot(
          _localVideoKey,
          'local_video_${DateTime.now().millisecondsSinceEpoch}.png',
        );
      },
    );
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onUserMuteVideo: (RtcConnection connection, int uid, bool muted) {
          debugPrint("User $uid muted video: $muted");
          setState(() {
            if (uid == _remoteUid) {
              _remoteCameraOff = muted;
            }
          });
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: 0, // Use 0 for default UID or specify a unique UID if needed
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> _captureAndUploadScreenshot(GlobalKey key, String fileName) async {
  try {
    RenderRepaintBoundary boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Sending the image to the backend
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(backendUrl),
    )
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        pngBytes,
        filename: fileName,
      ));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      // Print landmarks in Flutter console
      if (jsonResponse['landmarks'] != null) {
        for (var hand in jsonResponse['landmarks']) {
          debugPrint('Hand ${hand['hand_index']} Landmarks:');
          for (var landmark in hand['landmarks']) {
            debugPrint(
                '  ID: ${landmark['id']}, X: ${landmark['x']}, Y: ${landmark['y']}, Z: ${landmark['z']}');
          }
        }
      } else {
        debugPrint('No hands detected!');
      }
    } else {
      debugPrint('Failed to process image: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error capturing and uploading image: $e');
  }
}


  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _engine.muteLocalAudioStream(_muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void _onToggleCamera() async {
    setState(() {
      _cameraOff = !_cameraOff;
    });
    await _engine.muteLocalVideoStream(_cameraOff);
  }

  void _onEndCall() {
    _dispose();
    context.go('/homePage'); // Navigate back to the home page
  }

  Future<void> _dispose() async {
    _captureTimer?.cancel(); // Stop the timer
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        backgroundColor: const Color(0xFF7B78DA),
      ),
      body: Stack(
        children: [
          Center(child: _remoteVideo()),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: RepaintBoundary(
                key: _localVideoKey, // Key for capturing local video
                child: _localUserJoined
                    ? (_cameraOff
                        ? Container(color: Colors.black)
                        : AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _engine,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          ))
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildControlButton(
                        icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
                        onPressed: _onToggleCamera,
                      ),
                      const SizedBox(width: 10),
                      _buildControlButton(
                        icon: Icons.cameraswitch,
                        onPressed: _onSwitchCamera,
                      ),
                      const SizedBox(width: 10),
                      _buildControlButton(
                        icon: _muted ? Icons.mic_off : Icons.mic,
                        onPressed: _onToggleMute,
                      ),
                    ],
                  ),
                  _buildControlButton(
                    icon: Icons.call_end,
                    onPressed: _onEndCall,
                    backgroundColor: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.grey,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return _remoteCameraOff
          ? Container(color: Colors.black)
          : AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: widget.channelName),
              ),
            );
    } else {
      return const Text(
        'Waiting for remote user...',
        style: TextStyle(color: Colors.grey),
      );
    }
  }
}
