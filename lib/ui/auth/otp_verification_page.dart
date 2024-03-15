import 'package:aishshreya/bloc/auth_bloc.dart';
import 'package:aishshreya/ui/home/homepage.dart';
import 'package:aishshreya/ui/widget/app_button.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({Key? key}) : super(key: key);

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {

  late AuthBloc bloc;

  String otp = '';

  void initState() {
    super.initState();
    bloc = context.read<AuthBloc>();
    // bloc.startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Phone"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text("Code is sent to your number"),
              const SizedBox(height: 50),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.w),
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  onChanged: (v) => otp = v,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: K.themeColorPrimary,
                    activeColor: K.themeColorPrimary,
                    selectedFillColor: K.themeColorPrimary.withOpacity(0.2), //Colors.white,
                    selectedColor: K.themeColorPrimary.withOpacity(0.2),
                    inactiveFillColor: K.themeColorPrimary.withOpacity(0.2), //Colors.white,
                    inactiveColor: K.themeColorPrimary.withOpacity(0.2), //Colors.white,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  enableActiveFill: true,
                  controller: TextEditingController(),
                  onCompleted: (v) {
                    // print("Completed");
                  },
                  beforeTextPaste: (text) {
                    // print("Allowing to paste $text");
                    return true;
                  },
                ),
              ),

              // const SizedBox(height: 20),

              StatefulBuilder(
                  key: bloc.builderKey,
                  builder: (context, setBuilderState) {
                    if(bloc.start==0) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Didn\'t receive code.',
                            style: TextStyle(
                              color: K.textColor,
                              fontSize: 16,
                            ),
                          ),
                          IgnorePointer(
                            ignoring: false,
                            child: CupertinoButton(
                              onPressed: () {
                                bloc.userPhoneAuth();
                              },
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: ValueListenableBuilder(
                                valueListenable: bloc.loginLoading,
                                builder: (context, bool loading, _) {
                                  if(loading) {
                                    return const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2,),);
                                  }
                                  return const Text(
                                    'Resend Code',
                                    style: TextStyle(
                                      color: K.themeColorPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      );
                    }
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50.w),
                        child: Text('(${DateFormat('mm:ss').format(DateFormat('s').parse(bloc.start.toString()))})'),
                      ),
                    );
                  }),
              const SizedBox(height: 40),
              ValueListenableBuilder(
                valueListenable: bloc.verifyingOTP,
                builder: (context, bool verifying, _) {
                  return AppButton(
                    title: 'Submit',
                    onTap: () {
                      bloc.otpVerification(otp);
                    },
                    color: K.themeColorPrimary,
                    margin: EdgeInsets.zero,
                    loading: verifying,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
