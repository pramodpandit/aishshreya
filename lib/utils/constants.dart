import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class K {
  static const themeColorPrimary = Color(0xff507EFB);
  static const themeColorSecondary = Color(0xffEEF4FF);
  static const themeColorTertiary1 = Color(0xffEEF4FF);
  static const themeColorTertiary2 = Color(0xffD9D9D9);
  static const themeColorTertiary3 = Color(0xffe5f3ff);
  // static const themeColorTertiary2 = Color(0xffFFE66D);
  static const themeColorBg = Color(0xffFFFFFF);


  static const disabledColor = Color(0xff868A9A);
  static const textColor = Color(0xff02012D);//Color(0xff1C2340);
  static const textGrey = Color(0xff8A8D9F);


  static const fontFamily = "Kodchasan";

  static List<BoxShadow> boxShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 30,
    )
  ];

  static const TextStyle textStyle = TextStyle(fontFamily: fontFamily);

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }
}

class Validate {
  static RegExp phoneValidation = RegExp(r"^[0][1-9]\d{9}$|^[1-9]\d{9}$", caseSensitive: false);
  static RegExp emailValidation = RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z-.]{2,}$)", caseSensitive: false);
}

class FirebaseVapidKey {
  static const key = "BICEBCJnmwy0Jw8G_OppZ6pieju59avJuGM8HfKrm-7-0BBIGyuUn1AI_xOMSsQOV-nfjw7ioOv2DoF7qciYEuI";
}

class GoogleMapKey {
  static const String placeKey = "";
  static const String mapKey = "";
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class DateNumberName {
  static const _dateMap = {'1':'st', '2':'nd', '3':'rd', '21':'st', '22':'nd', '23':'rd'};
  static getDateNumberString(String number) {
    return "$number${_dateMap[number] ?? 'th'}";
  }
}