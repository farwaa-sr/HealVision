import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../utilis/constants/size.dart';
import '../../../utilis/constants/text_string.dart';
import '../../../utilis/helpers/helper_function.dart';
import '../../style/spacing_style.dart';


class SuccessScreen extends StatelessWidget {
  const SuccessScreen(
      {super.key,
      required this.image,
      required this.title,
      required this.subtitile,
      required this.onpressed});
  final String image, title, subtitile;
  final VoidCallback onpressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              Lottie.asset(
                image,
                width: THelperFunctions.screenWidth() * 0.6,
              ),
              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),
              // Title & subTitle
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: TSizes.spaceBtwItem,
              ),
              Text(
                subtitile,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),

              //  Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onpressed,
                  child: const Text(WTexts.tContinue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
