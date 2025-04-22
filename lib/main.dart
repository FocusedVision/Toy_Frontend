import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'package:toyvalley/config/get_it.dart';
import 'package:toyvalley/config/colors.dart';
import 'package:toyvalley/config/notification.dart';

import 'package:toyvalley/firebase_options.dart';
import 'package:toyvalley/present/navigation.dart';

import 'package:toyvalley/cubit/main/cubit.dart';
import 'package:toyvalley/cubit/profile/cubit.dart';
import 'package:toyvalley/cubit/toy/cubit.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging
  Logger.root.level =
      Level.ALL; // Or choose appropriate level: INFO, WARNING, etc.
  Logger.root.onRecord.listen((record) {
    if (record.error != null) {
      debugPrint(
        '${record.level.name}: ${record.time}: ${record.message} Error: ${record.error} ${record.stackTrace}',
      );
    } else {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    }
  });

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      Logger('Firebase').info('FCM Token: $token');

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }

    Logger('Firebase').info('Firebase initialized successfully');
    final fcm = FCM();
    await fcm.setNotifications();
  } catch (e, stackTrace) {
    Logger('Firebase').severe('Firebase initialization failed', e, stackTrace);
  }

  await setup();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  MainCubit()
                    ..initialize()
                    ..startPushNotifications()
                    ..sendFirebaseToken(),
        ),
        BlocProvider(create: (context) => ProfileCubit()..initialize()),
        BlocProvider(create: (context) => ToyCubit()),
      ],

      child: MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor:
                  (MediaQuery.of(context).size.height < 720 ||
                          MediaQuery.of(context).size.width < 340)
                      ? 0.8
                      : 1,
            ),
            child: child!,
          );
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'VAG Rounded Std',
          scaffoldBackgroundColor: MyColors.background,
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.resolveWith(
              (states) => Colors.grey.withOpacity(0.5),
            ),
          ),
        ),
        home: const StartNavigation(),
      ),
    );
  }
}
