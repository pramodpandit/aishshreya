import 'package:aishshreya/ui/auth/login_page.dart';
import 'package:aishshreya/ui/home/homepage.dart';
import 'package:aishshreya/ui/splash/splash_page.dart';
import 'package:flutter/material.dart';

class Routes {
  static Map<String, WidgetBuilder> routes = {
    SplashPage.route: (context) => const SplashPage(),
    HomePage.route: (context) => const HomePage(),
    LoginPage.route: (context) => const LoginPage(),
    // AddEventKeyPage.route: (context) => const AddEventKeyPage(),
    // LoginPage.route: (context) => const LoginPage(),
  };
}