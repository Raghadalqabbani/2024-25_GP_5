import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  String _cid = '';
  String get cid => _cid;
  set cid(String value) {
    _cid = value;
  }

  String _conID = '';
  String get conID => _conID;
  set conID(String value) {
    _conID = value;
  }
}
