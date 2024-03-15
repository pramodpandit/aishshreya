import 'dart:async';
import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:aishshreya/data/model/AuthResponse.dart';
import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/data/model/api_response.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:aishshreya/data/repository/app_repository.dart';
import 'package:aishshreya/data/repository/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class AuthBloc extends Bloc {

  final AuthRepository _repo;
  final AppRepository _appRepo;
  AuthBloc(this._repo, this._appRepo) {
    // getFirebaseToken();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamController<String> loginController = StreamController.broadcast();
  StreamController<String> registerController = StreamController.broadcast();
  //
  ValueNotifier<bool> loginLoading = ValueNotifier(false);
  ValueNotifier<CountryCode> dialCode = ValueNotifier(const CountryCode(name: 'India', code: 'IN', dialCode: '+91'));
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController name = TextEditingController();
  File? image;


  final GlobalKey builderKey = GlobalKey();

  late Timer timer;
  int start = 1 * 60;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (start == 0) {
          builderKey.currentState?.setState(() {
            timer.cancel();
          });
        } else {
          builderKey.currentState?.setState(() {
            start--;
          });
        }
      },
    );
  }

  //#region Region - firebase

  final ValueNotifier<bool> showOTPScreen = ValueNotifier(false);
  final ValueNotifier<bool> otpVerifying = ValueNotifier(false);
  String? _verificationId;
  UserDetail? user;
  UserCredential? firebaseUserCred;

  updateDialCode(CountryCode code) {
    dialCode.value = code;
  }

  Future checkUserExists() async {
    try{
      if(loginLoading.value) {
        return;
      }
      loginLoading.value = true;
      user = null;
      firebaseUserCred = null;
      ApiResponse<UserDetail> res = await _repo.userLoginWithPhone(dialCode.value.dialCode, phone.text, fcmToken: fcmToken);
      if(res.status) {
        user = res.data;
        num? userType = user?.isAdmin;
        if(kIsWeb) {
          if(userType==0) {
            showMessage(const MessageType.error("Employees are not allowed to login on web"));
            loginLoading.value = false;
            return;
          }
        } else {
          /// FOR ADMIN APP: UNCOMMENT BOTH CONDITIONS
          /// FOR ACCOUNTANT APP: UNCOMMENT 1st CONDITIONS
          /// FOR EMP APP: COMMENT 1st CONDITIONS
          // if(userType==0) {
          //   // showMessage(const MessageType.error("Employees are not allowed to login in admin/accountant app"));
          //   showMessage(const MessageType.error("Employees are not allowed to login in admin app."));
          //   loginLoading.value = false;
          //   return;
          // }
          if(userType==2) {
            ///For admin
            //showMessage(const MessageType.error("Accountants are not allowed to login in admin app"));
            ///For employee
            showMessage(const MessageType.error("Employee are not allowed to login in employee app"));
            // showMessage(const MessageType.error("Accountants are not allowed to login in employee app"));
            loginLoading.value = false;
            return;
          }
          // if(userType==2) {
          //   ///For admin
          //   // showMessage(const MessageType.error("Accountants are not allowed to login in admin app"));
          //   showMessage(const MessageType.error("Employees are not allowed to login in admin app."));
          //   ///For employee
          //   //showMessage(const MessageType.error("Accountants are not allowed to login in employee app"));
          //   loginLoading.value = false;
          //   return;
          // }
        }
        userPhoneAuth();
      } else {
        showMessage(MessageType.error(res.message));
        loginLoading.value = false;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      showMessage(MessageType.error("$e"));
      loginLoading.value = false;
    }
  }

  userPhoneAuth() async {
    loginLoading.value = true;
    debugPrint(phone.text);
    await _auth.verifyPhoneNumber(
      phoneNumber: "${dialCode.value.dialCode}${phone.text}",
      timeout: const Duration(seconds: 60),
      codeSent: (String verificationId, int? forceResendingToken) async {
        showOTPScreen.value = true;
        start = 60;
        startTimer();
        _verificationId = verificationId;
        loginLoading.value = false;
      },
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
        UserCredential userData = await _auth.signInWithCredential(phoneAuthCredential);
        //onPhoneAuthSuccess
        firebaseUserCred = userData;
        if(user==null) {
          loginController.sink.add('NEW_USER');
        } else {
          _saveUserDetails(user!);
          loginController.sink.add('VERIFIED');
        }

        //'Phone number automatically verified and user signed in'
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      verificationFailed: (FirebaseAuthException authException) {
        showOTPScreen.value = false;
        if (authException.code == 'invalid-phone-number') {
          showMessage(const MessageType.error('The provided phone number is not valid.'));
        } else {
          debugPrint('exception code ${authException.code}');
          debugPrint('exception ${authException.message}');
          showMessage(MessageType.error(
              'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}'));
        }
      },
    );
  }

  ValueNotifier<bool> verifyingOTP = ValueNotifier(false);
  otpVerification(String otp) {
    //loginLoading.value = true;
    // print(otp);
    if(otp.isEmpty) {
      showMessage(const MessageType.error('Please enter otp first!'));
      return;
    }
    if(verifyingOTP.value) {
      return;
    }
    verifyingOTP.value = true;
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    FirebaseAuth.instance.signInWithCredential(credential).then((user) {
      firebaseUserCred = user;
      if(this.user==null) {
        loginController.sink.add('NEW_USER');
      } else {
        _saveUserDetails(this.user!);
        loginController.sink.add('VERIFIED');
      }
    }).catchError((e) {
      showMessage(const MessageType.error('Wrong OTP! Enter OTP Again!'));
      //loginLoading.value = false;
    });
    verifyingOTP.value = false;
  }

  ValueNotifier<bool> pageLoading = ValueNotifier(false);


//#endregion

  // //#region - UserAuth
  //
  late String fcmToken;
  getFirebaseToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // use the returned token to send messages to users from your custom server
    if(kIsWeb) {
      fcmToken = "";
      // fcmToken = (await messaging.getToken())!;
    } else {
      fcmToken = (await messaging.getToken(
        vapidKey: FirebaseVapidKey.key,
      ))!;
    }

    // fcmToken = "";
    debugPrint('fcmToken $fcmToken');

  }

  //
  // userLoginWithEmail() async {
  //   try{
  //     loginLoading.value = true;
  //     // fcmToken = '';
  //     AuthResponse<UserDetail> response = await _repo.userLoginWithEmail(email.text, password.text, fcmToken: fcmToken);
  //     if(response.status) {
  //       if(response.verified) {
  //         _saveUserDetails(response.data!, password.text);
  //         // showMessage(MessageType.success(response.message));
  //         loginController.sink.add('verified');
  //       } else {
  //         loginController.sink.add('error');
  //         showMessage(MessageType.error(response.message));
  //       }
  //     } else {
  //       showMessage(MessageType.error(response.message));
  //     }
  //   } catch(e,s) {
  //     loginController.sink.add('error');
  //     print(e);
  //     print(s);
  //     showMessage(MessageType.error('$e'));
  //   } finally {
  //     loginLoading.value = false;
  //   }
  // }
  //

  _saveUserDetails(UserDetail userDetails) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setString('id', '${userDetails.id}');
    _pref.setString('name', '${userDetails.name}');
    _pref.setString('dialCode', '${userDetails.dialCode}');
    _pref.setString('phone', '${userDetails.phone}');
    _pref.setString('email', '${userDetails.email}');
    _pref.setBool('isAdmin', userDetails.isAdmin==1);
    _pref.setBool('isAccountant', userDetails.isAdmin==2);
    _pref.setString('image', '${userDetails.image}');
    _pref.setString('token', '${userDetails.userToken}');
  }
  //
  // //#endregion
  //
  //
  // //#region -Forgot Password
  // StreamController<String> forgotPasswordController = StreamController.broadcast();
  //
  // ForgotPasswordVerificationResult? forgotPassDetail;
  // ValueNotifier<bool> forgotLoading = ValueNotifier(false);
  // ValueNotifier<bool> showForgotOTPScreen = ValueNotifier(false);
  //
  //
  // sendForgotPasswordVerifyOTP() async {
  //   try{
  //     if(email.text.isEmpty) {
  //       showMessage(const MessageType.error("Email is required"));
  //       return;
  //     }
  //     forgotLoading.value = true;
  //     ApiResponse<ForgotPasswordVerificationResult?> res = await _repo.sendForgotPasswordVerificationOTP(email.text);
  //     if(res.status) {
  //       forgotPassDetail = res.data;
  //       showForgotOTPScreen.value = true;
  //       showMessage(const MessageType.info('OTP sent to your email successfully.'));
  //       forgotPasswordController.sink.add('forgotOTPSent');
  //     } else {
  //       showMessage(MessageType.error(res.message));
  //     }
  //   } catch(e,s) {
  //     print(e);
  //     print(s);
  //     showMessage(MessageType.error(e.toString()));
  //   } finally {
  //     forgotLoading.value = false;
  //   }
  // }
  //
  // verifyForgotOTP(String otp) {
  //   print('${forgotPassDetail!.otp}');
  //   if(otp=='${forgotPassDetail!.otp}') {
  //     // print('sd');
  //     forgotPasswordController.sink.add('otpVerified');
  //   } else {
  //     showMessage(const MessageType.error('Invalid OTP'));
  //   }
  // }
  //
  // ValueNotifier<bool> changePass = ValueNotifier(false);
  //
  // changeForgotPassword() async {
  //   try{
  //     if(password.text.isEmpty || confirmPass.text.isEmpty) {
  //       showMessage(const MessageType.error("Password is required"));
  //       return;
  //     }
  //     if(password.text!=confirmPass.text) {
  //       showMessage(const MessageType.error("Password does not match"));
  //       return;
  //     }
  //     changePass.value = true;
  //     ApiResponse res = await _repo.changeForgotPassword('${forgotPassDetail!.uid}', password.text);
  //     if(res.status) {
  //       showMessage(const MessageType.success('Password Changed Successfully'));
  //
  //       forgotPasswordController.sink.add('password_changed');
  //     } else {
  //       showMessage(MessageType.error(res.message));
  //     }
  //   } catch(e,s) {
  //     print(e);
  //     print(s);
  //     showMessage(MessageType.error(e.toString()));
  //   } finally {
  //     changePass.value = false;
  //   }
  // }
  //
  // //#endregion

  List<Permission> statuses = [
    //for ios app hide
    Permission.phone,
    Permission.microphone,
    Permission.storage,
    Permission.location,
  ];

  Future<void> requestAllPermission() async {
    try {
      for (var element in statuses) {
        if ((await element.status.isDenied || await element.status.isPermanentlyDenied)) {
          await statuses.request();
          break;
        }
      }
    } catch (e) {
      debugPrint('$e');
    } finally {//commented for 2.0
      checkAndRequestAccessibility();
    }
  }

  Future<bool> checkAllPermission() async {
    bool result = true;
    try {
      for (var element in statuses) {
        if ((await element.status.isDenied || await element.status.isPermanentlyDenied)) {
          print(element.toString());
          if (element.toString() != 'Permission.storage') {
            result = false;
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('$e');
    }
    return result;
  }

  Future<void> checkAndRequestAccessibility() async {
    bool enabled = await checkAccessibility();
    if (!enabled) {
      const platformMethodChannel = MethodChannel('nativeChannel');
      await platformMethodChannel.invokeMethod('startAccessibilityActivity');
    }
  }

  Future<bool> checkAccessibility() async {
    const platformMethodChannel = MethodChannel('nativeChannel');
    final String? result = await platformMethodChannel.invokeMethod('checkAccessibility');

    debugPrint('result: $result');

    return result != null && result == 'enabled';
  }

  Future<bool> checkCallRequirements() async {
    bool permissions = await checkAllPermission();
    //commented for 2.0
    //bool accessibility = await checkAccessibility();
    if (!permissions) {
      showMessage(const MessageType.error('Please provide all permissions!'));
    }

    //commented for 2.0
    // if (!accessibility) {
    //   showMessage(const MessageType.error('Please enable accessibility'));
    // }

    //commented for 2.0
    // return permissions && accessibility;
    return permissions;
  }

}