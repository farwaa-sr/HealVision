import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/colors.dart';
import '../../helpers/helper_function.dart';

class TShimmerEffect extends StatelessWidget {
  const TShimmerEffect(
      {super.key,
      required this.width,
      required this.height,
      this.radius = 15,
      this.color});
  final double width, height, radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Shimmer.fromColors(
      baseColor: dark ? Colors.grey.shade600 : Colors.grey.shade300,
      highlightColor: dark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? (dark ? WColors.darkerGrey : WColors.white),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
