import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'danger_option_model.dart';
export 'danger_option_model.dart';

class DangerOptionWidget extends StatefulWidget {
  const DangerOptionWidget({super.key});

  @override
  State<DangerOptionWidget> createState() => _DangerOptionWidgetState();
}

class _DangerOptionWidgetState extends State<DangerOptionWidget> {
  late DangerOptionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DangerOptionModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).babyPowder,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x33000000),
              offset: Offset(
                0.0,
                2.0,
              ),
              spreadRadius: 0.0,
            )
          ],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                      child: Icon(
                        Icons.mic_rounded,
                        color: FlutterFlowTheme.of(context).gamboge,
                        size: 40.0,
                      ),
                    ),
                    Text(
                      'Danger listener',
                      textAlign: TextAlign.center,
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: 'Urbanist',
                                color: FlutterFlowTheme.of(context).night,
                                fontSize: 25.0,
                                letterSpacing: 0.0,
                              ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-1.0, 0.0),
                child: Text(
                  'Enable the Danger Listener feature to detect potentially dangerous sounds. You’ll receive a vibration alert to check your surroundings. \n\nPlease turn on your mic to activate this feature. \n\nnote: You can change this setting anytime in the app settings.',
                  textAlign: TextAlign.start,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Manrope',
                        color: FlutterFlowTheme.of(context).eerieBlack,
                        letterSpacing: 0.0,
                        lineHeight: 1.5,
                      ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FFButtonWidget(
                    onPressed: () async {
                      await currentUserReference!.update(createUsersRecordData(
                        dangerListener: false,
                      ));
                      Navigator.pop(context);
                    },
                    text: 'OFF',
                    options: FFButtonOptions(
                      width: 120.0,
                      height: 40.0,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).babyPowder,
                      textStyle:
                          FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Manrope',
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 16.0,
                                letterSpacing: 0.0,
                              ),
                      elevation: 0.0,
                      borderSide: const BorderSide(
                        color: Color(0x85262626),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                      hoverColor: FlutterFlowTheme.of(context).whiteSmoke,
                    ),
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      await currentUserReference!.update(createUsersRecordData(
                        dangerListener: true,
                      ));
                      Navigator.pop(context);
                    },
                    text: 'ON',
                    options: FFButtonOptions(
                      width: 120.0,
                      height: 40.0,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).mediumSlateBlue,
                      textStyle:
                          FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Manrope',
                                color: FlutterFlowTheme.of(context).babyPowder,
                                fontSize: 16.0,
                                letterSpacing: 0.0,
                              ),
                      elevation: 0.0,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                      hoverColor: const Color(0xADE74852),
                    ),
                  ),
                ].divide(const SizedBox(width: 15.0)),
              ),
            ].divide(const SizedBox(height: 16.0)),
          ),
        ),
      ),
    );
  }
}
