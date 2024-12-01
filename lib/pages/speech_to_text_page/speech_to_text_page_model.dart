import '/flutter_flow/flutter_flow_util.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:developer'; // For logging
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class GoogleSpeechService {
  // Fetch API Key from environment variable
  final String apiKey = const String.fromEnvironment('API_KEY', defaultValue: 'No API Key Provided');

  Future<String> transcribeAudio(File audioFile, String languageCode) async {
    final String apiUrl = 'https://speech.googleapis.com/v1/speech:recognize?key=$apiKey';

    // Convert audio file to base64
    List<int> audioBytes = await audioFile.readAsBytes();
    String base64Audio = base64Encode(audioBytes);

    // Create the request payload
    Map<String, dynamic> requestPayload = {
      'config': {
        'encoding': 'LINEAR16',
        'sampleRateHertz': 16000,
        'languageCode': languageCode,
      },
      'audio': {
        'content': base64Audio,
      }
    };

    log("Sending transcription request...");
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestPayload),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      log("Transcription result: $result");

      // Check if results array is not null and contains transcriptions
      if (result['results'] != null && result['results'].isNotEmpty) {
        final String transcription = result['results'][0]['alternatives'][0]['transcript'];
        return transcription;
      } else {
        return "No transcription available.";
      }
    } else {
      log("Transcription failed: ${response.body}");
      throw Exception('Failed to transcribe audio: ${response.body}');
    }
  }
}

class SpeechToTextPageModel {
  FlutterSoundRecorder? _recorder;
  bool isRecording = false;
  String recordedFilePath = '';
  String transcribedText = '';
  final GoogleSpeechService speechService = GoogleSpeechService();
  String selectedLanguage = 'en-US'; // Default language is English

  Future<void> openAudioSession() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
  }

  Future<void> closeAudioSession() async {
    await _recorder!.closeRecorder();
  }

  Future<void> startRecording() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      Directory tempDir = await getTemporaryDirectory();
      String path = '${tempDir.path}/temp_audio.wav';

      await _recorder!.startRecorder(
        toFile: path,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
      );

      isRecording = true;
      recordedFilePath = path;
      transcribedText = ''; // Clear placeholder text on recording start
    } else {
      throw Exception('Microphone permission denied.');
    }
  }

  Future<void> stopRecording() async {
    await _recorder!.stopRecorder();
    isRecording = false;
  }

  Future<void> transcribeAudio() async {
    if (recordedFilePath.isNotEmpty) {
      try {
        File audioFile = File(recordedFilePath);
        transcribedText = await speechService.transcribeAudio(audioFile, selectedLanguage);
        log("Transcription successful: $transcribedText");
      } catch (e) {
        log("Transcription failed: $e");
        transcribedText = "try again";
      }
    }
  }
}