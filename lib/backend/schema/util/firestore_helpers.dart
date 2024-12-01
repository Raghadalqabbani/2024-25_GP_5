import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelpers {
  // Function to retrieve FCM token from the 'users' collection
  static Future<String?> getFcmToken(String userId) async {
    try {
      // Access the 'users' collection in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users') // Replace with your Firestore collection name
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Retrieve the FCM token field (named `fcm_token`) from the user's document
        return userDoc.data()?['fcm_token']; // Adjust field name here
      } else {
        print('User not found for ID: $userId');
        return null;
      }
    } catch (e) {
      print('Error fetching FCM token: $e');
      return null;
    }
  }
}
