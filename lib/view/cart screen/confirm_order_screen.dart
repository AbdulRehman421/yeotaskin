import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/utilities/cart.dart';
import 'package:yeotaskin/view/cart%20screen/widgets/cart_item_card.dart';

import '../../APIs/urls.dart';
import '../../models/product_model.dart';
import '../../services/user_profile_manager.dart';
import '../../utilities/app_colors.dart';
import '../../utilities/price_converter.dart';
import 'package:http/http.dart' as http;

import '../../utilities/snackbar_utils.dart';

class ConfirmOrderScreen extends StatefulWidget {
  final double totalAmount;
  final double eWallet;
  final double incomeWallet;
  final List<ProductModel> cart;
  final Function onSubmitOrder;
  const ConfirmOrderScreen(
      {super.key,
      required this.cart,
      required this.totalAmount,
      required this.onSubmitOrder,
      required this.eWallet,
      required this.incomeWallet});

  @override
  State<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  String attachment = "";
  File? imageFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        surfaceTintColor: AppColors.backgroundColor,
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          "Submit Order",
          style: TextStyle(
            fontFamily: AppFonts.palatino,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.cart.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.only(bottom: 300),
                    shrinkWrap: true,
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      return CartItemCard(
                        cartProduct: widget.cart[index],
                        index: index,
                        buttonPressed: () {},
                        cart: Cart(),
                        type: 'confirmOrder',
                      );
                    },
                  )
                : const Center(
                    child: Text(
                    "Nothing found!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.palatino,
                      fontSize: 18,
                    ),
                  )),
          ),
          Column(
            children: [
              row("To Pay", widget.totalAmount),
              const SizedBox(
                height: 10,
              ),
              const SelectableText(
                cursorColor: Colors.brown,
                "YEOTA SDN. BHD.",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SelectableText(
                cursorColor: Colors.brown,
                "Public bank",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SelectableText(
                    cursorColor: Colors.brown,
                    "3235330832",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        _copyTextToClipboard(
                            "3235330832");
                      },
                      child: const Icon(
                        Icons.copy,
                        size: 15,
                      ))
                ],
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.backgroundColor,
                      foregroundColor: AppColors.primaryColor),
                  onPressed: () {
                    selectAttachment();
                  },
                  child: attachment.isEmpty
                      ? const Text("Select Attachment (Compulsory)")
                      : Text(attachment)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
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
                    onPressed: () {
                      if (imageFile != null) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.transparent,
                              title: const Text(
                                "Confirm Order",
                                style: TextStyle(
                                  fontFamily: AppFonts.palatino,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                              content: const Text(
                                "Do you want place order?",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: AppFonts.optima,
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.backgroundColor,
                                      foregroundColor: AppColors.accent,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "No",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppFonts.palatino,
                                      ),
                                    )),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor:
                                          AppColors.backgroundColor),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    submitOrder();
                                  },
                                  child: const Text(
                                    "Yes",
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
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              surfaceTintColor: Colors.transparent,
                              title: const Text(
                                "Attachment",
                                style: TextStyle(
                                  fontFamily: AppFonts.palatino,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                              content: Container(
                                height: 50,
                                child: const Text(
                                  "You have to select attachment to confirm order",
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
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text(
                                    'OK',
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
                      }
                    },
                    child: !submitOrderLoading
                        ? const Text("Confirm Order")
                        : const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding row(String key, double value) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(PriceUtility.priceWithSymbol(value),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
        ],
      ),
    );
  }

  bool submitOrderLoading = false;
  void setLoading(bool status) {
    setState(() {
      submitOrderLoading = status;
    });
  }

  void popScreen() {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> submitOrder() async {
    setLoading(true);
    String? token = await UserProfileManager().getUserToken();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("${URLs.baseURL}${URLs.submitOrderURL}"),
      );

      request.headers['Authorization'] = "Bearer $token";
      request.fields["total_amount"] = widget.totalAmount.toString();
      request.fields["product"] = jsonEncode(widget.cart);
      request.fields["income_use"] = widget.incomeWallet.toString();
      request.fields["ewallet_use"] = widget.eWallet.toString();

      request.files.add(
        await http.MultipartFile.fromPath(
          "attachment",
          imageFile!.path,
        ),
      );
      debugPrint(request.fields.toString());
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        if (jsonDecode(responseBody)['success'] == true) {
          SnackBarUtils.show(
              title: "Order placed successfully", isError: false, duration: 1);
          widget.onSubmitOrder();
          popScreen();
          debugPrint("submitOrder(): order submitted");

        } else {
          SnackBarUtils.show(
              title: "An error occurred while placing you order!",
              isError: true,
              duration: 1);
          debugPrint("submitOrder(): error occurred");
        }
      } else {
        SnackBarUtils.show(
            title: "An error occurred while placing you order!",
            isError: true,
            duration: 1);
        debugPrint("submitOrder(): HTTP error occurred");
      }
    } catch (e) {
      SnackBarUtils.show(
          title: "Something went wrong!", isError: true, duration: 2);
      debugPrint("submitOrder(): $e");
    }
    setLoading(false);
  }

  Future<void> selectAttachment() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.storage,
    ].request();

    if (status[Permission.storage]!.isGranted) {
      debugPrint("Storage Permission Granted");
      try {
        final ImagePicker picker = ImagePicker();
        XFile? pickedImage = await picker.pickImage(
          source: ImageSource.gallery,
          maxHeight: 512,
          maxWidth: 512,
          imageQuality: 72,
        );
        if (pickedImage != null) {
          imageFile = File(pickedImage.path);
          setState(() {
            attachment = pickedImage.name;
          });
        }
      } catch (e) {
        SnackBarUtils.show(title: e.toString(), isError: true, duration: 2);
        debugPrint("changeProfilePhoto() : ${e.toString()}");
      }
    } else {
      SnackBarUtils.show(
          title: 'Storage Permission Not Granted', isError: true, duration: 2);
      debugPrint("Storage Permission Not Granted");
    }
  }

  void _copyTextToClipboard(
      String text,
      ) {
    Clipboard.setData(ClipboardData(text: text));
    SnackBarUtils.show(title: 'Text Copied', isError: false);
  }
}
