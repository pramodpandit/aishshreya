import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:aishshreya/utils/constants.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final Color? textColor;
  final bool hasLeading;
  final List<Widget>? actions;
  final SystemUiOverlayStyle? overlayStyle;
  const CustomAppBar({Key? key, required this.title, this.leading, this.textColor, this.hasLeading=false, this.actions, this.overlayStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      automaticallyImplyLeading: hasLeading,
      title: Text(title, style: TextStyle(
        color: textColor ?? K.textColor,
      ),),
      centerTitle: true,
      elevation: 0,
      iconTheme: IconThemeData(
        color: Colors.black, //change your color here
      ),
      backgroundColor: Colors.white,
      actions: actions,
      systemOverlayStyle: overlayStyle,
    );
  }


  @override
  Size get preferredSize => Size(1.sw,60.h);
}
