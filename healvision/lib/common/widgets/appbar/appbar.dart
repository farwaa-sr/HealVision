import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utilis/constants/colors.dart';
import '../../../utilis/constants/size.dart';
import '../../../utilis/device/device_utility.dart';



class TAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TAppBar(
      {super.key,
      this.title,
      this.showBackArrow = false,
      this.leadingIcon,
      this.action,
      this.leadingOnPressed,
      this.bg, this.padding=EdgeInsets.zero});
  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? action;
  final Color? bg;
  final VoidCallback? leadingOnPressed;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bg,
        leading: showBackArrow
            ? IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(
                  Iconsax.arrow_left,
                  color: WColors.white,
                ),
              )
            : leadingIcon != null
                ? IconButton(
                    onPressed: leadingOnPressed,
                    icon: Icon(
                      leadingIcon,
                    ),
                  )
                : null,
        title: Padding(
          padding: const EdgeInsets.only(left: TSizes.md),
          child: title,
        ),
        actions: action,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());
}
