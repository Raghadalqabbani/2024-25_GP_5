import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:map_launcher/map_launcher.dart' as $ml;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contact_us_model.dart';
export 'contact_us_model.dart';

class ContactUsWidget extends StatefulWidget {
  const ContactUsWidget({super.key});

  @override
  State<ContactUsWidget> createState() => _ContactUsWidgetState();
}

class _ContactUsWidgetState extends State<ContactUsWidget> {
  late ContactUsModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ContactUsModel());
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
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
                      child: Text(
                        'Contact Us',
                        style: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .override(
                              fontFamily: 'Urbanist',
                              color: FlutterFlowTheme.of(context).night,
                              letterSpacing: 0.0,
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
                              await launchMap(
                                mapType: $ml.MapType.google,
                                address: '24°43\'24.4\"N 46°38\'10.0\"E',
                                title: 'Mubayin Location',
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: FlutterFlowTheme.of(context)
                                      .mediumSlateBlue,
                                  size: 30.0,
                                ),
                                Text(
                                  'King Saud University, Riyadh, KSA',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Manrope',
                                        color:
                                            FlutterFlowTheme.of(context).night,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ].divide(const SizedBox(width: 12.0)),
                            ),
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              await launchUrl(Uri(
                                scheme: 'tel',
                                path: '966506383083',
                              ));
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: FlutterFlowTheme.of(context)
                                      .mediumSlateBlue,
                                  size: 30.0,
                                ),
                                Text(
                                  '+966 50 638 3083',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Manrope',
                                        color:
                                            FlutterFlowTheme.of(context).night,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ].divide(const SizedBox(width: 12.0)),
                            ),
                          ),
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
                                Icon(
                                  Icons.email,
                                  color: FlutterFlowTheme.of(context)
                                      .mediumSlateBlue,
                                  size: 30.0,
                                ),
                                Text(
                                  'Mubayinapp@gmail.com',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Manrope',
                                        color:
                                            FlutterFlowTheme.of(context).night,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ].divide(const SizedBox(width: 12.0)),
                            ),
                          ),
                        ].divide(const SizedBox(height: 16.0)),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FlutterFlowIconButton(
                          borderRadius: 25.0,
                          buttonSize: 55.0,
                          fillColor:
                              FlutterFlowTheme.of(context).mediumSlateBlue,
                          hoverColor:
                              FlutterFlowTheme.of(context).mediumSlateBlue,
                          hoverIconColor:
                              FlutterFlowTheme.of(context).tropicalIndigo,
                          icon: FaIcon(
                            FontAwesomeIcons.github,
                            color: FlutterFlowTheme.of(context).info,
                            size: 30.0,
                          ),
                          onPressed: () async {
                            await launchURL(
                                'https://github.com/Raghadalqabbani/2024-25_GP_5.git');
                          },
                        ),
                        FlutterFlowIconButton(
                          borderRadius: 25.0,
                          buttonSize: 55.0,
                          fillColor:
                              FlutterFlowTheme.of(context).mediumSlateBlue,
                          hoverColor:
                              FlutterFlowTheme.of(context).tropicalIndigo,
                          hoverIconColor:
                              FlutterFlowTheme.of(context).whiteSmoke,
                          icon: FaIcon(
                            FontAwesomeIcons.instagram,
                            color: FlutterFlowTheme.of(context).info,
                            size: 30.0,
                          ),
                          onPressed: () async {
                            await launchURL(
                                'https://www.instagram.com/mubayinapp/');
                          },
                        ),
                      ].divide(const SizedBox(width: 16.0)),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        text: 'Close',
                        options: FFButtonOptions(
                          width: 170.0,
                          height: 50.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).mediumSlateBlue,
                          textStyle: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                fontFamily: 'Manrope',
                                color: FlutterFlowTheme.of(context).babyPowder,
                                letterSpacing: 0.0,
                              ),
                          elevation: 0.0,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
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
