import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBojYPpbgvdm1PPP1Wmk49NTH1y-wd7-G8",
            authDomain: "mubayin-353c1.firebaseapp.com",
            projectId: "mubayin-353c1",
            storageBucket: "mubayin-353c1.appspot.com",
            messagingSenderId: "389462520301",
            appId: "1:389462520301:web:23842a5a1d3d6a548ef7e4"));
  } else {
    await Firebase.initializeApp();
  }
}
