import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../feature/authentication/controllers/login/login_controller.dart';
import '../../../utilis/constants/colors.dart';
import '../../../utilis/constants/image_strings.dart';
import '../../../utilis/constants/size.dart';



class TSocialButtons extends StatelessWidget {
  const TSocialButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: WColors.grey),
              borderRadius: BorderRadius.circular(100)),
          child: IconButton(
            onPressed: () {
              controller.googleSignIn();
            },
            icon: const Image(
              width: TSizes.iconMd,
              height: TSizes.iconMd,
              image: AssetImage(WImages.google),
            ),
          ),
        ),
        const SizedBox(
          width: TSizes.spaceBtwItem,
        ),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: WColors.grey),
              borderRadius: BorderRadius.circular(100)),
          child: IconButton(
            onPressed: () {},
            icon: const Image(
              width: TSizes.iconMd,
              height: TSizes.iconMd,
              image: AssetImage(WImages.facebook),
            ),
          ),
        ),
      ],
    );
  }
}
