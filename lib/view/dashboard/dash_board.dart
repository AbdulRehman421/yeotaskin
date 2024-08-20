import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yeotaskin/APIs/urls.dart';
import 'package:yeotaskin/models/home_model.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/utilities/snackbar_utils.dart';
import 'package:yeotaskin/view/dashboard/individual%20sales/individual_sales_screen.dart';
import 'package:yeotaskin/view/dashboard/team%20sales/team_sales_screen.dart';
import 'package:yeotaskin/view/dashboard/widgets/gradient_icon.dart';
import 'package:yeotaskin/view/dashboard/widgets/table.dart';

import '../../models/profile_model.dart';
import '../../services/user_profile_manager.dart';
import '../../utilities/app_colors.dart';
import 'package:http/http.dart' as http;

import '../cart screen/confirm_order_screen.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard>
    with AutomaticKeepAliveClientMixin {
  HomeModel? _homeModel;
  ProfileModel profile = UserProfileManager().profile;
  bool loadingHome = false;


  void setLoading(bool status) {
    setState(() {
      loadingHome = status;
    });
  }


  @override
  bool get wantKeepAlive => true;


  Future<void> loadHome() async {
    setLoading(true);
    String? token = await UserProfileManager().getUserToken();
    try {
      final response = await http.get(
          Uri.parse("${URLs.baseURL}${URLs.getHomeURL}"),
          headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        debugPrint("home loaded: ${jsonDecode(response.body)}");

        _homeModel = HomeModel.fromJson(jsonDecode(response.body)['data']);
      } else {
        debugPrint("loadHome(): error");
      }
    } catch (e) {
      debugPrint("loadHome(): $e");
    }
    await getAvailableStock();
    await compareUplineId();
    setLoading(false);
  }



  List<String> names = [];
  List<Map<String, dynamic>> agentSalesList = [];
  List<Map<String, dynamic>> upline = [];
  bool isLoading = false;

  Future<void> getAgentSales() async {
    try {
      final response = await http.get(Uri.parse("${URLs.baseURL}${URLs.agentSaleURL}"));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as List<dynamic>;
          agentSalesList = data
              .where((agent) => names.contains(agent['name']))
              .map((e) => e as Map<String, dynamic>)
              .toList();
          agentSalesList.sort((a, b) => int.parse(b['total_sales'].toString())
              .compareTo(int.parse(a['total_sales'].toString())));
        } else {
          debugPrint("getAgentSales(): else Error");
        }
      } else {
        debugPrint("getAgentSales(): else Error");
      }
    } catch (e) {
      debugPrint("getAgentSales(): ${e.toString()}");
    }
  }

  Future<void> compareUplineId() async {
    String? token = await UserProfileManager().getUserToken();
    try {
      final response = await http.get(
          Uri.parse("https://admin.yeotaskin.com/api/downline"),
          headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        upline = (responseData['data'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        names = upline
            .where((element) => element['upline'].toString() == profile.id.toString())
            .map((element) => element['name'].toString())
            .toList();
        print('upline names: $names');
      } else {
        debugPrint("compareUplineId(): error");
      }
    } catch (e) {
      debugPrint("compareUplineId(): $e");
    }
  }

  Future<void> fetchUplineAndSales() async {
    setState(() {
      isLoading = true;
    });
    await compareUplineId();
    await getAgentSales();
    setState(() {
      isLoading = false;
    });
  }


  bool loadingTopUpWithdraw = false;

  void setTopUpWithdrawLoading(bool status) {
    setState(() {
      loadingTopUpWithdraw = status;
    });
  }



  Future<void> topUpWithdraw(int type, int amount) async {
    if (amount == 0) {
      Navigator.pop(context);

      Navigator.pop(context);

      SnackBarUtils.show(title: 'Invalid Amount', isError: true);
      return;
    }
    setTopUpWithdrawLoading(true);
    String? token = await UserProfileManager().getUserToken();
    try {
      final response = await http.post(
          Uri.parse(
              "${URLs.baseURL}${URLs.getTopUpWithdrawURL}?type=$type&amount=$amount"),
          headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        _topUpController.clear();
        _withdrawController.clear();
        Navigator.pop(context);
        Navigator.pop(context);
        SnackBarUtils.show(
            title: jsonDecode(response.body)['message'], isError: false);
      } else {
        debugPrint("topUpWithdraw(): error");
      }
    } catch (e) {
      debugPrint("topUpWithdraw(): $e");
    }
    await getAvailableStock();
    setTopUpWithdrawLoading(false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadHome();
    fetchUplineAndSales();
  }

  final TextEditingController _topUpController = TextEditingController();
  final TextEditingController _withdrawController = TextEditingController();
  final double tableRowHeight = 50;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    fetchUplineAndSales();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: !loadingHome
              ? _homeModel != null
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    "Welcome ${profile.name}",
                                    style: const TextStyle(
                                      fontFamily: AppFonts.palatino,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                "(Reached)",
                                style: TextStyle(
                                  fontFamily: AppFonts.palatino,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _homeModel?.moq?.toLowerCase() ==
                                          "reached"
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          headerText('Team'),
                          Card(
                            elevation: 5,
                            margin: const EdgeInsets.only(top: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 1,
                              height: MediaQuery.of(context).size.height * 0.22,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: walletAmountWidget('Income Wallet',
                                        "${_homeModel!.incomeWallet}"),
                                  ),
                                  VerticalDivider(
                                    width: 1,
                                    thickness: 1,
                                    indent: 50,
                                    endIndent: 50,
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: walletAmountWidget(
                                      'E-Wallet',
                                      "${_homeModel!.rebateWallet}",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              actionCard(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return Container(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            const Text(
                                              "TopUp",
                                              style: TextStyle(
                                                  fontFamily: AppFonts.optima,
                                                  fontSize: 18),
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Card(
                                                  margin: EdgeInsets.zero,
                                                  child: SizedBox(
                                                    height: 70,
                                                    width: 150,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Text(
                                                          'Income Wallet',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AppFonts.optima,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                            color: AppColors
                                                                .accent,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Text(
                                                            "RM ${_homeModel!.incomeWallet}",
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  AppFonts
                                                                      .arial,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: 150,
                                                    child: TextFormField(
                                                      controller:
                                                          _topUpController,
                                                      cursorColor: AppColors
                                                          .primaryColor,
                                                      // onChanged: (value) {
                                                      //   if (double.parse(
                                                      //           value.isNotEmpty
                                                      //               ? value
                                                      //               : '0.0') <=
                                                      //       double.parse(_homeModel!
                                                      //           .incomeWallet
                                                      //           .toString())) {
                                                      //   } else {
                                                      //     _topUpController
                                                      //         .clear();
                                                      //
                                                      //     setState(() {});
                                                      //     // SnackBarUtils.show(
                                                      //     //   title:
                                                      //     //   "Amount can't be greater than Income Wallet",
                                                      //     //   isError: true,
                                                      //     // );
                                                      //   }
                                                      // },
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration: InputDecoration(
                                                          helperText: '',
                                                          errorMaxLines: 1,
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide: const BorderSide(
                                                                  color: AppColors
                                                                      .primaryColor)),
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide: const BorderSide(
                                                                  color: AppColors
                                                                      .primaryColor))),
                                                    ))
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 60,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primaryColor,
                                                  foregroundColor: Colors.white,
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: AppFonts.optima,
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 32,
                                                    vertical: 16,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (double.parse(
                                                          _topUpController.text
                                                                  .isNotEmpty
                                                              ? _topUpController
                                                                  .text
                                                              : '0') !=
                                                      0.0) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                              Colors.white,
                                                          surfaceTintColor:
                                                              Colors
                                                                  .transparent,
                                                          title: const Text(
                                                            "Confirmation",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppFonts
                                                                      .palatino,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: AppColors
                                                                  .accent,
                                                            ),
                                                          ),
                                                          content:
                                                              const SizedBox(
                                                            height: 60,
                                                            child: Text(
                                                              "Are you sure to TopUp",
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontFamily:
                                                                    AppFonts
                                                                        .optima,
                                                              ),
                                                            ),
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .backgroundColor,
                                                                foregroundColor:
                                                                    AppColors
                                                                        .accent,
                                                              ),
                                                              child: const Text(
                                                                'Go Back',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:

                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      AppFonts
                                                                          .palatino,
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                topUpWithdraw(
                                                                    1,
                                                                    int.parse(_topUpController
                                                                            .text
                                                                            .isNotEmpty
                                                                        ? _topUpController
                                                                            .text
                                                                        : '0'));
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .primaryColor,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              child: const Text(
                                                                'I confirm',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      AppFonts
                                                                          .palatino,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    Navigator.pop(context);
                                                    SnackBarUtils.show(
                                                        title: 'Invalid Amount',
                                                        isError: true);
                                                  }
                                                },
                                                child: const Text("TopUp"),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                text: 'Top-up',
                                iconData: Icons.wallet,
                              ),
                              actionCard(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return Container(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            const Text(
                                              "Withdraw",
                                              style: TextStyle(
                                                  fontFamily: AppFonts.optima,
                                                  fontSize: 18),
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Card(
                                                  margin: EdgeInsets.zero,
                                                  child: SizedBox(
                                                    height: 70,
                                                    width: 150,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Text(
                                                          'Income Wallet',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AppFonts.optima,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                            color: AppColors
                                                                .accent,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Text(
                                                            "RM ${_homeModel!.incomeWallet}",
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  AppFonts
                                                                      .arial,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: 150,
                                                    child: TextFormField(
                                                      controller:
                                                          _withdrawController,
                                                      cursorColor: AppColors
                                                          .primaryColor,
                                                      // onChanged: (value) {
                                                      //   if (double.parse(
                                                      //           value.isNotEmpty
                                                      //               ? value
                                                      //               : '0.0') <=
                                                      //       double.parse(_homeModel!
                                                      //           .incomeWallet
                                                      //           .toString())) {
                                                      //   } else {
                                                      //
                                                      //     setState(() {});
                                                      //     // SnackBarUtils.show(
                                                      //     //   title:
                                                      //     //   "Amount can't be greater than Income Wallet",
                                                      //     //   isError: true,
                                                      //     // );
                                                      //   }
                                                      // },
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .always,
                                                      validator: (val) {
                                                        double? amount =
                                                            double.tryParse(
                                                                val ?? '');
                                                        if (amount == null) {
                                                          return null;
                                                        }

                                                        if (amount >
                                                            double.parse(_homeModel!
                                                                .incomeWallet
                                                                .toString())) {
                                                          return 'Insufficient Balance';
                                                        }

                                                        return null;
                                                      },
                                                      keyboardType:
                                                          TextInputType.number,
                                                      decoration: InputDecoration(
                                                          helperText: '',
                                                          errorMaxLines: 1,
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide: const BorderSide(
                                                                  color: AppColors
                                                                      .primaryColor)),
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide: const BorderSide(
                                                                  color: AppColors
                                                                      .primaryColor))),
                                                    ))
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 60,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primaryColor,
                                                  foregroundColor: Colors.white,
                                                  textStyle: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: AppFonts.optima,
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 32,
                                                    vertical: 16,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (double.parse(_withdrawController
                                                                  .text
                                                                  .isNotEmpty
                                                              ? _withdrawController
                                                                  .text
                                                              : '0') <=
                                                          double.parse(
                                                              _homeModel!
                                                                  .incomeWallet
                                                                  .toString()) &&
                                                      double.parse(_withdrawController
                                                                  .text
                                                                  .isNotEmpty
                                                              ? _withdrawController
                                                                  .text
                                                              : '0') !=
                                                          0.0) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                              Colors.white,
                                                          surfaceTintColor:
                                                              Colors
                                                                  .transparent,
                                                          title: const Text(
                                                            "Confirmation",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppFonts
                                                                      .palatino,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: AppColors
                                                                  .accent,
                                                            ),
                                                          ),
                                                          content:
                                                              const SizedBox(
                                                            height: 60,
                                                            child: Text(
                                                              "Are you sure to Withdraw",
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontFamily:
                                                                    AppFonts
                                                                        .optima,
                                                              ),
                                                            ),
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .backgroundColor,
                                                                foregroundColor:
                                                                    AppColors
                                                                        .accent,
                                                              ),
                                                              child: const Text(
                                                                'Go Back',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      AppFonts
                                                                          .palatino,
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                double amount = double.parse(
                                                                    _withdrawController
                                                                            .text
                                                                            .isNotEmpty
                                                                        ? _withdrawController
                                                                            .text
                                                                        : '0');
                                                                if (amount >
                                                                    double.parse(_homeModel!
                                                                        .incomeWallet
                                                                        .toString())) {
                                                                } else {
                                                                  topUpWithdraw(
                                                                      0,
                                                                      int.parse(_withdrawController
                                                                              .text
                                                                              .isNotEmpty
                                                                          ? _withdrawController
                                                                              .text
                                                                          : '0'));
                                                                }
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .primaryColor,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                              child: const Text(
                                                                'I confirm',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      AppFonts
                                                                          .palatino,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    Navigator.pop(context);
                                                    SnackBarUtils.show(
                                                        title: 'Invalid Amount',
                                                        isError: true);
                                                  }
                                                },
                                                child: const Text("Withdraw"),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                text: 'Withdraw',
                                iconData: Icons.output,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          headerText('Sales Information'),
                          salesCard(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const IndividualSalesScreen(),
                                  ));
                            },
                            salesType: 'Individual Sales',
                            salesAmount: "${_homeModel!.individualSales}",
                            assetImagePath: "assets/images/note.png",
                            backgroundColors: [
                              const Color(0xffcc998d),
                              const Color(0xff554348),
                            ],
                          ),
                          const SizedBox(height: 10),
                          salesCard(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TeamSalesScreen(),
                                  ));
                            },
                            salesType: 'Team Sales',
                            salesAmount: "${_homeModel!.teamSales}",
                            assetImagePath: "assets/images/trophy.png",
                            backgroundColors: [
                              const Color(0xffc3b091),
                              const Color(0xff48392a),
                            ],
                          ),
                          const SizedBox(height: 30),
                          headerText(
                            "Stock In Warehouse",
                          ),
                          availableStock.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(bottom: 20),
                                  child: TableWidget(
                                    headerText: const [
                                      '',
                                      '',
                                      'Product',
                                      'Quantity'
                                    ],
                                    columnData: availableStock,
                                    // [
                                    //   {
                                    //     'product': {'product_name': "Test"},
                                    //     'quantity': 2,
                                    //   }
                                    // ],
                                    isStockData: true,
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: const Text(
                                    "No Stock Information Found",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppFonts.palatino,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
      ListView.builder(
        itemCount: agentSalesList.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final agent = agentSalesList[index];
          return Table(
            columnWidths: const {
              0: FixedColumnWidth(40),
              1: FixedColumnWidth(0.5),
              2: FlexColumnWidth(5),
              3: FlexColumnWidth(2)
            },
            children: [
              index == 0
                  ? TableRow(
                  decoration: const BoxDecoration(
                      color: AppColors.theme,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
                  children: [
                    SizedBox(),
                    SizedBox(),
                    SizedBox(
                      height: tableRowHeight,
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              "Downline",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: AppColors.backgroundColor,
                                fontFamily: AppFonts.palatino,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              "Level",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: AppColors.backgroundColor,
                                fontFamily: AppFonts.palatino,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              "Sales",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: AppColors.backgroundColor,
                                fontFamily: AppFonts.palatino,
                              ),
                            ),
                          ),
                        ],
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                      ),
                    ),
                  ])
                  : TableRow(
                decoration: BoxDecoration(
                  color: index.isEven
                      ? AppColors.accent.withOpacity(0.4)
                      : AppColors.background,
                  borderRadius: (index == agentSalesList.length - 1)
                      ? const BorderRadius.vertical(bottom: Radius.circular(8))
                      : null,
                ),
                children: [
                  SizedBox(
                    height: tableRowHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          (index + 1).toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: AppFonts.optima,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: tableRowHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        VerticalDivider(
                          width: 0.5,
                          thickness: 0.5,
                          color: AppColors.accent.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: tableRowHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            names[index],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: AppFonts.palatino,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: tableRowHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            agent['level']?.toString() ?? '0',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: AppFonts.palatino,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: tableRowHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          agent['total_sales']?.toString() ?? '0',
                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: AppFonts.palatino,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
                        ],
                      ),
                    )
                  : Scaffold(
                      body: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Center(
                            child: Text("Something went wrong!"),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextButton(
                            style: const ButtonStyle(
                                overlayColor: MaterialStatePropertyAll(
                                    AppColors.primaryColor)),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DashBoard(),
                                  ));
                            },
                            child: const Text(
                              "Retry",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          )
                        ],
                      ),
                    )
              : const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
        ),
      ),
    );
  }

  List availableStock = [];

  Future<void> getAvailableStock() async {
    availableStock.clear();
    ProfileModel profile = UserProfileManager().profile;
    String? token = await UserProfileManager().getUserToken();
    try {
      final response = await http.get(
          Uri.parse(
              "${URLs.baseURL}${URLs.getAvailableStockURL}?id=${profile.id}"),
          headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        debugPrint("AvailableStock : ${response.body}");

        final data = jsonDecode(response.body)['data'];
        if (data.toString() != '[]') {
          availableStock = data;
        }

        setState(() {});
      } else {
        debugPrint("getAvailableStock(): error");
      }
    } catch (e) {
      debugPrint("getAvailableStock(): $e");
    }
  }

  Widget headerText(String text) => Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 24,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w900,
            fontFamily: AppFonts.palatino,
          ),
        ),
      );

  Widget walletAmountWidget(
    String title,
    String amount, {
    Color? titleColor,
    Color textColor = Colors.white,
    bool centerTitle = true,
  }) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: titleColor ?? Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.optima,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Text(
                  amount,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: AppFonts.optima,
                  ),
                ),
              ),
              Text(
                'RM',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontFamily: AppFonts.youngSerifDefault,
                ),
              ),
            ],
          ),
        ],
      );

  Widget actionCard({
    required GestureTapCallback onTap,
    required String text,
    required IconData iconData,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.6),
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GradientIcon(
                iconData,
                42,
                const LinearGradient(
                  colors: [
                    AppColors.twoLevelColor,
                    AppColors.threeLevelColor,
                  ],
                ),
              ),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.topLevelColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.optima,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget salesCard({
    required GestureTapCallback onTap,
    required String salesType,
    required String salesAmount,
    required String assetImagePath,
    required List<Color> backgroundColors,
  }) =>
      Stack(
        children: [
          InkWell(
            onTap: onTap,
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 20),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: backgroundColors,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                      child: walletAmountWidget(
                        salesType,
                        salesAmount,
                        titleColor: Colors.white,
                        centerTitle: false,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 0,
            child: Image(
              image: AssetImage(assetImagePath),
              height: 70,
            ),
          )
        ],
      );
}
