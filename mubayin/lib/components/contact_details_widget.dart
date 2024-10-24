import '/backend/backend.dart';
import '/components/call_widget.dart';
import '/components/contact_details_successfully_changed_widget.dart';
import '/components/delete_contact_widget.dart';
import '/components/empty_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'contact_details_model.dart';
export 'contact_details_model.dart';

class ContactDetailsWidget extends StatefulWidget {
  const ContactDetailsWidget({
    super.key,
    required this.contacts,
  });

  final DocumentReference? contacts;

  @override
  State<ContactDetailsWidget> createState() => _ContactDetailsWidgetState();
}

class _ContactDetailsWidgetState extends State<ContactDetailsWidget> {
  late ContactDetailsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ContactDetailsModel());

    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textFieldFocusNode2 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 1.0),
      child: Container(
        width: double.infinity,
        height: 600.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).babyPowder,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(36.0),
            topRight: Radius.circular(36.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<ContactsRecord>(
            stream: ContactsRecord.getDocument(widget.contacts!),
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

              final listViewContactsRecord = snapshot.data!;

              return ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: FlutterFlowIconButton(
                            borderRadius: 40.0,
                            buttonSize: 55.0,
                            fillColor: FlutterFlowTheme.of(context).babyPowder,
                            hoverColor: FlutterFlowTheme.of(context).whiteSmoke,
                            icon: Icon(
                              Icons.close_rounded,
                              color: FlutterFlowTheme.of(context).eerieBlack,
                              size: 30.0,
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder<List<UsersRecord>>(
                        stream: queryUsersRecord(
                          queryBuilder: (usersRecord) => usersRecord.where(
                            'email',
                            isEqualTo: listViewContactsRecord.contactEmail,
                          ),
                          singleRecord: true,
                        ),
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
                          List<UsersRecord> containerUsersRecordList =
                              snapshot.data!;
                          // Return an empty Container when the item does not exist.
                          if (snapshot.data!.isEmpty) {
                            return Container();
                          }
                          final containerUsersRecord =
                              containerUsersRecordList.isNotEmpty
                                  ? containerUsersRecordList.first
                                  : null;

                          return Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).whiteSmoke,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 200.0,
                              height: 200.0,
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CachedNetworkImage(
                                fadeInDuration: const Duration(milliseconds: 500),
                                fadeOutDuration: const Duration(milliseconds: 500),
                                imageUrl: valueOrDefault<String>(
                                  containerUsersRecord?.photoUrl,
                                  'https://www.carenewengland.org/hubfs/big-bigstock-Default-Avatar-Profile-Icon-Ve-406542344.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _model.textController1 ??=
                                TextEditingController(
                              text: listViewContactsRecord.contactName,
                            ),
                            focusNode: _model.textFieldFocusNode1,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'Manrope',
                                    letterSpacing: 0.0,
                                  ),
                              hintText: 'TextField',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'Manrope',
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Manrope',
                                  color: FlutterFlowTheme.of(context).night,
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                            textAlign: TextAlign.center,
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            validator: _model.textController1Validator
                                .asValidator(context),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          listViewContactsRecord.contactEmail,
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Manrope',
                                    color: FlutterFlowTheme.of(context).night,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Builder(
                          builder: (context) => Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                24.0, 0.0, 24.0, 0.0),
                            child: FlutterFlowIconButton(
                              borderRadius: 30.0,
                              buttonSize: 48.0,
                              fillColor:
                                  FlutterFlowTheme.of(context).mediumSlateBlue,
                              hoverColor:
                                  FlutterFlowTheme.of(context).tropicalIndigo,
                              hoverIconColor:
                                  FlutterFlowTheme.of(context).whiteSmoke,
                              icon: Icon(
                                Icons.videocam_rounded,
                                color: FlutterFlowTheme.of(context).info,
                                size: 30.0,
                              ),
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return Dialog(
                                      elevation: 0,
                                      insetPadding: EdgeInsets.zero,
                                      backgroundColor: Colors.transparent,
                                      alignment: const AlignmentDirectional(0.0, 0.0)
                                          .resolve(Directionality.of(context)),
                                      child: const CallWidget(),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        Builder(
                          builder: (context) => Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                24.0, 0.0, 24.0, 0.0),
                            child: FlutterFlowIconButton(
                              borderColor: Colors.transparent,
                              borderRadius: 30.0,
                              buttonSize: 48.0,
                              fillColor: FlutterFlowTheme.of(context).error,
                              hoverColor: const Color(0xC7E74852),
                              hoverIconColor:
                                  FlutterFlowTheme.of(context).whiteSmoke,
                              icon: Icon(
                                Icons.delete_rounded,
                                color: FlutterFlowTheme.of(context).info,
                                size: 30.0,
                              ),
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return Dialog(
                                      elevation: 0,
                                      insetPadding: EdgeInsets.zero,
                                      backgroundColor: Colors.transparent,
                                      alignment: const AlignmentDirectional(0.0, 0.0)
                                          .resolve(Directionality.of(context)),
                                      child: DeleteContactWidget(
                                        contact: widget.contacts!,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
                    child: Container(
                      width: double.infinity,
                      height: 120.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).whiteSmoke,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Align(
                        alignment: const AlignmentDirectional(-1.0, -1.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _model.textController2 ??=
                                TextEditingController(
                              text: listViewContactsRecord.note,
                            ),
                            focusNode: _model.textFieldFocusNode2,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: 'Note',
                              labelStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Manrope',
                                    color: FlutterFlowTheme.of(context).night,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                              alignLabelWithHint: false,
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'Manrope',
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              filled: true,
                              fillColor:
                                  FlutterFlowTheme.of(context).whiteSmoke,
                              suffixIcon: const Icon(
                                Icons.edit_note,
                              ),
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Manrope',
                                  color: FlutterFlowTheme.of(context).night,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                ),
                            textAlign: TextAlign.start,
                            maxLines: 4,
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            validator: _model.textController2Validator
                                .asValidator(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: Builder(
                      builder: (context) => Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            16.0, 20.0, 16.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: (((_model.textController1.text ==
                                          listViewContactsRecord.contactName) ||
                                      (listViewContactsRecord.contactName ==
                                              '')) &&
                                  (_model.textController2.text ==
                                      listViewContactsRecord.note))
                              ? null
                              : () async {
                                  if (_model.textController1.text != '') {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      enableDrag: false,
                                      useSafeArea: true,
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child:
                                              const ContactDetailsSuccessfullyChangedWidget(),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));

                                    await widget.contacts!
                                        .update(createContactsRecordData(
                                      contactName: _model.textController1.text,
                                      note: _model.textController2.text,
                                    ));
                                  } else {
                                    await showDialog(
                                      context: context,
                                      builder: (dialogContext) {
                                        return Dialog(
                                          elevation: 0,
                                          insetPadding: EdgeInsets.zero,
                                          backgroundColor: Colors.transparent,
                                          alignment: const AlignmentDirectional(
                                                  0.0, 0.0)
                                              .resolve(
                                                  Directionality.of(context)),
                                          child: const EmptyWidget(),
                                        );
                                      },
                                    );
                                  }

                                  context.safePop();
                                },
                          text: 'Save Changes',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 44.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).mediumSlateBlue,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Manrope',
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 3.0,
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                            disabledColor: const Color(0x9D9592E1),
                            hoverColor:
                                FlutterFlowTheme.of(context).tropicalIndigo,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
