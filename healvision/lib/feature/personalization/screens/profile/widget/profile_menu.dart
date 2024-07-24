import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utilis/constants/size.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.ontap,
    required this.title,
    required this.value,
    this.icon = Iconsax.arrow_right_34,
  });
  final VoidCallback ontap;
  final String title, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: TSizes.spaceBtwItem / 1.5),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
                child: Icon(
              icon,
              size: 18,
            )),
          ],
        ),
      ),
    );
  }
}
