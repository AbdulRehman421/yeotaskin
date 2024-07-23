import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/view/auth/login_screen.dart';
import 'package:yeotaskin/view/auth/register-screen.dart';

import '../APIs/app_constant.dart';
import '../view/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void navigateToHomeScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ));
  }

  void navigateRegisterScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        ));
  }

  Future<void> check() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Future.delayed(
      const Duration(seconds: 1),
      () {
        if ((prefs.getString(AppConstant.accessToken)) != null) {
          navigateToHomeScreen();
        } else {
          navigateRegisterScreen();
        }
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    check();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Image(
            image: AssetImage("assets/images/logo-transparent.PNG"),
            height: 50),
      ),
    );
  }
}
