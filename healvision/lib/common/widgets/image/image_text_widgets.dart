import 'package:flutter/material.dart';

import '../../../utilis/constants/colors.dart';
import '../../../utilis/constants/size.dart';
import 't_circular_image.dart';


class VerticalImageText extends StatelessWidget {
  const VerticalImageText({
    super.key,
    required this.image,
    required this.title,
    required this.textColor,
    this.backgroundColor,
    this.onTap,
    this.isNetworkImage = false,
  });
  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final bool isNetworkImage;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: TSizes.spaceBtwItem),
        child: Column(
          children: [
            // Circular icon
            TCircularimage(
              image: image,
              fit: BoxFit.fitWidth,
              isNetwork: isNetworkImage,
              backgroundColor: backgroundColor,
            ),
            const SizedBox(
              height: TSizes.spaceBtwItem / 2,
            ),
            SizedBox(
              width: 55,
              child: Center(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.bold, color: WColors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
