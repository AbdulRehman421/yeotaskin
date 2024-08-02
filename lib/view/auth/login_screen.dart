import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yeotaskin/APIs/app_constant.dart';
import 'package:yeotaskin/APIs/urls.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/view/auth/forgot%20password/forgot_password_screen.dart';
import 'package:yeotaskin/view/home_screen.dart';
import 'package:http/http.dart' as http;
import '../../utilities/image_utils.dart';
import '../../utilities/snackbar_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool loginLoading = false;

  void setLoading(bool status) {
    setState(() {
      loginLoading = status;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    userNameController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primaryColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 60, left: 30, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Log in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.palatino,
                    ),
                    textAlign: TextAlign.left),
                Text('Care your skin with us',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: AppFonts.palatino,
                    ),
                    textAlign: TextAlign.left),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50),
                      topLeft: Radius.circular(50))),
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(right: 40, left: 40, bottom: 20),
                          child: Image(image: AssetImage(Images.logo)),
                        ),
                        TextFormField(
                          controller: userNameController,
                          decoration: InputDecoration(
                            hintText: "User Name",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: AppColors.primaryColor.withOpacity(0.1),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.black38,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Your User Name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: "Password",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: AppColors.primaryColor.withOpacity(0.1),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.black38,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Your Password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ));
                              },
                              child: const Text(
                                "Forgot your Password?",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: AppFonts.palatino,
                                ),
                              )),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.optima,
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();
                                  login();
                                }
                              },
                              child: !loginLoading
                                  ? const Text("Log in")
                                  : const CircularProgressIndicator(
                                      color: Colors.white,
                                    )),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> login() async {
    try {
      setLoading(true);
      final response =
          await http.post(Uri.parse("${URLs.baseURL}${URLs.loginURL}"), body: {
        "user_name": userNameController.text,
        "password": passwordController.text,
      });

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        debugPrint("Done");

        saveUser(jsonDecode(response.body)['access_token'].toString());
        setLoading(false);
        navigateToHomeScreen();
      } else {
        SnackBarUtils.show(title: "Something went wrong!", isError: true);
        setLoading(false);
      }
    } catch (e) {
      setLoading(false);
      SnackBarUtils.show(title: e.toString(), isError: true);
      debugPrint(e.toString());
    }
  }

  Future<void> saveUser(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConstant.accessToken, token);
  }

  void navigateToHomeScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ));
  }
}
