import 'package:flutter/widgets.dart';

import 'curved_edges.dart';

class CustomCurvedEdgeWidget extends StatelessWidget {
  const CustomCurvedEdgeWidget({
    super.key,
    this.child,
  });
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TCustomCurvedEdges(),
      child: child,
    );
  }
}
