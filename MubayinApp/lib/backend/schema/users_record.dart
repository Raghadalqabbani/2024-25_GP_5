import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/schema/users_record.dart'; // Adjust the path based on your project structure

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "password" field.
  String? _password;
  String get password => _password ?? '';
  bool hasPassword() => _password != null;

  // "username" field.
  String? _username;
  String get username => _username ?? '';
  bool hasUsername() => _username != null;

  // "mic_option" field.
  bool? _micOption;
  bool get micOption => _micOption ?? false;
  bool hasMicOption() => _micOption != null;

  // "contacts_list" field.
  List<DocumentReference>? _contactsList;
  List<DocumentReference> get contactsList => _contactsList ?? const [];
  bool hasContactsList() => _contactsList != null;

  // "history" field.
  List<DocumentReference>? _history;
  List<DocumentReference> get history => _history ?? const [];
  bool hasHistory() => _history != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "danger_listener" field.
  bool? _dangerListener;
  bool get dangerListener => _dangerListener ?? false;
  bool hasDangerListener() => _dangerListener != null;

  // "camera_option" field.
  bool? _cameraOption;
  bool get cameraOption => _cameraOption ?? false;
  bool hasCameraOption() => _cameraOption != null;

  // "signer" field.
  bool? _signer;
  bool get signer => _signer ?? false;
  bool hasSigner() => _signer != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _password = snapshotData['password'] as String?;
    _username = snapshotData['username'] as String?;
    _micOption = snapshotData['mic_option'] as bool?;
    _contactsList = getDataList(snapshotData['contacts_list']);
    _history = getDataList(snapshotData['history']);
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _dangerListener = snapshotData['danger_listener'] as bool?;
    _cameraOption = snapshotData['camera_option'] as bool?;
    _signer = snapshotData['signer'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? password,
  String? username,
  bool? micOption,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? displayName,
  String? photoUrl,
  bool? dangerListener,
  bool? cameraOption,
  bool? signer,
  String? fcmToken, // Add FCM token parameter
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'password': password,
      'username': username,
      'mic_option': micOption,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'display_name': displayName,
      'photo_url': photoUrl,
      'danger_listener': dangerListener,
      'camera_option': cameraOption,
      'signer': signer,
      'fcm_token': fcmToken, // Include FCM token in Firestore data
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.password == e2?.password &&
        e1?.username == e2?.username &&
        e1?.micOption == e2?.micOption &&
        listEquality.equals(e1?.contactsList, e2?.contactsList) &&
        listEquality.equals(e1?.history, e2?.history) &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.dangerListener == e2?.dangerListener &&
        e1?.cameraOption == e2?.cameraOption &&
        e1?.signer == e2?.signer;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.password,
        e?.username,
        e?.micOption,
        e?.contactsList,
        e?.history,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.displayName,
        e?.photoUrl,
        e?.dangerListener,
        e?.cameraOption ,
        e?.signer
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
