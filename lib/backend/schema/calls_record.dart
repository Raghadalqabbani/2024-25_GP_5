import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CallsRecord extends FirestoreRecord {
  CallsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "callId" field.
  String? _callId;
  String get callId => _callId ?? '';
  bool hasCallId() => _callId != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "receiverId" field.
  DocumentReference? _receiverId;
  DocumentReference? get receiverId => _receiverId;
  bool hasReceiverId() => _receiverId != null;

  // "callerId" field.
  DocumentReference? _callerId;
  DocumentReference? get callerId => _callerId;
  bool hasCallerId() => _callerId != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "duration" field.
  int? _duration;
  int get duration => _duration ?? 0;
  bool hasDuration() => _duration != null;

  void _initializeFields() {
    _callId = snapshotData['callId'] as String?;
    _status = snapshotData['status'] as String?;
    _receiverId = snapshotData['receiverId'] as DocumentReference?;
    _callerId = snapshotData['callerId'] as DocumentReference?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _duration = castToType<int>(snapshotData['duration']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('calls');

  static Stream<CallsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CallsRecord.fromSnapshot(s));

  static Future<CallsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CallsRecord.fromSnapshot(s));

  static CallsRecord fromSnapshot(DocumentSnapshot snapshot) => CallsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CallsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CallsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CallsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CallsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCallsRecordData({
  String? callId,
  String? status,
  DocumentReference? receiverId,
  DocumentReference? callerId,
  DateTime? createdAt,
  int? duration,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'callId': callId,
      'status': status,
      'receiverId': receiverId,
      'callerId': callerId,
      'createdAt': createdAt,
      'duration': duration,
    }.withoutNulls,
  );

  return firestoreData;
}

class CallsRecordDocumentEquality implements Equality<CallsRecord> {
  const CallsRecordDocumentEquality();

  @override
  bool equals(CallsRecord? e1, CallsRecord? e2) {
    return e1?.callId == e2?.callId &&
        e1?.status == e2?.status &&
        e1?.receiverId == e2?.receiverId &&
        e1?.callerId == e2?.callerId &&
        e1?.createdAt == e2?.createdAt &&
        e1?.duration == e2?.duration;
  }

  @override
  int hash(CallsRecord? e) => const ListEquality().hash([
        e?.callId,
        e?.status,
        e?.receiverId,
        e?.callerId,
        e?.createdAt,
        e?.duration
      ]);

  @override
  bool isValidKey(Object? o) => o is CallsRecord;
}
