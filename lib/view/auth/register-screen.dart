import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yeotaskin/APIs/PdfApi.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/view/auth/login_screen.dart';
import 'package:yeotaskin/view/auth/sign_doc_view_screen.dart';
import 'package:http/http.dart' as http;

import '../../APIs/urls.dart';
import '../../utilities/image_utils.dart';
import '../../utilities/snackbar_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

String documentPath = '';
const List<String> genderList = ["Male", "Female"];

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  TextEditingController levelController = TextEditingController();
  TextEditingController referralController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController icNumberController = TextEditingController();
  bool documentSigned = false;
  bool loadingLevels = false;
  String selectedValue = '';
  List levelList = [];
  void setLoadingLevel(bool status) {
    setState(() {
      loadingLevels = status;
    });
  }

  Future<void> getLevels() async {
    setLoadingLevel(true);
    try {
      final response =
          await http.get(Uri.parse("${URLs.baseURL}${URLs.getLevelURL}"));
      levelList.add({'id': "Select level"});
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        levelList = jsonDecode(response.body)['data'];
        if (kDebugMode) {
          print(levelList);
        }
        // data.map((item) {
        //   if(item['agent_id'].toString() == profile.id.toString()){
        //     orderHistory.add(item);
        //   }
        // }).toList();
        // filterData.map((item){
        //   List products = item['product'];
        //   products.map((product) {
        //     orderHistory.add(ProductModel.fromJsonHistory(product as Map<String, dynamic>));
        //   }).toList();
        // }).toList();

        setState(() {});
      } else {
        debugPrint("getLevels(): error");
      }
    } catch (e) {
      debugPrint("getLevels(): $e");
    }
    setLoadingLevel(false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLevels();
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
                Text('Sign up',
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
                padding: const EdgeInsets.only(bottom: 200),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
                  child: Column(
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(right: 40, left: 40, bottom: 20),
                        child: Image(image: AssetImage(Images.logo)),
                      ),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  hintText: "Name",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Colors.black38,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter Your Name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: userNameController,
                                decoration: InputDecoration(
                                  hintText: "Username",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Colors.black38,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter Your Username';
                                  }
                                  if ((userNameController.text).contains(" ")) {
                                    return 'Enter a valid Username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Colors.black38,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter Your Email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: contactController,
                                decoration: InputDecoration(
                                  hintText: "Contact",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  prefixIcon: const Icon(
                                    Icons.phone,
                                    color: Colors.black38,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter Your Contact';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropdownButtonFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  prefixIcon: const Icon(
                                    Icons.stacked_bar_chart,
                                    color: Colors.black38,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return "Please select gender";
                                  }
                                  return null;
                                },
                                hint: const Text('Select Gender'),
                                items: genderList.map((gender) {
                                  return DropdownMenuItem(
                                      value: gender, child: Text(gender));
                                }).toList(),
                                onChanged: (value) {
                                  genderController.text = value!;
                                  if (kDebugMode) {
                                    print(genderController.text);
                                  }
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
                                  fillColor:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.black38,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter Password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: confirmController,
                                decoration: InputDecoration(
                                  hintText: "Confirm Password",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Colors.black38,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter Your Confirm Password';
                                  }
                                  if (passwordController.text !=
                                      confirmController.text) {
                                    return "Password not matching";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: icNumberController,
                                decoration: InputDecoration(
                                  hintText: "IC Number",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  prefixIcon: const Icon(
                                    Icons.numbers,
                                    color: Colors.black38,
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter Your IC Number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              !loadingLevels && levelList.isNotEmpty
                                  ? DropdownButtonFormField(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide.none),
                                        filled: true,
                                        fillColor: AppColors.primaryColor
                                            .withOpacity(0.1),
                                        prefixIcon: const Icon(
                                          Icons.stacked_bar_chart,
                                          color: Colors.black38,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null) {
                                          return "Please select level";
                                        }
                                        return null;
                                      },
                                      hint: const Text('Select Value'),
                                      items: levelList.reversed.map((level) {
                                        return DropdownMenuItem(
                                            value: level['id'].toString(),
                                            child: Text(
                                                "${level['name']} (${level['title']})"));
                                      }).toList(),
                                      onChanged: (value) {
                                        levelController.text = value!;
                                        if (kDebugMode) {
                                          print(levelController.text);
                                        }
                                      },
                                    )
                                  : const Text(
                                      "Please wait... \n Loading levels...",
                                      textAlign: TextAlign.center,
                                    ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: referralController,
                                decoration: InputDecoration(
                                  hintText: "Referral (Optional)",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none),
                                  filled: true,
                                  fillColor:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      foregroundColor:
                                          AppColors.backgroundColor,
                                      backgroundColor: AppColors.primaryColor),
                                  onPressed: () async {
                                    FocusScopeNode().unfocus();
                                    if (_formKey.currentState!.validate()) {
                                      final file =
                                          await PdfApiIcNumber.generatePDF(
                                              icNumber:
                                                  icNumberController.text);
                                      documentPath = file.path;

                                      navigateToPdfViewScreen(documentPath);
                                    }
                                  },
                                  child: const Text("Sign Document"),
                                ),
                              ),
                            ],
                          )),
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
                                    builder: (context) => const LoginScreen(),
                                  ));
                            },
                            child: const Text(
                              "Already have an account?",
                              textAlign: TextAlign.right,
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
                                if (documentSigned) {
                                  register();
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        surfaceTintColor: Colors.transparent,
                                        title: const Text(
                                          'Please Sign document',
                                          style: TextStyle(
                                            fontFamily: AppFonts.palatino,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                "OK",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: AppFonts.palatino,
                                                ),
                                              ))
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            },
                            child: !registerLoading
                                ? const Text("Register Now")
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
      ),
    );
  }

  Future<void> register() async {
    try {
      setLoading(true);
      final request = http.MultipartRequest(
          'POST', Uri.parse("${URLs.baseURL}${URLs.registerURL}"));
      request.fields['name'] = nameController.text;
      request.fields['user_name'] = userNameController.text;
      request.fields['phone'] = contactController.text;
      request.fields['email'] = emailController.text;
      request.fields['gender'] = genderController.text;
      request.fields['ic_number'] = icNumberController.text;
      request.fields['password'] = passwordController.text;
      request.fields['level'] = levelController.text;
      request.files
          .add(await http.MultipartFile.fromPath('attachment', documentPath));

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 201 &&
          jsonDecode(responseBody)['success'] == true) {
        if (kDebugMode) {
          print('Registered');
        }
        setLoading(false);
        nameController.clear();
        userNameController.clear();
        passwordController.clear();
        confirmController.clear();
        referralController.clear();
        levelController.clear();
        contactController.clear();
        emailController.clear();
        genderController.clear();
        levelController.clear();
        icNumberController.clear();
        genderController.clear();
        navigateLoginScreen();
        SnackBarUtils.show(
            title: "Account Created Successfully", isError: false);
      } else {
        SnackBarUtils.show(title: "Something went wrong!", isError: true);
        if (kDebugMode) {
          print('register error: ${response.statusCode}');
        }
      }
    } catch (e) {
      SnackBarUtils.show(title: e.toString(), isError: true);
      debugPrint(e.toString());
    }
    setLoading(false);
  }

  void navigateLoginScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
  }

  bool registerLoading = false;

  void setLoading(bool status) {
    setState(() {
      registerLoading = status;
    });
  }

  void navigateToPdfViewScreen(String path) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SignedDocViewScreen(
                  icNumber: icNumberController.text,
                  saveSignature: () {
                    setState(() {
                      documentSigned = true;
                    });
                  },
                  url: path,
                )));
  }
}
