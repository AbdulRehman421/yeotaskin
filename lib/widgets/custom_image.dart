import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utilities/image_utils.dart';

class CustomImage extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final String? placeholder;
  final Color? color;
  const CustomImage({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit,
    this.placeholder,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    String secureImage = image;
    if (image.startsWith("http:")) {
      secureImage = image.replaceFirst("http:", "https:");
    }
    return FadeInImage(
      placeholder:
          AssetImage(placeholder != null ? placeholder! : Images.placeholder),
      image: CachedNetworkImageProvider(secureImage),
      height: height,
      width: width,
      fit: fit,
      imageErrorBuilder: (context, error, stackTrace) {
        return Image.asset(
          placeholder != null ? placeholder! : Images.placeholder,
          height: height,
          width: width,
          fit: fit,
        );
      },
    );
  }
}
