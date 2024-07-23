import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yeotaskin/APIs/urls.dart';
import 'package:yeotaskin/models/product_model.dart';
import 'package:yeotaskin/view/cart%20screen/cart_screen.dart';
import 'package:yeotaskin/view/product%20screen/widget/item_card.dart';
import 'package:http/http.dart' as http;
import '../../models/profile_model.dart';
import '../../services/user_profile_manager.dart';
import '../../utilities/app_colors.dart';
import '../../utilities/app_fonts.dart';
import '../../utilities/cart.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with AutomaticKeepAliveClientMixin {
  ProfileModel profile = UserProfileManager().profile;
  bool productsLoading = false;
  bool search = false;
  late Cart cart;

  void setLoading(bool status) {
    setState(() {
      productsLoading = status;
    });
  }

  List<ProductModel> allProducts = [];
  Future getAllProducts() async {
    setLoading(true);
    try {
      final response =
          await http.get(Uri.parse("${URLs.baseURL}${URLs.getProductsURL}"));

      if (response.statusCode == 200 &&
          jsonDecode(response.body)['success'] == true) {
        allProducts.clear();
        if (!mounted) {
          return;
        }

        final List fetchedProducts = jsonDecode(response.body)['products'];
        debugPrint("Products loaded: ${jsonDecode(response.body)}");

        fetchedProducts.map((product) {
          final List productPrice = product['product_level_price'];
          productPrice.map((levelPrice) {
            if (levelPrice['level_id'].toString() == profile.level.toString()) {
              allProducts.add(ProductModel.fromJson(product as Map<String, dynamic>));
            }
          }).toList();
        }).toList();
        loadProduct();
        setLoading(false);
      } else {
        setLoading(false);
        debugPrint("getAllProducts(): else Error");
      }
    } catch (e) {
      setLoading(false);
      debugPrint("getAllProducts(): ${e.toString()}");
    }
  }

  List<ProductModel> productsToShow = [];
  TextEditingController searchController = TextEditingController();
  void loadProduct() {
    productsToShow.clear();
    if (search) {
      allProducts.map((product) {
        if (kDebugMode) {
          print(product.createdAt);
        }
        if (product.productName!
            .toLowerCase()
            .contains(searchController.text.toLowerCase())) {
          productsToShow.add(product);
        }
      }).toList();
      productsToShow.sort((a, b) => DateTime.parse(b.createdAt!).compareTo(DateTime.parse(a.createdAt!)));
      for (var element in productsToShow) { if (kDebugMode) {
        print('${element.productName} - ${element.createdAt}');
      }}
    } else {
      productsToShow.addAll(allProducts);
    }
    setState(() {});
  }

  void loadCart() {
    cart = Cart();
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    loadCart();
    // TODO: implement initState
    super.initState();
    getAllProducts();
  }

  @override
  Widget build(BuildContext context) {

    super.build(context);
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return Future(() => true);
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          surfaceTintColor: AppColors.backgroundColor,
          backgroundColor: AppColors.backgroundColor,
          automaticallyImplyLeading: false,
          leadingWidth: 80,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              child: Center(
                child: CircleAvatar(
                  foregroundImage: profile.profilePhoto!.isNotEmpty
                      ? NetworkImage(profile.profilePhoto!)
                      : null,
                  backgroundColor: AppColors.primaryColor,
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: AppColors.backgroundColor,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            !search
                ? InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: () {
                      setState(() {
                        search = true;
                      });
                    },
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(100)),
                        child: const Icon(
                          Icons.search,
                          color: AppColors.primaryColor,
                        )),
                  )
                : SizedBox(
                    width: 250,
                    height: 50,
                    child: TextFormField(
                      controller: searchController,
                      cursorColor: AppColors.primaryColor,
                      maxLines: 1,
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: const BorderSide(
                                  color: AppColors.primaryColor)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: const BorderSide(
                                  color: AppColors.primaryColor)),
                          suffixIcon: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              onTap: () {
                                setState(() {
                                  searchController.clear();
                                  loadProduct();
                                  search = false;
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                color: AppColors.primaryColor,
                              ))),
                      onChanged: (value) {
                        loadProduct();
                        setState(() {});
                      },
                    )),
            const SizedBox(
              width: 10,
            ),
            Stack(
              children: [
                Positioned(
                  right: 0,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      (cart.items.isNotEmpty ? cart.items.length : "0")
                          .toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.backgroundColor, fontSize: 10),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartScreen(
                            itemRemoved: () {
                              loadCart();
                            },
                          ),
                        ));
                  },
                  child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(100)),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: AppColors.primaryColor,
                      )),
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
        body: !productsLoading
            ? productsToShow.isNotEmpty
                ? Padding(
                    padding: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? const EdgeInsets.only(right: 10, left: 10, top: 16)
                        : const EdgeInsets.only(right: 48, left: 48, top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Our Best Product",
                          style: TextStyle(
                            fontSize: 24,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w900,
                            fontFamily: AppFonts.palatino,
                          ),
                        ),
                        !productsLoading
                            ? productsToShow.isNotEmpty
                                ? Expanded(
                                    child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                        childAspectRatio: MediaQuery.of(context)
                                                    .orientation ==
                                                Orientation.portrait
                                            ? (1 / 1.65)
                                            : 1 / 1.5,
                                      ),
                                      padding:
                                          const EdgeInsets.only(bottom: 64),
                                      itemCount: productsToShow.length,
                                      itemBuilder: (context, index) {

                                        return ItemCard(
                                          product: productsToShow[index],
                                          addedToCart: () {
                                            loadCart();
                                          },
                                        );
                                      },
                                    ),
                                  )
                                : const Center(
                                    child: Text(
                                      "No Product Found",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: AppFonts.palatino,
                                        fontSize: 18,
                                      ),
                                    ),
                                  )
                            : const Center(
                                child: CircularProgressIndicator(
                                color: Colors.white,
                              ))
                      ],
                    ),
                  )
                : const Center(
                    child: Text(
                      "No product found",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.palatino,
                        fontSize: 18,
                      ),
                    ),
                  )
            : const Center(
                child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              )),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
