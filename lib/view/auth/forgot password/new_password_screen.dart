import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/view/auth/register-screen.dart';
import 'package:http/http.dart' as http;
import '../../../APIs/urls.dart';
import '../../../utilities/app_fonts.dart';

class NewPasswordScreen extends StatefulWidget {
  final String? email;
  const NewPasswordScreen({super.key,required this.email});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool forgotLoading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
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
                    Text('Enter new Password',
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
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            hintText: "Enter new Password",
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
                              return 'Enter Your new Password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20,),
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
                                  newPasswordUpdate();
                                }

                              },
                              child: !forgotLoading ? const Text("Confirm Changes") : const CircularProgressIndicator(color: Colors.white,)),
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
  Future<void> newPasswordUpdate () async{
    try {
      setLoading(true);
      final response = await http.post(Uri.parse("${URLs.baseURL}${URLs.newPasswordURL}"),body: {
        "email" : widget.email,
        "password" : passwordController.text,
      });

      if(response.statusCode == 200 && jsonDecode(response.body)['success'] == true){
        debugPrint("Done");
        setLoading(false);
        navigateToRegisterScreen();

      }else{
        setLoading(false);
        debugPrint("forgotPassword(): error");
      }
    } catch (e) {
      setLoading(false);
      debugPrint("forgotPassword(): ${e.toString()}");
    }
  }
  void navigateToRegisterScreen()  {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  const RegisterScreen(),));

  }
  void setLoading(bool status){
    setState(() {
      forgotLoading = status;
    });
  }
}
