import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class TChipTheme {
  TChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: WColors.grey.withOpacity(0.4),
    labelStyle: const TextStyle(color: WColors.black),
    selectedColor: WColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: WColors.white,
  );

  static ChipThemeData darkChipTheme = const ChipThemeData(
    disabledColor: WColors.darkerGrey,
    labelStyle: TextStyle(color: WColors.white),
    selectedColor: WColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: WColors.white,
  );
}
