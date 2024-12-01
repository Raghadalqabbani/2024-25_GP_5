import '/flutter_flow/flutter_flow_util.dart';
import 'contacts_page_widget.dart' show ContactsPageWidget;
import 'package:flutter/material.dart';

class ContactsPageModel extends FlutterFlowModel<ContactsPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
