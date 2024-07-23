import 'package:flutter/material.dart';
import 'package:yeotaskin/models/product_model.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/utilities/cart.dart';
import 'package:yeotaskin/utilities/utilities.dart';

import '../../../utilities/app_colors.dart';
import '../../../utilities/image_utils.dart';
import '../../../utilities/price_converter.dart';
import '../../../utilities/snackbar_utils.dart';
import '../../../widgets/custom_image.dart';

class CartItemCard extends StatefulWidget {
  final int index;
  final ProductModel cartProduct;
  final Cart cart;
  final Function buttonPressed;
  final String type;
  const CartItemCard({
    super.key,
    required this.cartProduct,
    required this.index,
    required this.cart,
    required this.buttonPressed,
    required this.type,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(20)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomImage(
                    image: widget.cartProduct.productImage!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: Images.placeholder,
                  )),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.cartProduct.productName!.toTitleCase(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      softWrap: true,
                      style: const TextStyle(
                        fontFamily: AppFonts.arial,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${widget.cartProduct.weight ?? 0} gm",
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: AppFonts.arial,
                        fontWeight: FontWeight.bold,
                        color: AppColors.twoLevelColor,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Text(
                                PriceUtility.priceWithSymbol(
                                    widget.cartProduct.price!),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: AppFonts.arial,
                                  color: AppColors.topLevelColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            ],
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(100),
                              onTap: widget.type == "cart"
                                  ? () {
                                      widget.cart.removeQuantity(widget.index);
                                      widget.buttonPressed();
                                    }
                                  : null,
                              child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryColor),
                                  child: const Align(
                                      alignment: Alignment.topCenter,
                                      child: Icon(Icons.minimize))),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: 45,
                              child: Text(
                                widget.cartProduct.productCount.toString(),
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(100),
                              onTap: widget.type == "cart"
                                  ? () {
                                widget.cart.addQuantity(widget.index);
                                widget.buttonPressed();

                                    }
                                  : null,
                              child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryColor),
                                  child: const Icon(Icons.add)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              child: const Icon(Icons.more_vert),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: '0',
                  onTap: widget.type == "cart"
                      ? () {
                          widget.cart.removeFromCart(widget.index);
                          Future.delayed(
                            const Duration(milliseconds: 500),
                            () {
                              widget.buttonPressed();
                            },
                          );
                        }
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.red.shade600,
                      ),
                      const Text(
                        'Remove From Cart',
                        style: TextStyle(
                          fontFamily: AppFonts.arial,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
