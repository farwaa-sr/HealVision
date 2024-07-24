import 'package:flutter/material.dart';

import '../../constants/size.dart';
import 'shimmer.dart';

class TBoxesShimer extends StatelessWidget {
  const TBoxesShimer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(child: TShimmerEffect(width: 150, height: 110)),
            SizedBox(
              width: TSizes.spaceBtwItem,
            ),
            Expanded(child: TShimmerEffect(width: 150, height: 110)),
            SizedBox(
              width: TSizes.spaceBtwItem,
            ),
            Expanded(child: TShimmerEffect(width: 150, height: 110)),
          ],
        )
      ],
    );
  }
}
