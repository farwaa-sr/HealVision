import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the user has finished onboarding. Initialized in `main()` (from
/// secure storage) via an override, then flipped when onboarding completes —
/// the router watches this to decide the first screen.
final onboardingDoneProvider = StateProvider<bool>((ref) => true);

/// Secure-storage key backing [onboardingDoneProvider].
const kOnboardingDoneKey = 'onboarding.done';
