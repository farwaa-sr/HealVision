import 'package:flutter/foundation.dart';

/// A recurring time that tends to be harder for this person, derived on-device
/// from their own check-ins. Used to time a *supportive* nudge just before it —
/// never a warning, just a warm "your tools are here" at a useful moment.
@immutable
class RiskWindow {
  const RiskWindow({required this.hour, this.weekday});

  /// Hour of day (0–23) the harder stretch tends to begin.
  final int hour;

  /// 1 = Monday … 7 = Sunday, or null when the pattern holds every day.
  final int? weekday;

  bool appliesTo(DateTime day) => weekday == null || day.weekday == weekday;
}
