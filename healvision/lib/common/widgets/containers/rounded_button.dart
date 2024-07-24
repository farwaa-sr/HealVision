import 'package:flutter/material.dart';

import '../../../utilis/constants/colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.btnname,
    required this.icons,
    required this.onpressed,
    this.iconsize=28,
    this.fontsize=14
  });
  final String btnname;
  final double iconsize,fontsize;
  final IconData icons;
  final VoidCallback onpressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icons,
              size: iconsize,
              color: WColors.white,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(textAlign: TextAlign.center, btnname,style: TextStyle(fontSize: fontsize,color: WColors.white),)
          ],
        ),
      ),
    );
  }
}
