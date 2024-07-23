import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/utilities/cart.dart';
import 'package:yeotaskin/utilities/price_converter.dart';

import '../../../models/product_model.dart';
import '../../../utilities/image_utils.dart';
import '../../../utilities/snackbar_utils.dart';
import '../../../widgets/custom_image.dart';

class ItemCard extends StatefulWidget {
  final ProductModel? product;
  final Function addedToCart;
  const ItemCard({
    super.key,
    required this.product,
    required this.addedToCart,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    const double padding = 16.0;
    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmAddToCard(
              product: widget.product,
              addedToCart: widget.addedToCart,
            );
          },
        );
      },
      child: Card(
        shadowColor: AppColors.background,
        elevation: 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: CustomImage(
                  image: widget.product!.productImage!,
                  width: size.width * 0.46,
                  height: size.height * 0.32,
                  fit: BoxFit.cover,
                  placeholder: Images.placeholder,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(padding / 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 10),
                      blurRadius: 50,
                      color: AppColors.accent.withOpacity(0.23),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "${widget.product!.productName!}\n".toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              overflow: TextOverflow.ellipsis,
                            ),
                        maxLines: 3,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              "${widget.product!.weight ?? 0} gm",
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: AppFonts.arial,
                                fontWeight: FontWeight.bold,
                                color: AppColors.twoLevelColor,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              PriceUtility.priceWithSymbol(
                                  widget.product!.price!),
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: AppFonts.arial,
                                fontWeight: FontWeight.bold,
                                color: AppColors.topLevelColor,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmAddToCard extends StatefulWidget {
  final ProductModel? product;
  final Function addedToCart;
  const ConfirmAddToCard({
    super.key,
    required this.product,
    required this.addedToCart,
  });

  @override
  State<ConfirmAddToCard> createState() => _ConfirmAddToCardState();
}

class _ConfirmAddToCardState extends State<ConfirmAddToCard> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      width: size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: CustomImage(
                  image: widget.product!.productImage!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                  placeholder: Images.placeholder,
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product!.productName!.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: AppFonts.arial,
                          fontSize: 18,
                          color: AppColors.topLevelColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                      Text(
                        "${widget.product!.weight!} gm",
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: AppFonts.arial,
                          color: AppColors.twoLevelColor,
                        ),
                      ),
                      Text(
                        PriceUtility.priceWithSymbol(widget.product!.price!),
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.accent,
                          fontFamily: AppFonts.arial,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity: ',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.accent,
                        fontFamily: AppFonts.palatino,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      color: AppColors.accent,
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                    ),
                    Container(
                      width: 60,
                      height: 40,
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Text(
                        quantity.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      color: AppColors.accent,
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.shopping_cart,
                  color: AppColors.primaryColor,
                  size: 30,
                ),
                label: const Text(
                  'Add to cart',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.optima,
                  ),
                ),
                style: const ButtonStyle(
                  padding: MaterialStatePropertyAll(
                    EdgeInsets.fromLTRB(32, 12, 32, 12),
                  ),
                ),
                onPressed: () {
                  if(widget.product!.quantity! - quantity < 0){
                    Navigator.pop(context);
                    SnackBarUtils.show(title: "Product out of stock", isError: true);
                  }else{

                    Cart().addToCart(widget.product!, quantity);
                    widget.addedToCart();
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
