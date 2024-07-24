import 'package:flutter/material.dart';

import '../../../utilis/constants/colors.dart';
import '../../../utilis/device/device_utility.dart';
import '../../../utilis/helpers/helper_function.dart';


class TTabBar extends StatelessWidget implements PreferredSizeWidget {
  const TTabBar({
    super.key,
    required this.tabs,
  });
  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Material(
      color: dark ? WColors.black : WColors.white,
      child: TabBar(
        tabs: tabs,
        isScrollable: true,
        indicatorColor: WColors.primary,
        unselectedLabelColor: WColors.darkGrey,
        labelColor: dark ? WColors.white : WColors.primary,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());
}
