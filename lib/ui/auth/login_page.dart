import 'package:aishshreya/bloc/auth_bloc.dart';
import 'package:aishshreya/data/repository/app_repository.dart';
import 'package:aishshreya/data/repository/auth_repository.dart';
import 'package:aishshreya/ui/home/homepage.dart';
import 'package:aishshreya/ui/widget/app_button.dart';
import 'package:aishshreya/ui/widget/app_text_field.dart';
import 'package:aishshreya/utils/image_icons.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'otp_verification_page.dart';

class LoginPage extends StatefulWidget {
  static const route = "/LoginPage";
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  late AuthBloc bloc;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    bloc = AuthBloc(context.read<AuthRepository>(), context.read<AppRepository>());
    super.initState();
    bloc.loginController.stream.listen((event) {
      if(event=='VERIFIED') {
        Navigator.pushNamedAndRemoveUntil(context,
          HomePage.route,
              (Route<dynamic> route) => false,
        );
      }
    });
    bloc.msgController?.stream.listen((event) {
      AppMessageHandler().showSnackBar(context, event);
    });
    bloc.showOTPScreen.addListener(() {
      if (bloc.showOTPScreen.value) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Provider<AuthBloc>.value(
              value: bloc,
              child: const OTPVerificationPage(),
            ),
          ),
        );
      }
    });
    bloc.getFirebaseToken();
    if(!kIsWeb) {
      bloc.requestAllPermission();
    }

  }
  final countryPicker = const FlCountryCodePicker(
    // filteredCountries: ['IN', "US"],
    favorites: ["US", 'IN'],
    favoritesIcon: Icon(PhosphorIcons.push_pin_bold),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                    AppImages.login,
                  height: 0.5.sh,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 80,
                  // left: 0,
                  // right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      AppImages.logo,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     // const Text("Admin Login", style: TextStyle(
                    const Text("Employee Login", style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: bloc.phone,
                      title: 'Mobile Number',
                      showTitle: false,
                      // suffixIcon: const Icon(PhosphorIcons.eye_closed),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validate: true,
                      icon: GestureDetector(
                        onTap: () async {
                          final code = await countryPicker.showPicker(
                            context: context,
                          );
                          if (code != null)  {
                            bloc.updateDialCode(code);
                          }
                        },
                        child: Container(
                          // padding: const EdgeInsets.symmetric(
                          //     horizontal: 8.0, vertical: 4.0),
                          // margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          height: 45,
                          width: 60,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            // color: Colors.blue,
                              borderRadius: BorderRadius.all(Radius.circular(5.0))),
                          child: ValueListenableBuilder(
                              valueListenable: bloc.dialCode,
                              builder: (context, CountryCode dialCode, _) {
                                return Text(dialCode.dialCode,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    // color: Colors.white,
                                  ),
                                );
                              }
                          ),
                        ),
                      ),
                      // icon: SizedBox(height: 45.h, width: 45.h, child: const Center(child: Text('+91', style: TextStyle(fontWeight: FontWeight.w500),),),),
                      validator: (v) => v!.length < 7 || v.length > 15 ? "Please enter valid phone number" : null,
                      // (v) => !Validate.emailValidation.hasMatch(v!) ? 'Please enter valid email' : null,
                    ),
                    const SizedBox(height: 15),
                    ValueListenableBuilder<bool>(
                      valueListenable: bloc.loginLoading,
                      builder: (context, loading, child) {
                        return AppButton(
                          title: 'Login',
                          onTap: () async {
                            if(kIsWeb) {
                              if(formKey.currentState!.validate()) {
                                bloc.checkUserExists();
                              }
                            } else {
                              if (await bloc.checkCallRequirements()) {
                                if(formKey.currentState!.validate()) {
                                  bloc.checkUserExists();
                                }
                              }
                            }
                          },
                          margin: EdgeInsets.zero,
                          loading: loading,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
