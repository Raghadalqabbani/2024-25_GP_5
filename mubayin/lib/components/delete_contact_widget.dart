import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'delete_contact_model.dart';
export 'delete_contact_model.dart';

class DeleteContactWidget extends StatefulWidget {
  const DeleteContactWidget({
    super.key,
    required this.contact,
  });

  final DocumentReference? contact;

  @override
  State<DeleteContactWidget> createState() => _DeleteContactWidgetState();
}

class _DeleteContactWidgetState extends State<DeleteContactWidget> {
  late DeleteContactModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeleteContactModel());
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
        child: StreamBuilder<ContactsRecord>(
          stream: ContactsRecord.getDocument(widget.contact!),
          builder: (context, snapshot) {
            // Customize what your widget looks like when it's loading.
            if (!snapshot.hasData) {
              return Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FlutterFlowTheme.of(context).primary,
                    ),
                  ),
                ),
              );
            }

            final containerContactsRecord = snapshot.data!;

            return Container(
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
                    Icon(
                      Icons.warning_rounded,
                      color: FlutterFlowTheme.of(context).error,
                      size: 48.0,
                    ),
                    Text(
                      'Delete Contact',
                      textAlign: TextAlign.center,
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: 'Urbanist',
                                color: FlutterFlowTheme.of(context).night,
                                fontSize: 25.0,
                                letterSpacing: 0.0,
                              ),
                    ),
                    Text(
                      'Are you sure you want to delete this contact? This action cannot be undone.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Manrope',
                            color: FlutterFlowTheme.of(context).eerieBlack,
                            letterSpacing: 0.0,
                          ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FFButtonWidget(
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          text: 'Cancel',
                          options: FFButtonOptions(
                            width: 120.0,
                            height: 40.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).babyPowder,
                            textStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Manrope',
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
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
                            await widget.contact!.delete();
                            await actions.removeContact(
                              currentUserReference!,
                              containerContactsRecord.reference,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Successfully Deleted',
                                  style: TextStyle(
                                    color:
                                        FlutterFlowTheme.of(context).babyPowder,
                                  ),
                                ),
                                duration: const Duration(milliseconds: 4000),
                                backgroundColor:
                                    FlutterFlowTheme.of(context).success,
                              ),
                            );

                            context.pushNamed(
                              'ContactsPage',
                              extra: <String, dynamic>{
                                kTransitionInfoKey: const TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.fade,
                                ),
                              },
                            );
                          },
                          text: 'Delete',
                          options: FFButtonOptions(
                            width: 120.0,
                            height: 40.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).error,
                            textStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Manrope',
                                  color:
                                      FlutterFlowTheme.of(context).babyPowder,
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
            );
          },
        ),
      ),
    );
  }
}
