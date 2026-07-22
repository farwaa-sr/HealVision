import 'package:flutter/material.dart';

/// What the substance did *for* the user — used to personalize suggestions.
enum Need {
  energy('Gave me energy or a lift', Icons.bolt),
  calm('Helped me relax or take the edge off', Icons.spa_outlined),
  social('Made socialising easier', Icons.people_outline),
  boredom('Filled time or eased boredom', Icons.hourglass_empty),
  numbing('Numbed pain or hard feelings', Icons.healing_outlined);

  const Need(this.question, this.icon);
  final String question;
  final IconData icon;

  static Need? fromName(String name) {
    for (final n in Need.values) {
      if (n.name == name) return n;
    }
    return null;
  }
}

/// The kind of activity, for browsing the library.
enum ActivityCategory {
  physical('Physical', Icons.directions_run),
  social('Social', Icons.groups_outlined),
  creative('Creative', Icons.palette_outlined),
  mindfulness('Mindfulness', Icons.self_improvement),
  productive('Productive', Icons.checklist_rtl),
  selfCare('Self-care', Icons.favorite_outline),
  nature('Nature', Icons.park_outlined),
  connection('Connection', Icons.forum_outlined);

  const ActivityCategory(this.label, this.icon);
  final String label;
  final IconData icon;

  static ActivityCategory fromName(String name) {
    for (final c in ActivityCategory.values) {
      if (c.name == name) return c;
    }
    return ActivityCategory.selfCare;
  }
}

/// Helpers to (de)serialize a set of needs as a CSV string for storage.
String needsToCsv(Iterable<Need> needs) => needs.map((n) => n.name).join(',');

List<Need> needsFromCsv(String? csv) {
  if (csv == null || csv.isEmpty) return const [];
  return csv
      .split(',')
      .map(Need.fromName)
      .whereType<Need>()
      .toList();
}
