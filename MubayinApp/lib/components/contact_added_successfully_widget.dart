import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'contact_added_successfully_model.dart';
export 'contact_added_successfully_model.dart';

class ContactAddedSuccessfullyWidget extends StatefulWidget {
  const ContactAddedSuccessfullyWidget({super.key});

  @override
  State<ContactAddedSuccessfullyWidget> createState() =>
      _ContactAddedSuccessfullyWidgetState();
}

class _ContactAddedSuccessfullyWidgetState
    extends State<ContactAddedSuccessfullyWidget> {
  late ContactAddedSuccessfullyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ContactAddedSuccessfullyModel());
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
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            Navigator.pop(context);
          },
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).babyPowder,
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10.0,
                    color: Color(0x33000000),
                    offset: Offset(
                      0.0,
                      -2.0,
                    ),
                    spreadRadius: 0.0,
                  )
                ],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        color: const Color(0xAD24A891),
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: FlutterFlowTheme.of(context).babyPowder,
                        size: 30.0,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Added Successfully!',
                            style: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Manrope',
                                  color: FlutterFlowTheme.of(context).night,
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          Text(
                            'You can now call this contact directly from your contacts list.',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Manrope',
                                  color: const Color(0xCB262626),
                                  letterSpacing: 0.0,
                                  lineHeight: 1.5,
                                ),
                          ),
                        ].divide(const SizedBox(height: 4.0)),
                      ),
                    ),
                  ].divide(const SizedBox(width: 16.0)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
