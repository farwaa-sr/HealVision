import 'package:flutter/material.dart';

import '../../../core/routing/navigator_keys.dart';
import '../../../core/theme/theme_ext.dart';
import 'crisis_resources_sheet.dart';

/// The persistent, always-reachable crisis affordance. Rendered once in an
/// overlay above the whole app (see `main.dart`), so it's available on every
/// screen — including the lock screen, so app lock never stands between a
/// person and help.
///
/// Calm on purpose: a small, discreet button (not an alarming red banner) that
/// stays findable in the same spot everywhere.
class CrisisHelpButton extends StatelessWidget {
  const CrisisHelpButton({super.key});

  void _open() {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null) CrisisResourcesSheet.show(ctx);
  }

  @override
  Widget build(BuildContext context) {
    final support = context.palette.support;
    return SafeArea(
      minimum: const EdgeInsets.only(left: 12, bottom: 84),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Semantics(
          button: true,
          label: 'Get crisis help — call or text a crisis line',
          child: Material(
            color: context.palette.surfaceElevated,
            shape: CircleBorder(
              side: BorderSide(color: support.withValues(alpha: 0.55)),
            ),
            elevation: 3,
            shadowColor: Colors.black.withValues(alpha: 0.2),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _open,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.health_and_safety, color: support),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
