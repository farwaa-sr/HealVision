import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import 'shimmer.dart';


class WoundShimer extends StatelessWidget {
  const WoundShimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ListView.separated(
          itemCount: 6,
          separatorBuilder: (__, _) => const SizedBox(
                height: 20,
              ),
          itemBuilder: (context, index) {
            return Container(
              width: double.infinity,
              height: 70,
              decoration: const BoxDecoration(
                  color: WColors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(22))),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  TShimmerEffect(width: 80, height: 50),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TShimmerEffect(width: 130, height: 15),
                      SizedBox(
                        height: 5,
                      ),
                      TShimmerEffect(width: 80, height: 15),
                    ],
                  )
                ],
              ),
            );
          }),
    );
  }
}
