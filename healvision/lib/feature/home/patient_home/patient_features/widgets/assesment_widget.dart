import 'package:flutter/material.dart';

import '../../../../../utilis/constants/colors.dart';
import '../../../../../utilis/constants/size.dart';
import '../view_appointment.dart';

class CustomNextButton extends StatelessWidget {
  const CustomNextButton({
    super.key,
    required this.onpressed,
    this.alignment = Alignment.bottomRight,
  });
  final VoidCallback onpressed;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ElevatedButton(
        onPressed: onpressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(side: BorderSide(style: BorderStyle.none)),
          backgroundColor: WColors.primary,
        ),
        child: const Icon(
          Icons.arrow_forward_ios,
          color: WColors.white,
        ),
      ),
    );
  }
}

class CustomCountContainer extends StatelessWidget {
  const CustomCountContainer({
    super.key,
    required this.pagenumber,
    this.endingpage = '10',
  });
  final String pagenumber;
  final String endingpage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 40,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(22)),
        color: WColors.customcontainer,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            '$pagenumber of $endingpage',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: WColors.textpri,
            ),
          ),
        ),
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  const OptionButton({
    super.key,
    required this.title,
    this.align = Alignment.bottomLeft,
    this.isSelected = false,
    required this.onPressed,
  });

  final String title;
  final Alignment align;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: align,
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: isSelected ? WColors.primary : WColors.light,
                borderRadius: const BorderRadius.all(Radius.circular(50)),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: CustomTextLabel(
                    textalign: TextAlign.center,
                    label: title,
                    fontweight: FontWeight.w400,
                    textcolor: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}


class CustomButtonNext extends StatelessWidget {
  const CustomButtonNext({
    super.key,
    required this.title,
    required this.onpressed,
    this.visble = true,
  });
  final String title;
  final VoidCallback onpressed;
  final bool visble;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: WColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
             if (visble) ...[
              const SizedBox(width: 20),
              const Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
