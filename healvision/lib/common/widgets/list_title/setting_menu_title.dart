import 'package:flutter/material.dart';

import '../../../utilis/constants/colors.dart';
import '../../../utilis/helpers/helper_function.dart';

class TSettingMenuTitle extends StatelessWidget {
  const TSettingMenuTitle(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      this.trailing,
      this.onpressed});
  final IconData icon;
  final String title, subtitle;
  final Widget? trailing;
  final VoidCallback? onpressed;

  @override
  Widget build(BuildContext context) {
    final drak = THelperFunctions.isDarkMode(context);
    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: drak ? WColors.white : WColors.primary,
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
      trailing: trailing,
      onTap: onpressed,
    );
  }
}
