import 'dart:async';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';
import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'services/danger_sound_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
late GoRouter _router;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register the background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await initFirebase();

  await FlutterFlowTheme.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await appState.initializePersistedState();

  // Initialize local notifications
  await _initializeLocalNotifications();

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: const MyApp(),
  ));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
  print('Message data: ${message.data}');

  // Extract data from the message
  final String? callId = message.data['callId'];
  final String? title = message.data['title'] ?? 'Incoming Call';
  final String? body = message.data['body'] ?? 'You have an incoming call.';

  // Trigger a local notification with action buttons
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'your_channel_id',
    'Incoming Call',
    channelDescription: 'Channel for handling incoming calls',
    importance: Importance.max,
    priority: Priority.high,
    sound:
        RawResourceAndroidNotificationSound('apple_iphone_15'), // Custom sound
    playSound: true, // Ensure sound is enabled
    timeoutAfter: 120000, // Notification stays for 2 minutes (120,000 ms)
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction(
        'accept_action',
        '✔️ Accept',
        showsUserInterface: true,
      ),
      AndroidNotificationAction(
        'reject_action',
        '❌ Reject',
        showsUserInterface: true,
      ),
    ],
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique notification ID
    title,
    body,
    notificationDetails,
    payload: callId, // Pass callId as payload
  );
}

// Local Notifications Initialization
Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final String? callId = response.payload;

      if (response.actionId == 'accept_action') {
        print('User clicked Accept');
        await _acceptCall2(callId); // Handle the Accept action
      }
      if (response.actionId == 'reject_action' && callId != null) {
        print("Reject action triggered in the background for callId: $callId");
        await _rejectCallInBackground(callId); // Trigger API
      }
    },
  );

  // Create a notification channel with the custom sound
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'your_channel_id', // Channel ID
    'Incoming Call', // Channel name
    description: 'Channel for handling incoming calls',
    importance: Importance.max,
    sound:
        RawResourceAndroidNotificationSound('apple_iphone_15'), // Custom sound
    playSound: true, // Ensure sound is enabled
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> _acceptCall2(String? callId) async {
  if (callId == null) {
    print("No callId found to accept.");
    return;
  }

  const String generateTokenUrl =
      'https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/generate-and-save-token';
  const String acceptCallUrl =
      'https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/accept-call';

  try {
    // Step 1: Generate token and channelName
    final tokenResponse = await http.post(
      Uri.parse(generateTokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'callId': callId, 'channelName': callId}),
    );

    if (tokenResponse.statusCode == 200) {
      final tokenData = jsonDecode(tokenResponse.body);
      final String token = tokenData['token'];
      final String channelName = tokenData['channelName'];

      print(
          "Token and channel name generated successfully: $token, $channelName");

      // Step 2: Call accept API
      final acceptResponse = await http.post(
        Uri.parse(acceptCallUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'callId': callId}),
      );

      if (acceptResponse.statusCode == 200) {
        print("Call accepted successfully: ${acceptResponse.body}");

        _router.go(
          '/videoCallPage',
          extra: {
            'token': token,
            'channelName': channelName,
            'uid': 1,
            //   'cameraInitiallyOff': true, // 👈 or false
            // 'micInitiallyMuted': true,
          },
        );
        // Step 3: Store navigation data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('videoCallToken', token);
        await prefs.setString('videoCallChannel', channelName);

        print("Navigation data stored successfully.");
      } else {
        print("Failed to accept call: ${acceptResponse.body}");
      }
    } else {
      print("Failed to generate token and channel name: ${tokenResponse.body}");
    }
  } catch (e) {
    print("Error during call acceptance: $e");
  }
}

Future<void> _rejectCallInBackground(String? callId) async {
  const String rejectCallUrl =
      'https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/rejectCall';

  try {
    final response = await http.post(
      Uri.parse(rejectCallUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'callId': callId}),
    );

    if (response.statusCode == 200) {
      print("Call rejected successfully in the background: ${response.body}");
    } else {
      print("Failed to reject call in the background: ${response.body}");
    }
  } catch (e) {
    print("Error rejecting call in the background: $e");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  String? _currentCallId; // Store the callId from the FCM message
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;
  late DangerSoundService dangerSoundService;
Timer? _dangerListenerTimer; // Timer to periodically check danger listener
  late AppStateNotifier _appStateNotifier;
bool _isMonitoring = false;

  late Stream<BaseAuthUser> userStream;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();
dangerSoundService = DangerSoundService(
  flaskUrl: 'https://uploadsounds.onrender.com/upload_audio', // Use your backend IP
);
print("✅ DangerSoundService initialized");

// dangerSoundService.startMonitoring();

    _requestNotificationPermissions();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);

    userStream = mubayinFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);

        if (user != null && user.uid != null) {
          print('✅ User logged in: ${user.uid}');
                _startDangerListenerTimer(user.uid!); // Start repeating check
          // _checkAndStartDangerListener(user.uid!); // ADD the `!` here
        }
      });


    jwtTokenStream.listen((_) {});
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );

    // Listen for FCM foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Print message to terminal
      print('Foreground Message: ${message.notification?.title}');
      print('Message Data: ${message.data}');

      if (message.data.containsKey('callId')) {
        _currentCallId = message.data['callId'];
        print("Call ID saved: $_currentCallId");
        _showLocalNotification(message);
      }
      if (message.data['navigate'] == 'danger') {
        print("🧭 Navigating to /danger WITHOUT showing notification");
        _router.go('/danger');
        // Do NOT show any notification for this message!
      }
      // Display local notification
      // navigateToVideoCallPage();
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null && message.data.containsKey('callId')) {
        print('App launched from terminated state via notification.');
        _handleIncomingCallNotification(message.data);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.containsKey('callId')) {
        print('App resumed from background via notification.');
        _handleIncomingCallNotification(message.data);
      }
    });

    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        print("✅ sucess to get FCM token and send it to danger");

        DangerSoundService.setFcmToken(token); // ✅ Store for later use
      } else {
        print("⚠️ Failed to get FCM token");
      }
    });
  }
  void _startDangerListenerTimer(String callerId) {
  _dangerListenerTimer?.cancel(); // Cancel any old timer

  _dangerListenerTimer = Timer.periodic(
    const Duration(seconds: 10), // ⏲️ Check every 10 seconds (adjust as needed)
    (Timer timer) async {
      await _checkAndStartDangerListener(callerId);
    },
  );

  print('🔁 Danger listener timer started.');
}


  // Request Notification Permissions
  void _requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  // Future<void> _checkAndStartDangerListener(String callerId) async {
  //   const String settingsUrl =
  //       "http://192.168.8.136:4000/api/calls/get-caller-settings";

  //   try {
  //     final response = await http.post(
  //       Uri.parse(settingsUrl),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'callerId': callerId}),
  //     );
  //     print(response.body);
  //     if (response.statusCode == 200) {
  //       final settingsData = jsonDecode(response.body);

  //       final bool dangerListener = settingsData['dangerListener'] ?? false;

  //       if (dangerListener) {
  //         print('🛡️ Danger listener activated for this user!');
  //         dangerSoundService.startMonitoring();
  //       } else {
  //         print('🚫 Danger listener not activated for this user.');
  //       }
  //     } else {
  //       print('⚠️ Failed to fetch caller settings: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('❌ Error fetching caller settings: $e');
  //   }
  // }

  Future<void> _checkAndStartDangerListener(String callerId) async {
  const String settingsUrl = "https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/get-caller-settings";

  try {
    final response = await http.post(
      Uri.parse(settingsUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'callerId': callerId}),
    );
    print(response.body);

    if (response.statusCode == 200) {
      final settingsData = jsonDecode(response.body);

      final bool dangerListener = settingsData['dangerListener'] ?? false;

      if (dangerListener) {
        print('🛡️ Danger listener activated for this user!');
        if (!_isMonitoring) {
          await dangerSoundService.startMonitoring();
          _isMonitoring = true;
          print('🎧 DangerSoundService started.');
        }
      } else {
        print('🚫 Danger listener deactivated for this user.');
        if (_isMonitoring) {
          await dangerSoundService.stopMonitoring();
          _isMonitoring = false;
          print('🛑 DangerSoundService stopped.');
        }
      }
    } else {
      print('⚠️ Failed to fetch caller settings: ${response.body}');
    }
  } catch (e) {
    print('❌ Error fetching caller settings: $e');
  }
}


  // Show Local Notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id', // Unique channel ID
      'Your Channel Name', // Channel name
      description: 'Your Channel Description', // Channel description
      importance: Importance.max, // High-priority notification
      sound: RawResourceAndroidNotificationSound(
          'apple_iphone_15'), // Custom sound
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your_channel_id', // Match channel ID
      'Your Channel Name',
      channelDescription: 'Your Channel Description',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(
          'apple_iphone_15'), // Custom sound
      playSound: true, // Ensure sound is enabled
      timeoutAfter: 120000, // Notification stays for 2 minutes (120,000 ms)
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'accept_action', // Action ID for Accept
          '✔️ Accept', // Button text
          showsUserInterface: true, // Show button on notification
        ),
        AndroidNotificationAction(
          'reject_action', // Action ID for Reject
          '❌ Reject', // Button text

          showsUserInterface: true,
        ),
      ],
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique notification ID
      "Hi, ${message.notification?.title ?? 'No Title'}",
      message.notification?.body ?? 'No Body',
      notificationDetails,
      payload: 'data_payload', // You can use this payload to pass data
    );

    // Handle button actions
    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.actionId == 'accept_action') {
          print('User clicked Accept');
          _acceptCall(); // Call the API to accept the call
        } else if (response.actionId == 'reject_action') {
          print('User clicked Reject');
          _rejectCall(); // Call the API to reject the call
          // Optional: Handle reject action if needed

          
        }
      },
    );
  }

  Future<void> _rejectCall() async {
    if (_currentCallId == null) {
      print("No callId found to reject.");
      return;
    }

    const rejectCallUrl =
        'https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/rejectCall';
    try {
      final response = await http.post(
        Uri.parse(rejectCallUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'callId': _currentCallId}),
      );

      if (response.statusCode == 200) {
        print("Call rejected successfully: ${response.body}");
        // Optionally navigate or show a message after rejecting the call
      } else {
        print("Failed to reject call: ${response.body}");
      }
    } catch (e) {
      print("Error rejecting call: $e");
    }
  }

  Future<void> _acceptCall() async {
    if (_currentCallId == null) {
      print("No callId found to accept.");
      return;
    }

    const generateTokenUrl =
        'https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/generate-and-save-token';
    const acceptCallUrl =
        'https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/accept-call';

    try {
      // Step 1: Call the generate-and-save-token API
      final tokenResponse = await http.post(
        Uri.parse(generateTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'callId': _currentCallId, 'channelName': _currentCallId}),
      );

      if (tokenResponse.statusCode == 200) {
        final tokenData = jsonDecode(tokenResponse.body);
        final token = tokenData['token'];
        final channelName = tokenData['channelName'];

        print("Token and channel name generated successfully:");
        print("Token: $token");
        print("Channel Name: $channelName");

        // Step 2: Call the accept-call API
        final acceptResponse = await http.post(
          Uri.parse(acceptCallUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'callId': _currentCallId}),
        );

        if (acceptResponse.statusCode == 200) {
          print("Call accepted successfully: ${acceptResponse.body}");

          // Step 3: Navigate to the video call page, passing the token and channelName
          navigateToVideoCallPage(token, channelName);
        } else {
          print("Failed to accept call: ${acceptResponse.body}");
        }
      } else {
        print(
            "Failed to generate token and channel name: ${tokenResponse.body}");
      }
    } catch (e) {
      print("Error during call acceptance: $e");
    }
  }

  void navigateToVideoCallPage(String token, String channelName) {
    _router.go(
      '/videoCallPage',
      extra: {
        'token': token,
        'channelName': channelName,
        'userId': currentUserUid, // 👈 this is your logged-in user ID
      },
    );
  }

  void _handleIncomingCallNotification(Map<String, dynamic> data) {
    final callId = data['callId'];
    final channelName = data['channelName'];
    final callerName = data['callerName'];

    print("Incoming call from $callerName, Channel: $channelName");

    // Navigate directly to the video call page
    navigateToVideoCallPage(channelName, callId);
  }

  @override
  void dispose() {
    authUserSub.cancel();
      _dangerListenerTimer?.cancel(); // ⛔ stop the timer
    super.dispose();
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mubayin',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
