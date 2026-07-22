import 'package:flutter/widgets.dart';

/// The app's root navigator. Shared so the always-on crisis help button (which
/// lives above the router in an overlay) can open modal sheets on it from any
/// screen — even the lock screen.
final rootNavigatorKey = GlobalKey<NavigatorState>();
