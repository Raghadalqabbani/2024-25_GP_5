import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'video_call_page_model.dart';
export 'video_call_page_model.dart';

class VideoCallPageWidget extends StatefulWidget {
  const VideoCallPageWidget({super.key});

  @override
  State<VideoCallPageWidget> createState() => _VideoCallPageWidgetState();
}

class _VideoCallPageWidgetState extends State<VideoCallPageWidget> {
  late VideoCallPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VideoCallPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).babyPowder,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).mediumSlateBlue,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 40.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.arrow_back,
              color: FlutterFlowTheme.of(context).babyPowder,
              size: 40.0,
            ),
            onPressed: () async {
              context.safePop();
            },
          ),
          title: Align(
            alignment: const AlignmentDirectional(-1.0, 0.0),
            child: Text(
              'Video Call',
              textAlign: TextAlign.start,
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Urbanist',
                    color: FlutterFlowTheme.of(context).babyPowder,
                    fontSize: 30.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: Align(
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
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(
                              'HomePage',
                              extra: <String, dynamic>{
                                kTransitionInfoKey: const TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.fade,
                                ),
                              },
                            );
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
                    ].divide(const SizedBox(height: 4.0)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(
                              'ContactsPage',
                              extra: <String, dynamic>{
                                kTransitionInfoKey: const TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.fade,
                                  duration: Duration(milliseconds: 0),
                                ),
                              },
                            );
                          },
                          child: Icon(
                            Icons.videocam_rounded,
                            color: FlutterFlowTheme.of(context).babyPowder,
                            size: 35.0,
                          ),
                        ),
                      ),
                    ].divide(const SizedBox(height: 4.0)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(
                              'SpeechToTextPage',
                              extra: <String, dynamic>{
                                kTransitionInfoKey: const TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.fade,
                                  duration: Duration(milliseconds: 0),
                                ),
                              },
                            );
                          },
                          child: Icon(
                            Icons.mic_rounded,
                            color: FlutterFlowTheme.of(context).babyPowder,
                            size: 35.0,
                          ),
                        ),
                      ),
                    ].divide(const SizedBox(height: 4.0)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(
                              'ProfilePage',
                              extra: <String, dynamic>{
                                kTransitionInfoKey: const TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.fade,
                                  duration: Duration(milliseconds: 0),
                                ),
                              },
                            );
                          },
                          child: Icon(
                            Icons.person_rounded,
                            color: FlutterFlowTheme.of(context).babyPowder,
                            size: 35.0,
                          ),
                        ),
                      ),
                    ].divide(const SizedBox(height: 4.0)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
