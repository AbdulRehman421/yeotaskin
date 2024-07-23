import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:yeotaskin/APIs/urls.dart';
import 'package:yeotaskin/models/home_model.dart';
import 'package:yeotaskin/services/user_profile_manager.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/utilities/cart.dart';
import 'package:yeotaskin/utilities/price_converter.dart';
import 'package:yeotaskin/utilities/snackbar_utils.dart';
import 'package:yeotaskin/view/cart%20screen/confirm_order_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Cart cart;
  final double totalAmount;
  final Function itemRemoved;
  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.totalAmount,
    required this.itemRemoved,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  double incomeWallet = 0.0;
  double eWallet = 0.0;
  HomeModel? _homeModel;
  bool loadingHome = false;
  void setLoading(bool status) {
    setState(() {
      loadingHome = status;
    });
  }

  @override
  void initState() {
    super.initState();
    loadHome();
  }

  final TextEditingController _incomeWalletController = TextEditingController();
  final TextEditingController _eWalletController = TextEditingController();

  Future<void> loadHome() async {
    setLoading(true);
    String? token = await UserProfileManager().getUserToken();
    try {
      final response = await http.get(
          Uri.parse("${URLs.baseURL}${URLs.getHomeURL}"),
          headers: {"Authorization": "Bearer $token"});
      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        debugPrint("home loaded");
        _homeModel = HomeModel.fromJson(jsonDecode(response.body)['data']);
      } else {
        debugPrint("loadHome(): error");
      }
    } catch (e) {
      debugPrint("loadHome(): $e");
    }
    setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    Cart cart = widget.cart;
    double totalAmount = widget.totalAmount;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Checkout",
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            totalPriceData("Subtotal", totalAmount),
            totalPriceData(
              "To Pay",
              totalAmount - incomeWallet - eWallet,
              isFinalPrice: true,
            ),
            const SizedBox(
              height: 30,
            ),
            !loadingHome
                ? _homeModel != null
                    ? Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Card(
                                  margin: EdgeInsets.zero,
                                  child: SizedBox(
                                    height: 70,
                                    width: 150,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Income Wallet',
                                          style: TextStyle(
                                            fontFamily: AppFonts.optima,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            "RM ${_homeModel!.incomeWallet}",
                                            style: const TextStyle(
                                              fontFamily: AppFonts.arial,
                                              fontWeight: FontWeight.bold,
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
                                      controller: _incomeWalletController,
                                      readOnly: cart.items.isNotEmpty
                                          ? _homeModel!.incomeWallet == 0
                                              ? true
                                              : false
                                          : true,
                                      cursorColor: AppColors.primaryColor,
                                      onChanged: (value) {
                                        if (double.parse(value.isNotEmpty
                                                ? value
                                                : '0.0') <=
                                            totalAmount) {
                                          if (double.parse(value.isNotEmpty
                                                  ? value
                                                  : '0.0') <=
                                              double.parse(_homeModel!
                                                  .incomeWallet
                                                  .toString())) {
                                            setState(() {
                                              incomeWallet = double.parse(
                                                  value.isNotEmpty
                                                      ? value
                                                      : '0.0');
                                            });
                                          } else {
                                            totalAmount =
                                                cart.calculateTotalPrice();
                                            setState(() {});
                                          }
                                        } else {
                                          _incomeWalletController.clear();
                                          incomeWallet = 0.0;
                                          setState(() {
                                            totalAmount =
                                                cart.calculateTotalPrice();
                                          });
                                          SnackBarUtils.show(
                                            title:
                                                "Amount can't be greater than 'To Pay'",
                                            isError: true,
                                          );
                                        }
                                      },
                                      autovalidateMode: AutovalidateMode.always,
                                      validator: (val) {
                                        double? amount =
                                            double.tryParse(val ?? '');
                                        if (amount == null) {
                                          return null;
                                        }

                                        if (amount >
                                            double.parse(_homeModel!
                                                .incomeWallet
                                                .toString())) {
                                          return 'Insufficient Balance';
                                        }
                                        if (amount > totalAmount) {
                                          return "Amount can't be greater than 'To Pay'";
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          helperText: '',
                                          errorMaxLines: 1,
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color:
                                                      AppColors.primaryColor)),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              borderSide: const BorderSide(
                                                  color:
                                                      AppColors.primaryColor))),
                                    ))
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Card(
                                  child: SizedBox(
                                    height: 70,
                                    width: 150,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Icon(Icons.account_balance_wallet,color: AppColors.primaryColor,size: 40,),
                                        const Text(
                                          'E-Wallet',
                                          style: TextStyle(
                                            fontFamily: AppFonts.optima,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            "RM ${_homeModel!.rebateWallet}",
                                            style: const TextStyle(
                                              fontFamily: AppFonts.arial,
                                              fontWeight: FontWeight.bold,
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
                                      controller: _eWalletController,
                                      readOnly: _homeModel!.rebateWallet == 0
                                          ? true
                                          : false,
                                      onChanged: (value) {
                                        if (double.parse(value.isNotEmpty
                                                ? value
                                                : '0.0') <=
                                            totalAmount) {
                                          if (double.parse(value.isNotEmpty
                                                  ? value
                                                  : '0.0') <=
                                              double.parse(_homeModel!
                                                  .rebateWallet
                                                  .toString())) {
                                            setState(() {
                                              eWallet = double.parse(
                                                  value.isNotEmpty
                                                      ? value
                                                      : '0.0');
                                            });
                                          } else {
                                            totalAmount =
                                                cart.calculateTotalPrice();
                                            setState(() {});
                                          }
                                        } else {
                                          _eWalletController.clear();
                                          eWallet = 0.0;
                                          setState(() {
                                            totalAmount =
                                                cart.calculateTotalPrice();
                                          });
                                          SnackBarUtils.show(
                                              title:
                                                  "Amount can't be greater than To Pay",
                                              isError: true);
                                        }
                                      },
                                      cursorColor: AppColors.primaryColor,
                                      autovalidateMode: AutovalidateMode.always,
                                      validator: (val) {
                                        double? amount =
                                            double.tryParse(val ?? '');
                                        if (amount == null) {
                                          return null;
                                        }

                                        if (amount >
                                            double.parse(_homeModel!
                                                .rebateWallet
                                                .toString())) {
                                          return 'Insufficient Balance';
                                        }
                                        if (amount > totalAmount) {
                                          return "Amount can't be greater than 'To Pay'";
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        helperText: '',
                                        errorMaxLines: 1,
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: AppColors.primaryColor)),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ))
                              ],
                            ),
                          ],
                        ),
                      )
                    : const Center(
                        child: Text(
                          "No wallet found!",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.palatino,
                            fontSize: 18,
                          ),
                        ),
                      )
                : const Center(
                    child: Text(
                      "Loading wallets...",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.palatino,
                        fontSize: 18,
                      ),
                    ),
                  ),
            const SizedBox(
              height: 30,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                onPressed: (_formKey.currentState?.validate() == false)
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.transparent,
                              title: const Text(
                                "Confirmation",
                                style: TextStyle(
                                  fontFamily: AppFonts.palatino,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                              content: const SizedBox(
                                height: 100,
                                child: Text(
                                  "Are you sure to confirm order?\nYou can't change product quantity or remove any product there.",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: AppFonts.optima,
                                  ),
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.backgroundColor,
                                    foregroundColor: AppColors.accent,
                                  ),
                                  child: const Text(
                                    'Go Back',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppFonts.palatino,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (cart.items.isNotEmpty) {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ConfirmOrderScreen(
                                            cart: cart.items,
                                            totalAmount: totalAmount -
                                                incomeWallet -
                                                eWallet,
                                            onSubmitOrder: () {
                                              _incomeWalletController.clear();
                                              _eWalletController.clear();
                                              cart.items.clear();
                                              totalAmount = 0.00;
                                              eWallet = 0.00;
                                              incomeWallet = 0.00;
                                              Cart().clearCart();
                                              setState(() {});

                                              widget.itemRemoved();
                                            },
                                            eWallet: eWallet,
                                            incomeWallet: incomeWallet,
                                          ),
                                        ),
                                      );
                                    } else {
                                      SnackBarUtils.show(
                                        title:
                                            "Cart is empty, Please add at-least one product",
                                        isError: true,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text(
                                    'I confirm',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppFonts.palatino,
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        );
                      },
                child: const Text("Submit"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget totalPriceData(String key, double value, {bool isFinalPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$key: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: AppFonts.palatino,
          ),
        ),
        Text(
          PriceUtility.priceWithSymbol(value),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isFinalPrice ? 18 : 16,
            fontFamily: AppFonts.arial,
            color: isFinalPrice ? Colors.orange.shade900 : Colors.black,
          ),
        ),
      ],
    );
  }
}
