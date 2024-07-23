import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:yeotaskin/models/product_model.dart';
import 'package:yeotaskin/utilities/cart.dart';

import '../../../utilities/app_colors.dart';
import '../../../utilities/app_fonts.dart';
import '../../../utilities/image_utils.dart';
import '../../../utilities/price_converter.dart';
import '../../../widgets/custom_image.dart';

class OrderHistoryCard extends StatefulWidget {
  final ProductModel cartProduct;
  const OrderHistoryCard(
      {super.key,
        required this.cartProduct,});

  @override
  State<OrderHistoryCard> createState() => _OrderHistoryCardState();
}

class _OrderHistoryCardState extends State<OrderHistoryCard> {

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: mq.height * .25,
            width: mq.width * 0.36,
            decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(100)),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CustomImage(
                  image: widget.cartProduct.productImage!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: Images.placeholder,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: mq.width * 0.42,
                  child: Text(
                    widget.cartProduct.productName!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    softWrap: true,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        PriceUtility.priceWithSymbol(widget.cartProduct.price!),
                        style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "${widget.cartProduct.quantity} gm",
                        style: const TextStyle(
                            color: Colors.black26,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}
