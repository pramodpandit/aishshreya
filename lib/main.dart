import 'dart:math';
// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:aishshreya/bloc/notification_controller.dart';
import 'package:aishshreya/data/repository/app_repository.dart';
import 'package:aishshreya/data/repository/employee_repository.dart';
import 'package:aishshreya/data/repository/lead_repository.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/ui/home/homepage.dart';
import 'package:aishshreya/ui/splash/splash_page.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/model/UserReminder.dart';
import 'data/network/api_service.dart';
import 'package:animations/animations.dart';
import 'data/network/hive_service.dart';
import 'data/network/interceptors.dart';
import 'data/repository/auth_repository.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'utils/constants.dart';
import 'utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) {
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCed2QV6Gvt-1CS8g2ZkQpoBzjG0c7ondg',
        appId: '1:184903141811:web:0611f7ea9ee86a2e9e23c6',
        messagingSenderId: '184903141811',
        projectId: 'aishshreya-469c5',
        storageBucket: 'aishshreya-469c5.appspot.com',
        measurementId: 'G-RNGXB821ZK',
        authDomain: 'aishshreya-469c5.firebaseapp.com',
      ),
    );
  } else {
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // await FlutterDownloader.initialize(debug: true);
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // await Hive.initFlutter();
  // Hive.registerAdapter(UserReminderAdapter());

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  AwesomeNotifications().initialize(
    // 'resource://drawable/logo',
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: K.themeColorPrimary,
          ledColor: Colors.blue,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'scheduled',
          channelName: 'Alarms',
          channelDescription: 'Scheduled Notification Channel',
          defaultColor: K.themeColorPrimary,
          ledColor: K.themeColorPrimary,
          channelShowBadge: true,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
          onlyAlertOnce: true,
        ),
      ]
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final sharedPreferences = await SharedPreferences.getInstance();
  // FirebaseMessaging.instance.getToken().then((value) {
  //   if (value != null) {
  //     sharedPreferences.setString('device_token', value);
  //   }
  // });
  Dio dio = Dio();
  dio.interceptors.add(AppInterceptors());
  dio.interceptors.add(DioCacheManager(CacheConfig(
    baseUrl: ApiService.host,
    defaultMaxAge: const Duration(minutes: 30),
    defaultMaxStale: const Duration(days: 2),

  )).interceptor);
  final ApiService apiService = ApiService(dio);
  runApp(MyApp(sharedPreferences, apiService));
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  const MyApp(this.prefs, this.apiService, {Key? key}) : super(key: key);

  final SharedPreferences prefs;
  final ApiService apiService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: AuthRepository(widget.prefs, widget.apiService)),
        Provider<AppRepository>.value(value: AppRepository(widget.prefs, widget.apiService)),
        Provider<EmployeeRepository>.value(value: EmployeeRepository(widget.prefs, widget.apiService)),
        Provider<ServiceRepository>.value(value: ServiceRepository(widget.prefs, widget.apiService)),
        Provider<LeadsRepository>.value(value: LeadsRepository(widget.prefs, widget.apiService)),
        Provider<SharedPreferences>.value(value: widget.prefs),
        // Provider<HiveService>.value(value: HiveService()),
        // ChangeNotifierProvider<ThemeBloc>(
        //   create: (_) => ThemeBloc(AppRepository(prefs, apiService)),
        // ),
      ],
      child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) {
            return Portal(
              child: MaterialApp(
                navigatorKey: MyApp.navigatorKey,
                title: 'Aishshreya',
                debugShowCheckedModeBanner: false,
                builder: (context, widget) {
                  //add this line
                  // ScreenUtil.setContext(context);
                  return MediaQuery(
                    //Setting font does not change with system font size
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: widget!,
                  );
                },
                theme: ThemeData(
                  primarySwatch: Colors.indigo,
                  scaffoldBackgroundColor: K.themeColorBg,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: K.themeColorBg,
                    systemOverlayStyle: SystemUiOverlayStyle.dark,
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: K.fontFamily,
                      color: K.themeColorPrimary
                    ),
                    iconTheme: IconThemeData(
                      color: K.themeColorPrimary,
                      size: 22
                    ),
                    centerTitle: true,
                  ),
                  useMaterial3: true,
                  bottomSheetTheme: const BottomSheetThemeData(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  ),
                  pageTransitionsTheme: const PageTransitionsTheme(builders: {
                    TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder()
                  }),
                  fontFamily: K.fontFamily,
                ),
                initialRoute: SplashPage.route,
                routes: Routes.routes,
                // onGenerateRoute: (routeSettings) {
                //   print('routeSettings $routeSettings');
                // switch(routeSettings.name) {
                //   case CreateOrderPage.route:
                //     return MaterialPageRoute(
                //       builder: (context) => const CreateOrderPage(),
                //       settings: routeSettings,
                //     );
                // }
                // },
              ),
            );
          }
      ),
    );
  }
}

// Declared as global, outside of any class
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");

  if (!AwesomeStringUtils.isNullOrEmpty(message.notification?.title, considerWhiteSpaceAsEmpty: true) ||
      !AwesomeStringUtils.isNullOrEmpty(message.notification?.body, considerWhiteSpaceAsEmpty: true)) {
    print('message also contained a notification: ${message.notification}');

    String? imageUrl;
    imageUrl ??= message.notification!.android?.imageUrl;
    imageUrl ??= message.notification!.apple?.imageUrl;

    Map<String, dynamic> notificationAdapter = {
      NOTIFICATION_CHANNEL_KEY: 'basic_channel',
      NOTIFICATION_ID: message.data[NOTIFICATION_CONTENT]?[NOTIFICATION_ID] ??
          message.messageId ??
          Random().nextInt(2147483647),
      NOTIFICATION_TITLE:
      message.data[NOTIFICATION_CONTENT]?[NOTIFICATION_TITLE] ?? message.notification?.title,
      NOTIFICATION_BODY: message.data[NOTIFICATION_CONTENT]?[NOTIFICATION_BODY] ?? message.notification?.body,
      NOTIFICATION_LAYOUT: AwesomeStringUtils.isNullOrEmpty(imageUrl) ? 'Default' : 'BigPicture',
      NOTIFICATION_BIG_PICTURE: imageUrl
    };

    AwesomeNotifications().createNotificationFromJsonData(notificationAdapter);
  } else {
    AwesomeNotifications().createNotificationFromJsonData(message.data);
  }
}
