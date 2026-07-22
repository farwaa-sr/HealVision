import 'package:flutter/material.dart';

/// A single crisis resource — a hotline or emergency number the user can reach
/// in one tap. [call]/[text] hold bare digits suitable for `tel:` / `sms:`.
@immutable
class CrisisResource {
  const CrisisResource({
    required this.name,
    required this.subtitle,
    required this.icon,
    this.call,
    this.text,
    this.emphasized = false,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final String? call;
  final String? text;

  /// The primary line for this region — rendered most prominently.
  final bool emphasized;
}

/// The resources to show for a region, plus whether we fell back to US defaults.
@immutable
class CrisisRegion {
  const CrisisRegion({
    required this.label,
    required this.resources,
    required this.isFallback,
  });

  final String label;
  final List<CrisisResource> resources;

  /// True when we didn't have specific data for the user's country and are
  /// showing US resources — the UI says so plainly and invites a local line.
  final bool isFallback;
}

const _us = [
  CrisisResource(
    name: '988 Suicide & Crisis Lifeline',
    subtitle: 'Free, confidential, 24/7 — call or text',
    icon: Icons.favorite,
    call: '988',
    text: '988',
    emphasized: true,
  ),
  CrisisResource(
    name: '911',
    subtitle: 'If you or someone else is in immediate danger',
    icon: Icons.emergency_outlined,
    call: '911',
  ),
  CrisisResource(
    name: 'SAMHSA National Helpline',
    subtitle: 'Free, confidential help for substance use — 24/7',
    icon: Icons.support_agent_outlined,
    call: '18006624357',
  ),
];

const _canada = [
  CrisisResource(
    name: '988 Suicide Crisis Helpline',
    subtitle: 'Free, 24/7 — call or text',
    icon: Icons.favorite,
    call: '988',
    text: '988',
    emphasized: true,
  ),
  CrisisResource(
    name: '911',
    subtitle: 'For an emergency or immediate danger',
    icon: Icons.emergency_outlined,
    call: '911',
  ),
];

const _uk = [
  CrisisResource(
    name: 'Samaritans',
    subtitle: 'Free, 24/7, any kind of distress — call 116 123',
    icon: Icons.favorite,
    call: '116123',
    emphasized: true,
  ),
  CrisisResource(
    name: 'Shout',
    subtitle: 'Text SHOUT to 85258 for 24/7 crisis text support',
    icon: Icons.sms_outlined,
    text: '85258',
  ),
  CrisisResource(
    name: '999',
    subtitle: 'For an emergency or immediate danger',
    icon: Icons.emergency_outlined,
    call: '999',
  ),
];

const _australia = [
  CrisisResource(
    name: 'Lifeline',
    subtitle: 'Free, 24/7 crisis support — call 13 11 14',
    icon: Icons.favorite,
    call: '131114',
    text: '0477131114',
    emphasized: true,
  ),
  CrisisResource(
    name: 'Beyond Blue',
    subtitle: 'Support for anxiety, depression — call 1300 22 4636',
    icon: Icons.support_agent_outlined,
    call: '1300224636',
  ),
  CrisisResource(
    name: '000',
    subtitle: 'For an emergency or immediate danger',
    icon: Icons.emergency_outlined,
    call: '000',
  ),
];

const _ireland = [
  CrisisResource(
    name: 'Samaritans',
    subtitle: 'Free, 24/7 — call 116 123',
    icon: Icons.favorite,
    call: '116123',
    emphasized: true,
  ),
  CrisisResource(
    name: '112',
    subtitle: 'For an emergency or immediate danger',
    icon: Icons.emergency_outlined,
    call: '112',
  ),
];

const _byCountry = <String, ({String label, List<CrisisResource> resources})>{
  'US': (label: 'United States', resources: _us),
  'CA': (label: 'Canada', resources: _canada),
  'GB': (label: 'United Kingdom', resources: _uk),
  'AU': (label: 'Australia', resources: _australia),
  'IE': (label: 'Ireland', resources: _ireland),
};

/// Picks the best resources for [countryCode] (an ISO code like `US`), falling
/// back to US resources — clearly labelled — when we don't have a region match.
CrisisRegion crisisRegionFor(String? countryCode) {
  final cc = countryCode?.toUpperCase();
  final match = cc == null ? null : _byCountry[cc];
  if (match != null) {
    return CrisisRegion(
      label: match.label,
      resources: match.resources,
      isFallback: false,
    );
  }
  return const CrisisRegion(
    label: 'United States',
    resources: _us,
    isFallback: true,
  );
}
