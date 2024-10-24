import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'empty_model.dart';
export 'empty_model.dart';

class EmptyWidget extends StatefulWidget {
  const EmptyWidget({super.key});

  @override
  State<EmptyWidget> createState() => _EmptyWidgetState();
}

class _EmptyWidgetState extends State<EmptyWidget> {
  late EmptyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EmptyModel());
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
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: 376.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).babyPowder,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: Icon(
                        Icons.warning_rounded,
                        color: FlutterFlowTheme.of(context).error,
                        size: 50.0,
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                        child: Text(
                          'Empty name',
                          style: FlutterFlowTheme.of(context)
                              .headlineMedium
                              .override(
                                fontFamily: 'Urbanist',
                                color: FlutterFlowTheme.of(context).night,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              await launchUrl(Uri(
                                scheme: 'mailto',
                                path: 'mubayinapp@gmail.com',
                              ));
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Align(
                                  alignment: const AlignmentDirectional(-1.0, 0.0),
                                  child: Text(
                                    'Make sure to enter contact\'s name',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Manrope',
                                          color: FlutterFlowTheme.of(context)
                                              .night,
                                          fontSize: 13.0,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ].divide(const SizedBox(width: 12.0)),
                            ),
                          ),
                        ].divide(const SizedBox(height: 16.0)),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        text: 'OK',
                        options: FFButtonOptions(
                          width: 170.0,
                          height: 50.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).babyPowder,
                          textStyle: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                fontFamily: 'Manrope',
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                              ),
                          elevation: 0.0,
                          borderSide: const BorderSide(
                            color: Color(0x85262626),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                          hoverColor:
                              FlutterFlowTheme.of(context).tropicalIndigo,
                        ),
                      ),
                    ),
                  ].divide(const SizedBox(height: 24.0)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
