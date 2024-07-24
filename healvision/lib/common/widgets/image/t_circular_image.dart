import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../utilis/constants/colors.dart';
import '../../../utilis/constants/size.dart';
import '../../../utilis/helpers/helper_function.dart';
import '../../../utilis/loaders/shimmers/shimmer.dart';


class TCircularimage extends StatelessWidget {
  const TCircularimage({
    super.key,
    this.fit = BoxFit.cover,
    required this.image,
    this.isNetwork = false,
    this.overLayColor,
    this.backgroundColor,
    this.width = 56,
    this.height = 56,
    this.padding = TSizes.sm, this.radius = 100,
  });
  final BoxFit? fit;
  final String image;
  final bool isNetwork;
  final Color? overLayColor, backgroundColor;
  final double width, height, padding,radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (THelperFunctions.isDarkMode(context)
                ? WColors.black
                : WColors.white),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Center(
          child: isNetwork
              ? CachedNetworkImage(
                  imageUrl: image,
                  fit: fit,
                  color: overLayColor,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      const TShimmerEffect(width: 55, height: 55),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : Image(
                  fit: fit,
                  image: AssetImage(image),
                  color: overLayColor,
                ),
        ),
      ),
    );
  }
}
