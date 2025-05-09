import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mubayin/flutter_flow/flutter_flow_util.dart';
import 'package:mubayin/pages/speech_to_text_page/speech_to_text_page_model.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class SpeechToTextPageWidget extends StatefulWidget {
  const SpeechToTextPageWidget({super.key});

  @override
  State<SpeechToTextPageWidget> createState() => _SpeechToTextPageWidgetState();
}

class _SpeechToTextPageWidgetState extends State<SpeechToTextPageWidget> {
  bool _isListening = false;
  String _transcribedText = '';
  bool _isEnglish = true;
late SpeechToTextPageModel _model;
bool _isTranscribing = false;

  @override
  void initState() {
    super.initState();
     _model = SpeechToTextPageModel();
  _model.openAudioSession();
  }
void toggleLanguage() {
  setState(() {
    _isEnglish = !_isEnglish;
    _transcribedText = '';
    _model.selectedLanguage = _isEnglish ? 'en-US' : 'ar-SA'; // <<< ADD THIS LINE
  });
}

Future<void> handleMicPress() async {
  if (!_isListening) {
    // Start recording
    await _model.startRecording();
    setState(() {
      _isListening = true;
      _transcribedText = '';
      _isTranscribing = false;
    });
  } else {
    // Stop recording
    await _model.stopRecording();
    setState(() {
      _isListening = false;
      _isTranscribing = true;
    });

    // 👉 Important: Delay the transcription until the next event loop
    Future.microtask(() async {
      await _model.transcribeAudio();

      setState(() {
        _transcribedText = _model.transcribedText;
        _isTranscribing = false;
      });

      // BONUS: Delete temp audio file
      if (_model.recordedFilePath.isNotEmpty) {
        try {
          final file = File(_model.recordedFilePath);
          if (await file.exists()) {
            await file.delete();
            print('Temp audio deleted.');
          }
        } catch (e) {
          print('Failed to delete temp audio: $e');
        }
      }
    });
  }
}



    // BONUS: Delete temp audio file...

@override
void dispose() {
  _model.closeAudioSession();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).mediumSlateBlue,
        elevation: 0,
        title: Align(
          alignment: const AlignmentDirectional(-1.0, 0.0),
          child: Text(
            'Speech to Text',
            textAlign: TextAlign.start,
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Urbanist',
                  color: FlutterFlowTheme.of(context).babyPowder,
                  fontSize: 30.0,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [



                          // GestureDetector(
                          //   onTap: toggleLanguage,
                          //   child: AnimatedContainer(
                          //     duration: const Duration(milliseconds: 300),
                          //     width: 80,
                          //     height: 40,
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(20),
                          //       color: FlutterFlowTheme.of(context).mediumSlateBlue,
                          //     ),
                          //     child: Stack(
                          //       children: [
                          //         Positioned(
                          //           left: 8,
                          //           top: 5,
                          //           child: _isEnglish
                          //               ? Container(
                          //                   width: 36,
                          //                   height: 30,
                          //                   decoration: BoxDecoration(
                          //                     borderRadius: BorderRadius.circular(15),
                          //                     color: Colors.white,
                          //                   ),
                          //                   child: Center(
                          //                     child: Text(
                          //                       'A',
                          //                       style: TextStyle(
                          //                         fontSize: 20,
                          //                         fontWeight: FontWeight.bold,
                          //                         color: FlutterFlowTheme.of(context).mediumSlateBlue,
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 )
                          //               : Center(
                          //                   child: Text(
                          //                     'A',
                          //                     style: TextStyle(
                          //                       fontSize: 20,
                          //                       fontWeight: FontWeight.bold,
                          //                       color: Colors.white.withOpacity(0.5),
                          //                     ),
                          //                   ),
                          //                 ),
                          //         ),
                          //         Positioned(
                          //           right: 8,
                          //           top: 5,
                          //           child: !_isEnglish
                          //               ? Container(
                          //                   width: 36,
                          //                   height: 30,
                          //                   decoration: BoxDecoration(
                          //                     borderRadius: BorderRadius.circular(15),
                          //                     color: Colors.white,
                          //                   ),
                          //                   child: Center(
                          //                     child: Text(
                          //                       'ع',
                          //                       style: TextStyle(
                          //                         fontSize: 20,
                          //                         fontWeight: FontWeight.bold,
                          //                         color: FlutterFlowTheme.of(context).mediumSlateBlue,
                          //                       ),
                          //                     ),
                          //                   ),
                          //                 )
                          //               : Center(
                          //                   child: Text(
                          //                     'ع',
                          //                     style: TextStyle(
                          //                       fontSize: 20,
                          //                       fontWeight: FontWeight.bold,
                          //                       color: Colors.white.withOpacity(0.5),
                          //                     ),
                          //                   ),
                          //                 ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),




GestureDetector(
  onTap: toggleLanguage,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: 100,
    height: 44,
    decoration: BoxDecoration(
      color: Colors.grey[200], // Light background
      borderRadius: BorderRadius.circular(30),
    ),
    child: Stack(
      children: [
        // Thumb (circle)
        AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          alignment: _isEnglish ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF7B78DA), // Purple thumb
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.language,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        // EN / AR labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 50,
              height: 44,
              alignment: Alignment.center,
              child: Text(
                // 'EN',
                                'AR',

                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isEnglish ? Colors.transparent : const Color.fromARGB(255, 91, 90, 90), // dark gray if visible
                ),
              ),
            ),
            Container(
              width: 50,
              height: 44,
              alignment: Alignment.center,
              child: Text(
                // 'AR',
                                'EN',

                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: !_isEnglish ? Colors.transparent : const Color.fromARGB(255, 91, 90, 90), // dark gray if visible
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),


                          const SizedBox(height: 4),
                          Text(
                            _isEnglish ? 'Language' : 'اللغة',
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                  Center(
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF7B78DA),
                              boxShadow: _isListening
                                  ? [
                                      BoxShadow(
                                        color: Colors.blueAccent.withOpacity(0.6),
                                        blurRadius: 40.0,
                                        spreadRadius: 5.0,
                                      )
                                    ]
                                  : [],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.mic,
                                size: 36,
                                color: Colors.white,
                              ),
                              onPressed: handleMicPress,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _isListening
                                ? (_isEnglish ? 'Listening... Tap to stop' : 'جارٍ الاستماع... اضغط للإيقاف')
                                : (_isEnglish ? 'Tap to start listening' : 'اضغط لبدء الاستماع'),
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          const SizedBox(height: 20),


      Container(
  padding: const EdgeInsets.all(16),
  width: double.infinity,
  decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(8),
  ),
  child: _isTranscribing
      ? Center(child: CircularProgressIndicator(color: Colors.blue))
      : SingleChildScrollView(
          child: Text(
            _transcribedText.isNotEmpty
                ? _transcribedText
                : (_isEnglish ? 'Speak with me....' : '....تحدث معي'),
            style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 69, 65, 65)),
            textAlign: TextAlign.center,
          ),
        ),
),







                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: Container(
                width: double.infinity,
                height: 80.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).mediumSlateBlue,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4.0,
                      color: Color(0x33000000),
                      offset: Offset(
                        0.0,
                        -2.0,
                      ),
                      spreadRadius: 0.0,
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavButton('HomePage', 'assets/images/Layer_1.png'),
                      _buildNavButton('ContactsPage', null, icon: Icons.videocam_rounded),
                      _buildNavButton('SpeechToTextPage', null, icon: Icons.mic_rounded),
                      _buildNavButton('ProfilePage', null, icon: Icons.person_rounded),
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

  Widget _buildNavButton(String route, String? imagePath, {IconData? icon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: InkWell(
            onTap: () {
              context.pushNamed(route);
            },
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      imagePath,
                      width: 48.0,
                      height: 48.0,
                      fit: BoxFit.contain,
                    ),
                  )
                : Icon(
                    icon,
                    color: FlutterFlowTheme.of(context).babyPowder,
                    size: 35.0,
                  ),
          ),
        ),
      ],
    );
  }
}



// import '/flutter_flow/flutter_flow_util.dart';
// export 'speech_to_text_page_model.dart';

// import 'package:flutter/material.dart';
// import '/flutter_flow/flutter_flow_theme.dart';
// import 'package:go_router/go_router.dart';
// import 'speech_to_text_page_model.dart';

// class SpeechToTextPageWidget extends StatefulWidget {
//   const SpeechToTextPageWidget({super.key});

//   @override
//   State<SpeechToTextPageWidget> createState() => _SpeechToTextPageWidgetState();
// }

// class _SpeechToTextPageWidgetState extends State<SpeechToTextPageWidget> {
//   late SpeechToTextPageModel _model;
//   bool _isEnglish = true;
//   bool _isPressed = false;
//   bool _isTranscribing = false;

//   @override
//   void initState() {
//     super.initState();
//     _model = SpeechToTextPageModel();
//     _model.openAudioSession();
//   }

//   @override
//   void dispose() {
//     _model.closeAudioSession();
//     super.dispose();
//   }

//   void toggleLanguage() {
//     setState(() {
//       _isEnglish = !_isEnglish;
//       _model.selectedLanguage = _isEnglish ? 'en-US' : 'ar-SA';
//       _model.transcribedText = '';
//     });
//   }

//   Future<void> handleRecordingPress() async {
//     await _model.startRecording();
//     setState(() {
//       _isPressed = true;
//       _isTranscribing = false;
//     });
//   }

//   Future<void> handleRecordingRelease() async {
//     setState(() {
//       _isPressed = false;
//       _isTranscribing = true;
//     });

//     await _model.stopRecording();
//     await _model.transcribeAudio();

//     setState(() {
//       _isTranscribing = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: FlutterFlowTheme.of(context).mediumSlateBlue,
//         elevation: 0,
//         title: Align(
//           alignment: const AlignmentDirectional(-1.0, 0.0),
//           child: Text(
//             'Speech to Text',
//             textAlign: TextAlign.start,
//             style: FlutterFlowTheme.of(context).headlineMedium.override(
//                   fontFamily: 'Urbanist',
//                   color: FlutterFlowTheme.of(context).babyPowder,
//                   fontSize: 30.0,
//                   fontWeight: FontWeight.w400,
//                 ),
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Column(
//                         children: [
//                           GestureDetector(
//                             onTap: toggleLanguage,
//                             child: AnimatedContainer(
//                               duration: Duration(milliseconds: 300),
//                               width: 80,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(20),
//                                 color: FlutterFlowTheme.of(context).mediumSlateBlue,
//                               ),
//                               child: Stack(
//                                 children: [
//                                   // "A" for English
//                                   Positioned(
//                                     left: 8,
//                                     top: 5,
//                                     child: _isEnglish
//                                         ? Container(
//                                             width: 36,
//                                             height: 30,
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.circular(15),
//                                               color: Colors.white,
//                                             ),
//                                             child: Center(
//                                               child: Text('A',
//                                                 style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: FlutterFlowTheme.of(context).mediumSlateBlue,
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                         : Center(
//                                             child: Text(
//                                               'A',
//                                               style: TextStyle(
//                                                 fontSize: 20,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.white.withOpacity(0.5),
//                                               ),
//                                             ),
//                                           ),
//                                   ),
//                                   // "ع" for Arabic
//                                   Positioned(
//                                     right: 8,
//                                     top: 5,
//                                     child: !_isEnglish
//                                         ? Container(
//                                             width: 36,
//                                             height: 30,
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.circular(15),
//                                               color: Colors.white,
//                                             ),
//                                             child: Center(
//                                               child: Text(
//                                                 'ع',
//                                                 style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: FlutterFlowTheme.of(context).mediumSlateBlue,
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                         : Center(
//                                             child: Text(
//                                               'ع',
//                                               style: TextStyle(
//                                                 fontSize: 20,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.white.withOpacity(0.5),
//                                               ),
//                                             ),
//                                           ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             _isEnglish ? 'Language' : 'اللغة',
//                             style: TextStyle(fontSize: 16, color: Colors.black54),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const Spacer(flex: 2),
//                   Center(
//                     child: Container(
//                       width: 300,
//                       padding: const EdgeInsets.symmetric(vertical: 24.0),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(15.0),
//                         boxShadow: [
//                           BoxShadow(color: Colors.black12.withOpacity(0.2),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: <Widget>[
//                           Container(
//                             width: 80,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: const Color(0xFF7B78DA),
//                               boxShadow: _isPressed
//                                   ? [
//                                       BoxShadow(
//                                         color: Colors.blueAccent.withOpacity(0.6),
//                                         blurRadius: 40.0,
//                                         spreadRadius: 5.0,
//                                       )
//                                     ]
//                                   : [],
//                             ),
//                             child: IconButton(
//                               icon: const Icon(
//                                 Icons.mic,
//                                 size: 36,
//                                 color: Colors.white,
//                               ),
//                               onPressed: () async {
//                                 if (_model.isRecording) {
//                                   await handleRecordingRelease();
//                                 } else {
//                                   await handleRecordingPress();
//                                 }
//                               },
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             _model.isRecording
//                                 ? (_isEnglish ? 'Recording... Tap to stop' : 'جارٍ التسجيل... اضغط للإيقاف')
//                                 : (_isEnglish ? 'Tap to start recording' : 'اضغط لبدء التسجيل'),
//                             style: const TextStyle(fontSize: 16, color: Colors.black54),
//                           ),
//                           const SizedBox(height: 20),
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: _isTranscribing
//                                 ? Center(child: CircularProgressIndicator(color: Colors.blue))
//                                 : Text(
//                                     _model.transcribedText.isNotEmpty
//                                         ? _model.transcribedText
//                                         : (_isEnglish ? 'Transcribed text will appear here...' : 'تحدث معي'),
//                                     style: const TextStyle(fontSize: 16, color: Colors.black),
//                                     textAlign: TextAlign.center,
//                                   ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const Spacer(flex: 3),
//                 ],
//               ),
//             ),
//             Align(
//               alignment: const AlignmentDirectional(0.0, 1.0),
//               child: Container(
//                 width: double.infinity,
//                 height: 80.0,
//                 decoration: BoxDecoration(
//                   color: FlutterFlowTheme.of(context).mediumSlateBlue,
//                   boxShadow: const [
//                     BoxShadow(
//                       blurRadius: 4.0,
//                       color: Color(0x33000000),
//                       offset: Offset(0.0, -2.0),
//                       spreadRadius: 0.0,
//                     )],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.max,
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildNavIcon(context, 'HomePage', 'assets/images/Layer_1.png'),
//                       _buildNavIcon(context, 'ContactsPage', null, Icons.videocam_rounded),
//                       _buildNavIcon(context, 'SpeechToTextPage', null, Icons.mic_rounded),
//                       _buildNavIcon(context, 'ProfilePage', null, Icons.person_rounded),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNavIcon(BuildContext context, String routeName, String? imagePath, [IconData? icon]) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Flexible(
//           child: InkWell(
//             splashColor: Colors.transparent,
//             focusColor: Colors.transparent,
//             hoverColor: Colors.transparent,
//             highlightColor: Colors.transparent,
//             onTap: () async {
//               context.pushNamed(
//                 routeName,
//                 extra: <String, dynamic>{
//                   kTransitionInfoKey: const TransitionInfo(
//                     hasTransition: true,
//                     transitionType: PageTransitionType.fade,
//                   ),
//                 },
//               );
//             },
//             child: imagePath != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(8.0),
//                     child: Image.asset(
//                       imagePath,
//                       width: 48.0,
//                       height: 48.0,
//                       fit: BoxFit.contain,
//                     ),
//                   )
//                 : Icon(
//                     icon,
//                     color: FlutterFlowTheme.of(context).babyPowder,
//                     size: 35.0,
//                   ),
//           ),
//         ),
//       ].divide(const SizedBox(height: 4.0)),
//     );
//   }
// }

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:mubayin/flutter_flow/flutter_flow_util.dart';
// import 'package:mubayin/pages/speech_to_text_page/speech_to_text_page_model.dart';
// import '/flutter_flow/flutter_flow_theme.dart';

// class SpeechToTextPageWidget extends StatefulWidget {
//   const SpeechToTextPageWidget({super.key});

//   @override
//   State<SpeechToTextPageWidget> createState() => _SpeechToTextPageWidgetState();
// }

// class _SpeechToTextPageWidgetState extends State<SpeechToTextPageWidget> {
//   bool _isListening = false;
//   String _transcribedText = '';
//   bool _isEnglish = true;
// late SpeechToTextPageModel _model;
// bool _isTranscribing = false;

//   @override
//   void initState() {
//     super.initState();
//      _model = SpeechToTextPageModel();
//   _model.openAudioSession();
//   }
// void toggleLanguage() {
//   setState(() {
//     _isEnglish = !_isEnglish;
//     _transcribedText = '';
//     _model.selectedLanguage = _isEnglish ? 'en-US' : 'ar-SA'; // <<< ADD THIS LINE
//   });
// }

// Future<void> handleMicPress() async {
//   if (!_isListening) {
//     // Start recording
//     await _model.startRecording();
//     setState(() {
//       _isListening = true;
//       _transcribedText = '';
//       _isTranscribing = false;
//     });
//   } else {
//     // Stop recording
//     await _model.stopRecording();
//     setState(() {
//       _isListening = false;
//       _isTranscribing = true;
//     });

//     // 👉 Important: Delay the transcription until the next event loop
//     Future.microtask(() async {
//       await _model.transcribeAudio();

//       setState(() {
//         _transcribedText = _model.transcribedText;
//         _isTranscribing = false;
//       });

//       // BONUS: Delete temp audio file
//       if (_model.recordedFilePath.isNotEmpty) {
//         try {
//           final file = File(_model.recordedFilePath);
//           if (await file.exists()) {
//             await file.delete();
//             print('Temp audio deleted.');
//           }
//         } catch (e) {
//           print('Failed to delete temp audio: $e');
//         }
//       }
//     });
//   }
// }



//     // BONUS: Delete temp audio file...

// @override
// void dispose() {
//   _model.closeAudioSession();
//   super.dispose();
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: FlutterFlowTheme.of(context).mediumSlateBlue,
//         elevation: 0,
//         title: Align(
//           alignment: const AlignmentDirectional(-1.0, 0.0),
//           child: Text(
//             'Speech to Text',
//             textAlign: TextAlign.start,
//             style: FlutterFlowTheme.of(context).headlineMedium.override(
//                   fontFamily: 'Urbanist',
//                   color: FlutterFlowTheme.of(context).babyPowder,
//                   fontSize: 30.0,
//                   fontWeight: FontWeight.w400,
//                 ),
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Column(
//                         children: [
//                           GestureDetector(
//                             onTap: toggleLanguage,
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 300),
//                               width: 80,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(20),
//                                 color: FlutterFlowTheme.of(context).mediumSlateBlue,
//                               ),
//                               child: Stack(
//                                 children: [
//                                   Positioned(
//                                     left: 8,
//                                     top: 5,
//                                     child: _isEnglish
//                                         ? Container(
//                                             width: 36,
//                                             height: 30,
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.circular(15),
//                                               color: Colors.white,
//                                             ),
//                                             child: Center(
//                                               child: Text(
//                                                 'A',
//                                                 style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: FlutterFlowTheme.of(context).mediumSlateBlue,
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                         : Center(
//                                             child: Text(
//                                               'A',
//                                               style: TextStyle(
//                                                 fontSize: 20,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.white.withOpacity(0.5),
//                                               ),
//                                             ),
//                                           ),
//                                   ),
//                                   Positioned(
//                                     right: 8,
//                                     top: 5,
//                                     child: !_isEnglish
//                                         ? Container(
//                                             width: 36,
//                                             height: 30,
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.circular(15),
//                                               color: Colors.white,
//                                             ),
//                                             child: Center(
//                                               child: Text(
//                                                 'ع',
//                                                 style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: FlutterFlowTheme.of(context).mediumSlateBlue,
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                         : Center(
//                                             child: Text(
//                                               'ع',
//                                               style: TextStyle(
//                                                 fontSize: 20,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.white.withOpacity(0.5),
//                                               ),
//                                             ),
//                                           ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             _isEnglish ? 'Language' : 'اللغة',
//                             style: const TextStyle(fontSize: 16, color: Colors.black54),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const Spacer(flex: 2),
//                   Center(
//                     child: Container(
//                       width: 300,
//                       padding: const EdgeInsets.symmetric(vertical: 24.0),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(15.0),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12.withOpacity(0.2),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: <Widget>[
//                           Container(
//                             width: 80,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: const Color(0xFF7B78DA),
//                               boxShadow: _isListening
//                                   ? [
//                                       BoxShadow(
//                                         color: Colors.blueAccent.withOpacity(0.6),
//                                         blurRadius: 40.0,
//                                         spreadRadius: 5.0,
//                                       )
//                                     ]
//                                   : [],
//                             ),
//                             child: IconButton(
//                               icon: const Icon(
//                                 Icons.mic,
//                                 size: 36,
//                                 color: Colors.white,
//                               ),
//                               onPressed: handleMicPress,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             _isListening
//                                 ? (_isEnglish ? 'Listening... Tap to stop' : 'جارٍ الاستماع... اضغط للإيقاف')
//                                 : (_isEnglish ? 'Tap to start listening' : 'اضغط لبدء الاستماع'),
//                             style: const TextStyle(fontSize: 16, color: Colors.black54),
//                           ),
//                           const SizedBox(height: 20),



//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               _transcribedText.isNotEmpty
//                                   ? _transcribedText
//                                   : (_isEnglish ? 'Transcribed text will appear here...' : 'تحدث معي'),
//                               style: const TextStyle(fontSize: 16, color: Colors.black),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),







//                         ],
//                       ),
//                     ),
//                   ),
//                   const Spacer(flex: 3),
//                 ],
//               ),
//             ),
//             Align(
//               alignment: const AlignmentDirectional(0.0, 1.0),
//               child: Container(
//                 width: double.infinity,
//                 height: 80.0,
//                 decoration: BoxDecoration(
//                   color: FlutterFlowTheme.of(context).mediumSlateBlue,
//                   boxShadow: const [
//                     BoxShadow(
//                       blurRadius: 4.0,
//                       color: Color(0x33000000),
//                       offset: Offset(
//                         0.0,
//                         -2.0,
//                       ),
//                       spreadRadius: 0.0,
//                     )
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildNavButton('HomePage', 'assets/images/Layer_1.png'),
//                       _buildNavButton('ContactsPage', null, icon: Icons.videocam_rounded),
//                       _buildNavButton('SpeechToTextPage', null, icon: Icons.mic_rounded),
//                       _buildNavButton('ProfilePage', null, icon: Icons.person_rounded),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNavButton(String route, String? imagePath, {IconData? icon}) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Flexible(
//           child: InkWell(
//             onTap: () {
//               context.pushNamed(route);
//             },
//             child: imagePath != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(8.0),
//                     child: Image.asset(
//                       imagePath,
//                       width: 48.0,
//                       height: 48.0,
//                       fit: BoxFit.contain,
//                     ),
//                   )
//                 : Icon(
//                     icon,
//                     color: FlutterFlowTheme.of(context).babyPowder,
//                     size: 35.0,
//                   ),
//           ),
//         ),
//       ],
//     );
//   }
// }
