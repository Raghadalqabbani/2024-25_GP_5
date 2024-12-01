import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';
import 'backend/firebase/firebase_config.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

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
  // This will be triggered when the app is in the background or terminated
  print('Background Message: ${message.messageId}');
  print('Background Message Data: ${message.data}');
}

// Local Notifications Initialization
Future<void> _initializeLocalNotifications() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // Set your app icon

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  late Stream<BaseAuthUser> userStream;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    _requestNotificationPermissions();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = mubayinFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
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
}
      // Display local notification
      _showLocalNotification(message);
            // navigateToVideoCallPage();
    });



    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
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

  // Show Local Notification
Future<void> _showLocalNotification(RemoteMessage message) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'your_channel_id', // Unique channel ID
    'Your Channel Name', // Channel name
    description: 'Your Channel Description', // Channel description
    importance: Importance.max, // High-priority notification
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
  ticker: 'ticker',
  actions: <AndroidNotificationAction>[
    AndroidNotificationAction(
      'accept_action', // Action ID for Accept
      'Accept', // Button text
      showsUserInterface: true, // Show button on notification
      
    ),
    AndroidNotificationAction(
      'reject_action', // Action ID for Reject
      'Reject', // Button text
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

  const rejectCallUrl = 'https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/rejectCall';
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

  const generateTokenUrl = 'https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/generate-and-save-token';
  const acceptCallUrl = 'https://call-backend-2333bc65bd8b.herokuapp.com/api/calls/accept-call';

  try {
    // Step 1: Call the generate-and-save-token API
    final tokenResponse = await http.post(
      Uri.parse(generateTokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'callId': _currentCallId, 'channelName': _currentCallId}),
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
      print("Failed to generate token and channel name: ${tokenResponse.body}");
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