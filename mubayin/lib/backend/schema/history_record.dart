import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class HistoryRecord extends FirestoreRecord {
  HistoryRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "call_status" field.
  String? _callStatus;
  String get callStatus => _callStatus ?? '';
  bool hasCallStatus() => _callStatus != null;

  // "caller_id" field.
  DocumentReference? _callerId;
  DocumentReference? get callerId => _callerId;
  bool hasCallerId() => _callerId != null;

  // "date_time" field.
  DateTime? _dateTime;
  DateTime? get dateTime => _dateTime;
  bool hasDateTime() => _dateTime != null;

  // "receiver_id" field.
  DocumentReference? _receiverId;
  DocumentReference? get receiverId => _receiverId;
  bool hasReceiverId() => _receiverId != null;

  // "duration" field.
  String? _duration;
  String get duration => _duration ?? '';
  bool hasDuration() => _duration != null;

  void _initializeFields() {
    _callStatus = snapshotData['call_status'] as String?;
    _callerId = snapshotData['caller_id'] as DocumentReference?;
    _dateTime = snapshotData['date_time'] as DateTime?;
    _receiverId = snapshotData['receiver_id'] as DocumentReference?;
    _duration = snapshotData['duration'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('History');

  static Stream<HistoryRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => HistoryRecord.fromSnapshot(s));

  static Future<HistoryRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => HistoryRecord.fromSnapshot(s));

  static HistoryRecord fromSnapshot(DocumentSnapshot snapshot) =>
      HistoryRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static HistoryRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      HistoryRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'HistoryRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is HistoryRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createHistoryRecordData({
  String? callStatus,
  DocumentReference? callerId,
  DateTime? dateTime,
  DocumentReference? receiverId,
  String? duration,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'call_status': callStatus,
      'caller_id': callerId,
      'date_time': dateTime,
      'receiver_id': receiverId,
      'duration': duration,
    }.withoutNulls,
  );

  return firestoreData;
}

class HistoryRecordDocumentEquality implements Equality<HistoryRecord> {
  const HistoryRecordDocumentEquality();

  @override
  bool equals(HistoryRecord? e1, HistoryRecord? e2) {
    return e1?.callStatus == e2?.callStatus &&
        e1?.callerId == e2?.callerId &&
        e1?.dateTime == e2?.dateTime &&
        e1?.receiverId == e2?.receiverId &&
        e1?.duration == e2?.duration;
  }

  @override
  int hash(HistoryRecord? e) => const ListEquality().hash(
      [e?.callStatus, e?.callerId, e?.dateTime, e?.receiverId, e?.duration]);

  @override
  bool isValidKey(Object? o) => o is HistoryRecord;
}
