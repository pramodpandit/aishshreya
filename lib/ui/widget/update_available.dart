import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/src/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aishshreya/bloc/app_bloc.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/image_icons.dart';

class UpdateAvailableSheet extends StatefulWidget {
  const UpdateAvailableSheet({Key? key}) : super(key: key);

  @override
  _UpdateAvailableSheetState createState() => _UpdateAvailableSheetState();
}

class _UpdateAvailableSheetState extends State<UpdateAvailableSheet> {

  late AppBloc appBloc;

  @override
  void initState() {
    super.initState();
    appBloc = context.read<AppBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text('Newer Version Available!', style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: K.themeColorPrimary,
                  ),),
                  const SizedBox(height: 10),
                  Text('A newer better version of Xtemp Mail Pro is available! ', style: TextStyle(
                    color: Colors.grey[700]!,
                  ),),
                  const SizedBox(height: 20),
                  // SvgPicture.asset(AppImages.updateSVG, height: 200),
                  const SizedBox(height: 20),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      // final url = "${appBloc.updateLink}";
                      // if(await canLaunch(url)) {
                      //   await launch(url);
                      // }
                    },
                    child: Container(
                      width: 1.sw,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: K.themeColorPrimary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: K.boxShadow,
                      ),
                      alignment: Alignment.center,
                      child: const Text('Update!', style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),),
                    ),
                  ),
                  // CupertinoButton(
                  //   onPressed: () => Navigator.pop(context),
                  //   child: Text('Not Now', style: TextStyle(
                  //     fontSize: 12,
                  //     color: Colors.grey,
                  //   ),),
                  // ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
