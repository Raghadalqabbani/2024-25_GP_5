import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'add_contact_page_widget.dart' show AddContactPageWidget;
import 'package:flutter/material.dart';

class AddContactPageModel extends FlutterFlowModel<AddContactPageWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for contactName widget.
  FocusNode? contactNameFocusNode;
  TextEditingController? contactNameTextController;
  String? Function(BuildContext, String?)? contactNameTextControllerValidator;
  String? _contactNameTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    return null;
  }

  // State field(s) for contactEmail widget.
  FocusNode? contactEmailFocusNode;
  TextEditingController? contactEmailTextController;
  String? Function(BuildContext, String?)? contactEmailTextControllerValidator;
  String? _contactEmailTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Has to be a valid email address.';
    }
    return null;
  }

  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  ContactsRecord? con;

  @override
  void initState(BuildContext context) {
    contactNameTextControllerValidator = _contactNameTextControllerValidator;
    contactEmailTextControllerValidator = _contactEmailTextControllerValidator;
  }

  @override
  void dispose() {
    contactNameFocusNode?.dispose();
    contactNameTextController?.dispose();

    contactEmailFocusNode?.dispose();
    contactEmailTextController?.dispose();
  }
}
