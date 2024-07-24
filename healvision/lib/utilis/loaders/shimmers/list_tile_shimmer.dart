import 'package:flutter/material.dart';

import '../../constants/size.dart';
import 'shimmer.dart';

class TListTileShimmer extends StatelessWidget {
  const TListTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            TShimmerEffect(width: 50, height: 50,radius: 50,),
            SizedBox(width: TSizes.spaceBtwItem,),
            Column(
              children: [
                TShimmerEffect(width: 100, height: 55),
                 SizedBox(height: TSizes.spaceBtwItem /2),
                 TShimmerEffect(width: 80, height: 12)
              ],
            )
          ],
        )
      ],
    );
  }
}
