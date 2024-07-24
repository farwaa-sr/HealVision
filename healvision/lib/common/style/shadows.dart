import 'package:flutter/material.dart';

import '../../utilis/constants/colors.dart';

class Tshadowstyle {
  static final verticalProductShadow = BoxShadow(
    color: WColors.darkGrey.withOpacity(0.1),
    blurRadius: 50,
    spreadRadius: 7,
    offset: const Offset(0, 2),
  );

  static final horizontalProductShadow = BoxShadow(
    color: WColors.darkGrey.withOpacity(0.1),
    blurRadius: 50,
    spreadRadius: 7,
    offset: const Offset(0, 2),
  );
}
