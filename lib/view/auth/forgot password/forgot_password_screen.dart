import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/view/auth/forgot%20password/otp_screen.dart';
import 'package:http/http.dart' as http;
import '../../../APIs/urls.dart';
import '../../../utilities/app_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool forgotLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 60, left: 30, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Forgot Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
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
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Enter your email",
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
                            return 'Enter Your email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
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
                                forgotPassword();
                              }
                            },
                            child: !forgotLoading
                                ? const Text("Next")
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
        ],
      )),
    );
  }

  Future<void> forgotPassword() async {
    try {
      setLoading(true);
      final response =
          await http.post(Uri.parse("${URLs.baseURL}${URLs.forgotURL}"), body: {
        "email": emailController.text,
      });

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        debugPrint("Done");

        setLoading(false);
        navigateToOtpScreen();
      } else {
        setLoading(false);
        debugPrint("forgotPassword(): error");
      }
    } catch (e) {
      setLoading(false);
      debugPrint("forgotPassword(): ${e.toString()}");
    }
  }

  void navigateToOtpScreen() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(email: emailController.text),
        ));
  }

  void setLoading(bool status) {
    setState(() {
      forgotLoading = status;
    });
  }
}
