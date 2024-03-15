import 'dart:async';
import 'dart:convert';

import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/data/model/api_response.dart';
import 'package:aishshreya/data/repository/auth_repository.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:animations/animations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc.dart';

class SplashBloc extends Bloc {

  final AuthRepository _repo;
  SplashBloc(this._repo);
  StreamController<String> introScreenController = StreamController.broadcast();

  /*


  ValueNotifier<List<IntroScreenData>> intros = ValueNotifier([]);

  getIntroPages() async {
    try {
      ApiResponse<List<IntroScreenData>> res = await _repo.getIntroScreens();
      if(res.status) {
        intros.value.addAll(res.data ?? []);
        splashPages.value = [...intros.value.map((e) => IntroPageView(key: UniqueKey(), data: e)).toList()];

        introScreenController.add("success");
      } else {
        introScreenController.add("error");
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      introScreenController.add("error");
    }
  }
*/

  ValueNotifier<List<Widget>> splashPages = ValueNotifier([]);

  Timer? periodicTimer;
  final ValueNotifier<int> currentStep = ValueNotifier(0);
  SharedAxisTransitionType transitionType = SharedAxisTransitionType.scaled;
  ValueNotifier<bool> forwardAnimated = ValueNotifier(false);

  initIntroPage() {
    // periodicTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
    //   updatePage();
    // });
  }

  updatePage(int ni) {
    currentStep.value = ni;
    // if(currentStep.value==splashPages.value.length-1) {
    //   forwardAnimated.value = true;
    //   currentStep.value = 0;
    // } else {
    //   forwardAnimated.value = true;
    //   currentStep.value++;
    // }
  }

  getUserDetails(String dialCode, String phone) async {
    try {
      String fcmToken = await getFirebaseToken();

      ApiResponse<UserDetail> res = await _repo.userLoginWithPhone(dialCode, phone, fcmToken: fcmToken);

      if(res.status) {
        UserDetail? data = res.data;
        if(data!=null) {
          SharedPreferences pref = await SharedPreferences.getInstance();
          pref.setString('token', '${data.userToken}');
          introScreenController.add("SUCCESS");
        } else {
          showMessage(const MessageType.error("User Details Not Found!"));
        }
      } else {
        introScreenController.add("ERROR");
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      introScreenController.add("ERROR");
    }
  }

  Future<String> getFirebaseToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // use the returned token to send messages to users from your custom server
    late String fcmToken;
    if(kIsWeb) {
      fcmToken = "";
      // fcmToken = (await messaging.getToken(
      //   vapidKey: FirebaseVapidKey.key,
      // ))!;
    } else {
      fcmToken = (await messaging.getToken(
        vapidKey: FirebaseVapidKey.key,
      ))!;
    }

    return fcmToken;
  }


}