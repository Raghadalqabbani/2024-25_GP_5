import 'package:flutter/material.dart';
import 'speech_to_text_page_model.dart';

class SpeechToTextPageWidget extends StatefulWidget {
  const SpeechToTextPageWidget({super.key});

  @override
  State<SpeechToTextPageWidget> createState() => _SpeechToTextPageWidgetState();
}

class _SpeechToTextPageWidgetState extends State<SpeechToTextPageWidget> {
  late SpeechToTextPageModel _model;
  bool _isEnglish = true; // Toggle for language (English by default)
  bool _isPressed = false; // Track if the button is pressed for the glow effect

  @override
  void initState() {
    super.initState();
    _model = SpeechToTextPageModel();
    _model.openAudioSession();
  }

  @override
  void dispose() {
    _model.closeAudioSession();
    super.dispose();
  }

  // Function to toggle the language and translate the text inside the box
  void toggleLanguage() {
    setState(() {
      _isEnglish = !_isEnglish;
      _model.selectedLanguage = _isEnglish ? 'en-US' : 'ar-SA';
      if (_model.transcribedText.isNotEmpty) {
        // Translate placeholder text if switching languages
        _model.transcribedText = _isEnglish
            ? 'Transcribed text will appear here...'
            : 'تحدث معي';
      }
    });
  }

  // Handle recording press and release with glow effect
  Future<void> handleRecordingPress() async {
    await _model.startRecording();
    setState(() {
      _isPressed = true; // Enable glow when pressed
    });
  }

  Future<void> handleRecordingRelease() async {
    // Clear the previous transcribed text immediately when stopping
    setState(() {
      _model.transcribedText = ''; // Clear previous text
    });

    await _model.stopRecording();
    setState(() {
      _isPressed = false; // Remove glow when released
    });

    await _model.transcribeAudio(); // Transcribe the new audio
    setState(() {}); // Update the UI with the new transcription
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B78DA), // Applied #7B78DA to app bar
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Speech to Text', // Title stays in English regardless of language
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        elevation: 2.0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Translation icon under the app bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.translate, size: 30, color: Color(0xFF7B78DA)), // Larger translation icon
                        onPressed: toggleLanguage,
                      ),
                    ],
                  ),
                  const Spacer(flex: 2), // Push the main content slightly above the center
                  // Main content section
                  Center(
                    child: Container(
                      width: 300, // Fixed width for the outer container
                      padding: const EdgeInsets.symmetric(vertical: 24.0), // Padding for spacing
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.2), // Slight shadow for elevation
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Button with noticeable glow effect only on press
                          Container(
                            width: 80, // Slightly smaller button
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF7B78DA), // Applied #7B78DA to the button background
                              boxShadow: _isPressed
                                  ? [
                                      BoxShadow(
                                        color: Colors.blueAccent.withOpacity(0.6), // More noticeable glow
                                        blurRadius: 40.0,
                                        spreadRadius: 5.0,
                                      )
                                    ]
                                  : [],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.mic, // Only the mic icon
                                size: 36,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                if (_model.isRecording) {
                                  await handleRecordingRelease(); // Stop recording and transcribe
                                } else {
                                  await handleRecordingPress(); // Start recording with glow
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Text to show current action (Start/Stop recording)
                          Text(
                            _model.isRecording
                                ? (_isEnglish
                                    ? 'Recording... Tap to stop'
                                    : 'جارٍ التسجيل... اضغط للإيقاف')
                                : (_isEnglish
                                    ? 'Tap to start recording'
                                    : 'اضغط لبدء التسجيل'),
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 20),
                          // Transcription text box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _model.transcribedText.isNotEmpty
                                  ? _model.transcribedText
                                  : (_isEnglish
                                      ? 'Transcribed text will appear here...'
                                      : 'تحدث معي'),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black, // Transcription text is black
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3), // Adjust the content to be above the center
                ],
              ),
            ),
            // Bottom navigation bar
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: Container(
                width: double.infinity,
                height: 80.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF7B78DA),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4.0,
                      color: Color(0x33000000),
                      offset: Offset(0.0, -2.0),
                      spreadRadius: 0.0,
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                // Navigate to HomePage
                                Navigator.pushNamed(context, 'HomePage');
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.asset(
                                  'assets/images/Layer_1.png',
                                  width: 48.0,
                                  height: 48.0,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                // Navigate to ContactsPage
                                Navigator.pushNamed(context, 'ContactsPage');
                              },
                              child: const Icon(
                                Icons.videocam_rounded,
                                color: Colors.white,
                                size: 35.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                // Navigate to SpeechToTextPage
                                Navigator.pushNamed(context, 'SpeechToTextPage');
                              },
                              child: const Icon(
                                Icons.mic_rounded,
                                color: Colors.white,
                                size: 35.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                // Navigate to ProfilePage
                                Navigator.pushNamed(context, 'ProfilePage');
                              },
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 35.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
