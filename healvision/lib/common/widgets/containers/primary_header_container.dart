import 'package:flutter/material.dart';

import '../../../../utilis/constants/colors.dart';
import '../../custom_shape/containers/circular_container.dart';
import '../../custom_shape/curved_edges/curved_edges_widget.dart';




class TPrimaryHeaderContainer extends StatelessWidget {
  const TPrimaryHeaderContainer({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomCurvedEdgeWidget(
      child: Container(
        color: WColors.primary,
        padding: const EdgeInsets.all(0),
        child: Stack(
          children: [
            Positioned(
              top: -150,
              right: -250,
              child: TCircularContainer(
                backgroundcolor: WColors.textWhite.withOpacity(0.1),
              ),
            ),
            Positioned(
              top: 100,
              right: -300,
              child: TCircularContainer(
                backgroundcolor: WColors.textWhite.withOpacity(0.1),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
