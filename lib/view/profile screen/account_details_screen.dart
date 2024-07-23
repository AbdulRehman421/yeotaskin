import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';

import '../../APIs/urls.dart';
import '../../services/user_profile_manager.dart';
import '../../utilities/app_colors.dart';
import 'package:http/http.dart' as http;

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  bool loadingBankAccountDetails = false;
  Map<String, dynamic> bankAccountDetails = {};
  bool saveBankAccountDetailsLoading = false;
  void setLoading(bool status) {
    setState(() {
      loadingBankAccountDetails = status;
    });
  }

  Future<void> getBankAccountDetails() async {
    setLoading(true);
    String? token = await UserProfileManager().getUserToken();

    try {
      final response = await http.get(
          Uri.parse("${URLs.baseURL}${URLs.getBankAccountDetailsURL}"),
          headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        if (jsonDecode(response.body)['data'] != null) {
          bankAccountDetails = jsonDecode(response.body)['data'];
        }
        debugPrint("Account details fetched");
        setState(() {});
      } else {
        debugPrint("getBankAccountDetails: error");
      }
    } catch (e) {
      debugPrint("getBankAccountDetails: $e");
    }
    setLoading(false);
  }

  Future<void> storeBankAccountDetails() async {
    setState(() {
      saveBankAccountDetailsLoading = true;
    });
    String? token = await UserProfileManager().getUserToken();
    try {
      final response = await http.post(
          Uri.parse("${URLs.baseURL}${URLs.storeBankAccountDetailsURL}"),
          headers: {
            "Authorization": "Bearer $token"
          },
          body: {
            "bank_name": bankNameController.text,
            "accont_holder_name": accountHolderNameController.text,
            "accont_no": accountNoController.text,
          });
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        debugPrint("Account details Saved");
      } else {
        debugPrint("storeBankAccountDetails(): error");
      }
    } catch (e) {
      debugPrint("storeBankAccountDetails(): $e");
    }
    setState(() {
      saveBankAccountDetailsLoading = false;
    });
    getBankAccountDetails();
  }

  TextEditingController bankNameController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();
  TextEditingController accountNoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBankAccountDetails();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 1,
        surfaceTintColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          "Account Details",
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: !loadingBankAccountDetails
          ? bankAccountDetails.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: mq.height * 0.02,
                      ),
                      rowProfile("Account Holder Name",
                          bankAccountDetails['accont_holder_name']),
                      SizedBox(
                        height: mq.height * 0.03,
                      ),
                      const Divider(color: Colors.black12),
                      SizedBox(
                        height: mq.height * 0.02,
                      ),
                      rowProfile("Bank Name", bankAccountDetails['bank_name']),
                      SizedBox(
                        height: mq.height * 0.03,
                      ),
                      const Divider(color: Colors.black12),
                      SizedBox(
                        height: mq.height * 0.02,
                      ),
                      rowProfile(
                        "Account Number",
                        bankAccountDetails['accont_no'],
                      ),
                      SizedBox(
                        height: mq.height * 0.03,
                      ),
                      const Divider(color: Colors.black12),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                surfaceTintColor: Colors.transparent,
                                title: Text(
                                  'Update Account Details',
                                  style: TextStyle(
                                    fontFamily: AppFonts.palatino,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              controller:
                                                  accountHolderNameController,
                                              decoration: InputDecoration(
                                                hintText: "Account holder name",
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide:
                                                        BorderSide.none),
                                                filled: true,
                                                fillColor: AppColors
                                                    .primaryColor
                                                    .withOpacity(0.1),
                                                prefixIcon: const Icon(
                                                  Icons.person,
                                                  color: Colors.black38,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Enter Your Account Name';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TextFormField(
                                              controller: bankNameController,
                                              decoration: InputDecoration(
                                                hintText: "Bank Name",
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide:
                                                        BorderSide.none),
                                                filled: true,
                                                fillColor: AppColors
                                                    .primaryColor
                                                    .withOpacity(0.1),
                                                prefixIcon: const Icon(
                                                  Icons.account_balance,
                                                  color: Colors.black38,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Enter Your Bank Name';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TextFormField(
                                              controller: accountNoController,
                                              decoration: InputDecoration(
                                                hintText: "Account Number",
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide:
                                                        BorderSide.none),
                                                filled: true,
                                                fillColor: AppColors
                                                    .primaryColor
                                                    .withOpacity(0.1),
                                                prefixIcon: const Icon(
                                                  Icons.numbers,
                                                  color: Colors.black38,
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Enter Your Account Number';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 60,
                                              child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              AppColors
                                                                  .primaryColor,
                                                          foregroundColor:
                                                              Colors.white),
                                                  onPressed: () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      storeBankAccountDetails()
                                                          .then((value) {
                                                        Navigator.of(context)
                                                            .pop();
                                                      });
                                                    }
                                                  },
                                                  child: !saveBankAccountDetailsLoading
                                                      ? const Text(
                                                          "Save",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily: AppFonts
                                                                .palatino,
                                                          ),
                                                        )
                                                      : const CircularProgressIndicator(
                                                          color: Colors.white,
                                                        )),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white),
                        child: const Text(
                          'Update Account Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.palatino,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: accountHolderNameController,
                              decoration: InputDecoration(
                                hintText: "Account holder name",
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
                                  return 'Enter Your Account Name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: bankNameController,
                              decoration: InputDecoration(
                                hintText: "Bank Name",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                                filled: true,
                                fillColor:
                                    AppColors.primaryColor.withOpacity(0.1),
                                prefixIcon: const Icon(
                                  Icons.account_balance,
                                  color: Colors.black38,
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter Your Bank Name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: accountNoController,
                              decoration: InputDecoration(
                                hintText: "Account Number",
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
                                  return 'Enter Your Account Number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
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
                                      storeBankAccountDetails();
                                    }
                                  },
                                  child: !saveBankAccountDetailsLoading
                                      ? const Text(
                                          "Save",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: AppFonts.palatino,
                                          ),
                                        )
                                      : const CircularProgressIndicator(
                                          color: Colors.white,
                                        )),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )
          : Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
    );
  }

  Row rowProfile(String name, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          name,
          style: TextStyle(
              fontFamily: AppFonts.palatino,
              fontSize: 16,
              fontWeight: FontWeight.normal),
        ),
        SelectableText(
          cursorColor: Colors.brown,
          value,
          style: TextStyle(
              fontFamily: AppFonts.optima,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
