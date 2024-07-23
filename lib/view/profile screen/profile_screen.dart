import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:yeotaskin/models/profile_model.dart';
import 'package:yeotaskin/utilities/snackbar_utils.dart';
import 'package:yeotaskin/view/profile%20screen/account_details_screen.dart';
import 'package:yeotaskin/view/profile%20screen/income%20log%20screen/income_log_screen.dart';
import 'package:yeotaskin/view/profile%20screen/order/customer%20order/customer_order_screen.dart';
import 'package:yeotaskin/view/profile%20screen/order/order%20history/order_history_screen.dart';
import 'package:yeotaskin/view/profile%20screen/pdf_view_screen.dart';
import 'package:yeotaskin/view/profile%20screen/personal_information.dart';
import 'package:yeotaskin/view/profile%20screen/shipping%20fee/shipping_fee_screen.dart';
import '../../services/user_profile_manager.dart';
import '../../utilities/app_colors.dart';
import '../../utilities/app_fonts.dart';
import 'knowledge base/knowledge_base_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileModel profile = UserProfileManager().profile;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 60, left: 25, bottom: 25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    child: Center(
                      child: CircleAvatar(
                        foregroundImage: profile.profilePhoto!.isNotEmpty
                            ? NetworkImage(profile.profilePhoto!)
                            : null,
                        backgroundColor: AppColors.backgroundColor,
                        maxRadius: 30,
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(profile.name!,
                      style: const TextStyle(
                        fontFamily: AppFonts.palatino,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50),
                        topLeft: Radius.circular(50))),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Card(
                      //       child: Container(
                      //         height: 150,
                      //         width: 150,
                      //         child: Column(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Icon(Icons.account_balance_wallet,color: AppColors.primaryColor,size: 40,),
                      //             Text('Comission Wallet'),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //     Card(
                      //       child: Container(
                      //         height: 150,
                      //         width: 150,
                      //         child: Column(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Icon(Icons.account_balance_wallet,color: AppColors.primaryColor,size: 40,),
                      //             Text('Bonus Wallet'),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PersonalInformation(
                                          updatePhoto: () {
                                            profile =
                                                UserProfileManager().profile;
                                            setState(() {});
                                          },
                                        ),
                                      ));
                                },
                                leading: const Icon(Icons.person_outline),
                                title: const Text("Personal information"),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                ),
                              ),
                              const Divider(color: Colors.black12),
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AccountDetailsScreen(),
                                      ));
                                },
                                leading: const Icon(Icons.account_balance_outlined),
                                title: const Text("Bank Account"),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                ),
                              ),
                              const Divider(color: Colors.black12),
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const OrderHistoryScreen(),
                                      ));
                                },
                                leading: const Icon(Icons.card_travel_outlined),
                                title: const Text("Order History"),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                ),
                              ),
                              const Divider(color: Colors.black12),
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CustomerOrderScreen(),
                                      ));
                                },
                                leading: const Icon(Icons.card_travel_outlined),
                                title: const Text("Customer Order"),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                ),
                              ),
                              const Divider(color: Colors.black12),
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ShippingFeeScreen(),
                                      ));
                                },
                                leading: const Icon(Icons.local_shipping_outlined),
                                title: const Text("Shipping fee"),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                ),
                              ),
                              const Divider(color: Colors.black12),
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const KnowledgeBaseScreen(),
                                      ));
                                },
                                leading: const Icon(Icons.blur_circular_outlined),
                                title: const Text("Knowledge Base"),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                ),
                              ),
                              const Divider(color: Colors.black12),
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const IncomeLogScreen(),
                                      ));
                                },
                                leading: const Icon(Icons.info_outline),
                                title: const Text("Income Logs"),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                ),
                              ),
                              const Divider(color: Colors.black12),
                              ListTile(
                                leading: const Icon(Icons.link),
                                title: SelectableText(
                                    "partners.yeotaskin.com/?value=${profile.id}"),
                                trailing: InkWell(
                                    onTap: () {
                                      _copyTextToClipboard(
                                          "partners.yeotaskin.com/?value=${profile.id}");
                                    },
                                    child: const Icon(
                                      Icons.copy,
                                      size: 15,
                                    )),
                              ),
                              const Divider(color: Colors.black12),
                              const ListTile(
                                leading: Icon(Icons.announcement_outlined),
                                title: Text("Feedback"),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                ),
                              ),
                              const Divider(
                                color: Colors.black12,
                              ),
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PDFViewScreen(
                                            stringURL: profile.attachment!),
                                      ));
                                },
                                leading: const Icon(Icons.person_outlined),
                                title: const Text("Agreement"),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  void _copyTextToClipboard(
    String text,
  ) {
    Clipboard.setData(ClipboardData(text: text));
    SnackBarUtils.show(title: 'Text Copied', isError: false);
  }
}
