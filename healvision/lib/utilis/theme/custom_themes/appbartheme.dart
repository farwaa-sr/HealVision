import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/size.dart';

class TAppBarTheme {
  TAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: WColors.black,
      size: TSizes.iconMd,
    ),
    actionsIconTheme: IconThemeData(
      color: WColors.black,
      size: TSizes.iconMd,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: WColors.black,
    ),
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: WColors.black,
      size: TSizes.iconMd,
    ),
    actionsIconTheme: IconThemeData(
      color: WColors.white,
      size: TSizes.iconMd,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: WColors.white,
    ),
  );
}
