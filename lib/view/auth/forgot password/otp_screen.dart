import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/view/auth/forgot%20password/new_password_screen.dart';
import 'package:http/http.dart' as http;
import '../../../APIs/urls.dart';
import '../../../utilities/app_fonts.dart';

class OtpScreen extends StatefulWidget {
  final String? email;
  const OtpScreen({super.key,required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool forgotLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
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
                    Text('OTP verification',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.youngSerifDefault),
                        textAlign: TextAlign.left),
                    Text('Care your skin with us',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: AppFonts.youngSerifDefault),
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
                      key: _formKey, child: Column(
                      children: [
                        Text("An email with OTP has been sent to ${widget.email}",style: TextStyle(fontSize: 16,color: AppColors.primaryColor),),
                        SizedBox(height: 20,),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: otpController,
                          decoration: InputDecoration(
                            hintText: "Enter OTP",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: AppColors.primaryColor.withOpacity(0.1),
                            prefixIcon: const Icon(
                              Icons.password,
                              color: Colors.black38,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Your OTP';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20,),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();
                                  otpVerification();
                                }

                              },
                              child: !forgotLoading ? const Text("Verify") : const CircularProgressIndicator(color: Colors.white,)),
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
  Future<void> otpVerification () async{
    try {
      setLoading(true);
      final response = await http.post(Uri.parse("${URLs.baseURL}${URLs.otpURL}"),body: {
        "email" : widget.email,
        "otp" : otpController.text,
      });

      if(response.statusCode == 200 && jsonDecode(response.body)['success'] == true){
        debugPrint("Done");

        setLoading(false);
        navigateToNewPasswordScreen();

      }else{
        setLoading(false);
        debugPrint("forgotPassword(): error");
      }
    } catch (e) {
      setLoading(false);
      debugPrint("forgotPassword(): ${e.toString()}");
    }
  }
  void navigateToNewPasswordScreen()  {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  NewPasswordScreen(email: widget.email,),));

  }
  void setLoading(bool status){
    setState(() {
      forgotLoading = status;
    });
  }
}
