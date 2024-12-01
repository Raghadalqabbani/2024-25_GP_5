import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

const String getCallDetailsURL =
    'https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/get-call';
const String cancelCallURL = 'https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/cancel-call';
const String videoInfoURL = 'https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/video-info';

class CallPage extends StatefulWidget {
  final String callId;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;

  const CallPage({
    Key? key,
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  String _callStatus = "calling"; // Default status
  Timer? _statusTimer;
  bool _isNavigating = false; // Prevent duplicate navigation

  @override
  void initState() {
    super.initState();
    _startPollingCallStatus(); // Start polling the backend for status updates
  }

  @override
  void dispose() {
    _statusTimer?.cancel(); // Cancel the timer when leaving the page
    super.dispose();
  }

  /// Periodically poll the backend for call status
  void _startPollingCallStatus() {
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final response = await http.get(
          Uri.parse('$getCallDetailsURL?callId=${widget.callId}'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final newStatus = data['status'];

          if (newStatus != _callStatus) {
            setState(() {
              _callStatus = newStatus;
            });

            if (newStatus == "accepted") {
              _handleAcceptedCall();
            } else if (newStatus == "rejected") {
              _handleRejectedCall();
            }
          }
        } else {
          print("Failed to fetch call status: ${response.body}");
        }
      } catch (e) {
        print("Error fetching call status: $e");
      }
    });
  }

  /// Handle call acceptance
  Future<void> _handleAcceptedCall() async {
    if (_isNavigating) return; // Prevent duplicate navigation
    _isNavigating = true;

    _statusTimer?.cancel(); // Stop polling

    try {
      final response = await http.get(
        Uri.parse('$videoInfoURL?callId=${widget.callId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final channelName = data['channelName'];

        print("Video Info retrieved successfully:");
        print("Token: $token");
        print("Channel Name: $channelName");

        // Navigate to the video call page with the token and channel name
        _navigateToVideoCall(token, channelName);
      } else {
        print("Failed to fetch video info: ${response.body}");
      }
    } catch (e) {
      print("Error fetching video info: $e");
    }
  }

  /// Handle call rejection
  void _handleRejectedCall() {
    _statusTimer?.cancel(); // Stop polling
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Call Rejected",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "${widget.receiverName} has rejected the call.",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Rounded corners
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Navigate back to the previous page
            },
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to the video call page
  void _navigateToVideoCall(String token, String channelName) {
    GoRouter.of(context).go(
      '/videoCallPage',
      extra: {
        'token': token,
        'channelName': channelName,
      },
    );
  }

  /// Cancel the ongoing call and return to the previous page
  Future<void> _cancelCall() async {
    try {
      final response = await http.post(
        Uri.parse(cancelCallURL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'callId': widget.callId}),
      );

      if (response.statusCode == 200) {
        print("Call cancelled successfully.");
      } else {
        print("Failed to cancel call: ${response.body}");
      }
    } catch (e) {
      print("Error cancelling call: $e");
    } finally {
      _statusTimer?.cancel(); // Stop polling
      Navigator.pop(context); // Navigate back
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calling..."),
        backgroundColor: const Color(0xFF7B78DA),
        automaticallyImplyLeading: false, // Disable back navigation
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Receiver's name
            Text(
              "Calling ${widget.receiverName}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Current call status
            Text(
              "Status: $_callStatus",
              style: TextStyle(
                fontSize: 18,
                color: _callStatus == "calling"
                    ? Colors.orange
                    : _callStatus == "accepted"
                        ? Colors.green
                        : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // Cancel Call Button
            ElevatedButton.icon(
              onPressed: _cancelCall,
              icon: const Icon(Icons.call_end),
              label: const Text("Cancel Call"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
