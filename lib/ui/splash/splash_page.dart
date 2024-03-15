import 'dart:math';

import 'package:aishshreya/bloc/splash_bloc.dart';
import 'package:aishshreya/data/repository/auth_repository.dart';
import 'package:aishshreya/ui/auth/login_page.dart';
import 'package:aishshreya/ui/home/homepage.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/image_icons.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  static const route = "/";
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  late String token;

  late SplashBloc splashBloc;

  @override
  void initState() {
    splashBloc = SplashBloc(context.read<AuthRepository>());
    super.initState();
    splashBloc.introScreenController.stream.listen((event) {
      switch(event) {
        case 'SUCCESS':
          Navigator.pushNamedAndRemoveUntil(context, HomePage.route, (r) => false);
          break;
        case 'ERROR':
          Navigator.pushNamedAndRemoveUntil(context, LoginPage.route, (r) => false);
          break;
      }
    });
    if(kIsWeb) {
      initApp();
    } else {
      initializeFirebase();
    }

  }

  initializeFirebase() {
    print('initializeFirebase getting called');
    getFirebaseToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (
      // This step (if condition) is only necessary if you pretend to use the
      // test page inside console.firebase.google.com
      !AwesomeStringUtils.isNullOrEmpty(message.notification?.title,
          considerWhiteSpaceAsEmpty: true) ||
          !AwesomeStringUtils.isNullOrEmpty(message.notification?.body,
              considerWhiteSpaceAsEmpty: true)) {
        print('Message also contained a notification: ${message.notification}');

        String? imageUrl;
        imageUrl ??= message.notification!.android?.imageUrl;
        imageUrl ??= message.notification!.apple?.imageUrl;

        // https://pub.dev/packages/awesome_notifications#notification-types-values-and-defaults
        Map<String, dynamic> notificationAdapter = {
          NOTIFICATION_CONTENT: {
            NOTIFICATION_ID: Random().nextInt(2147483647),
            NOTIFICATION_CHANNEL_KEY: 'basic_channel',
            NOTIFICATION_TITLE: message.notification!.title,
            NOTIFICATION_BODY: message.notification!.body,
            NOTIFICATION_LAYOUT:
            AwesomeStringUtils.isNullOrEmpty(imageUrl) ? 'Default' : 'BigPicture',
            NOTIFICATION_BIG_PICTURE: imageUrl,
          }
        };

        AwesomeNotifications().createNotificationFromJsonData(notificationAdapter);
      } else {
        AwesomeNotifications().createNotificationFromJsonData(message.data);
      }
    });
  }

  getFirebaseToken() async {
    // use the returned token to send messages to users from your custom server
    if(kIsWeb) {

      token = "";
      // token = (await messaging.getToken())!;
    } else {
      token = (await messaging.getToken(
        vapidKey: FirebaseVapidKey.key,
      ))!;
    }

    debugPrint('fcmToken $token');

    initApp();
  }

  initApp() {
    final prefs = context.read<SharedPreferences>();
    if(prefs.containsKey('id')) {
      bool? isAdmin = prefs.getBool('isAdmin') ;
      if(isAdmin!=null) {
        String dialCode = prefs.getString('dialCode') ?? '';
        String phone = prefs.getString('phone') ?? '';
        splashBloc.getUserDetails(dialCode, phone);
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushNamedAndRemoveUntil(context, LoginPage.route, (r) => false);
        });
      }
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushNamedAndRemoveUntil(context, LoginPage.route, (r) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Image.asset(AppImages.logoBG, width: 1.sw,),
            ),
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(AppImages.logo, height: 100, width: 100,
                  fit: BoxFit.cover,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
