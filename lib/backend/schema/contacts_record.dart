import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ContactsRecord extends FirestoreRecord {
  ContactsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "cid" field.
  DocumentReference? _cid;
  DocumentReference? get cid => _cid;
  bool hasCid() => _cid != null;

  // "contact_name" field.
  String? _contactName;
  String get contactName => _contactName ?? '';
  bool hasContactName() => _contactName != null;

  // "note" field.
  String? _note;
  String get note => _note ?? '';
  bool hasNote() => _note != null;

  // "contact_email" field.
  String? _contactEmail;
  String get contactEmail => _contactEmail ?? '';
  bool hasContactEmail() => _contactEmail != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _cid = snapshotData['cid'] as DocumentReference?;
    _contactName = snapshotData['contact_name'] as String?;
    _note = snapshotData['note'] as String?;
    _contactEmail = snapshotData['contact_email'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('contacts')
          : FirebaseFirestore.instance.collectionGroup('contacts');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('contacts').doc(id);

  static Stream<ContactsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ContactsRecord.fromSnapshot(s));

  static Future<ContactsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ContactsRecord.fromSnapshot(s));

  static ContactsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ContactsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ContactsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ContactsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ContactsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ContactsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createContactsRecordData({
  DocumentReference? cid,
  String? contactName,
  String? note,
  String? contactEmail,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'cid': cid,
      'contact_name': contactName,
      'note': note,
      'contact_email': contactEmail,
    }.withoutNulls,
  );

  return firestoreData;
}

class ContactsRecordDocumentEquality implements Equality<ContactsRecord> {
  const ContactsRecordDocumentEquality();

  @override
  bool equals(ContactsRecord? e1, ContactsRecord? e2) {
    return e1?.cid == e2?.cid &&
        e1?.contactName == e2?.contactName &&
        e1?.note == e2?.note &&
        e1?.contactEmail == e2?.contactEmail;
  }

  @override
  int hash(ContactsRecord? e) => const ListEquality()
      .hash([e?.cid, e?.contactName, e?.note, e?.contactEmail]);

  @override
  bool isValidKey(Object? o) => o is ContactsRecord;
}
