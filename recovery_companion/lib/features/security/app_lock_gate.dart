import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/theme_ext.dart';
import '../crisis/providers/crisis_providers.dart';
import 'providers/security_providers.dart';

/// Wraps the whole app. When app lock is on, it covers the content with a lock
/// screen — on launch and whenever the app goes to the background (which also
/// hides sensitive data from the app switcher). Crisis help stays reachable on
/// the lock screen itself, so the lock never stands between a person and help.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  bool _initialized = false;
  bool _locked = false;
  bool _enabled = false;
  bool _biometricsPref = false;
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_enabled) return;
    if (state == AppLifecycleState.resumed) {
      if (_locked && _biometricsPref && _biometricsAvailable) {
        unawaited(_tryBiometric());
      }
    } else if (!_locked && mounted) {
      // Cover content as we leave the foreground (also blanks the app switcher).
      setState(() => _locked = true);
    }
  }

  Future<void> _tryBiometric() async {
    final ok = await ref.read(biometricAuthProvider).authenticate();
    if (ok && mounted) setState(() => _locked = false);
  }

  Future<bool> _submitPin(String pin) async {
    final ok = await ref.read(appLockRepositoryProvider).verifyPin(pin);
    if (ok && mounted) setState(() => _locked = false);
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appLockConfigProvider).valueOrNull;
    final loading = config == null;
    _enabled = !loading && config.enabled && config.hasPin;
    _biometricsPref = !loading && config.biometrics;

    if (!_initialized && !loading) {
      _initialized = true;
      _locked = _enabled;
      if (_enabled && _biometricsPref) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          _biometricsAvailable =
              await ref.read(biometricAuthProvider).isAvailable();
          if (mounted) {
            setState(() {});
            if (_locked && _biometricsAvailable) unawaited(_tryBiometric());
          }
        });
      }
    }

    return Stack(
      children: [
        widget.child,
        if (loading)
          const Positioned.fill(child: _Splash())
        else if (_enabled && _locked)
          Positioned.fill(
            child: _LockScreen(
              canUseBiometrics: _biometricsPref && _biometricsAvailable,
              onBiometric: _tryBiometric,
              onSubmitPin: _submitPin,
            ),
          ),
      ],
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.surface,
      child: Center(
        child: Icon(Icons.spa, size: 44, color: context.colors.primary),
      ),
    );
  }
}

class _LockScreen extends ConsumerStatefulWidget {
  const _LockScreen({
    required this.canUseBiometrics,
    required this.onBiometric,
    required this.onSubmitPin,
  });

  final bool canUseBiometrics;
  final Future<void> Function() onBiometric;
  final Future<bool> Function(String pin) onSubmitPin;

  @override
  ConsumerState<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<_LockScreen> {
  static const _pinLength = 4;

  String _pin = '';
  bool _error = false;
  bool _showCrisis = false;
  int _attempts = 0;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onDigit(String d) {
    if (_cooldown > 0 || _pin.length >= _pinLength) return;
    setState(() {
      _error = false;
      _pin += d;
    });
    if (_pin.length == _pinLength) _verify();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _verify() async {
    final ok = await widget.onSubmitPin(_pin);
    if (ok || !mounted) return;
    _attempts++;
    setState(() {
      _error = true;
      _pin = '';
    });
    if (_attempts >= 5) _startCooldown();
  }

  void _startCooldown() {
    setState(() => _cooldown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _cooldown--);
      if (_cooldown <= 0) {
        t.cancel();
        _attempts = 0;
      }
    });
  }

  Future<void> _dial(Uri uri) async {
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final region = ref.watch(crisisRegionProvider);
    return Material(
      color: context.colors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.lock_outline, size: 40, color: context.colors.primary),
              const SizedBox(height: 16),
              Text('Welcome back', style: context.text.headlineSmall),
              const SizedBox(height: 6),
              Text(
                _cooldown > 0
                    ? 'Too many attempts — try again in $_cooldown s'
                    : 'Enter your PIN to continue',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.palette.muted),
              ),
              const SizedBox(height: 28),
              _PinDots(length: _pinLength, filled: _pin.length, error: _error),
              const SizedBox(height: 28),
              _Keypad(onDigit: _onDigit, onBackspace: _onBackspace),
              if (widget.canUseBiometrics) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: widget.onBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Use biometrics'),
                ),
              ],
              const Spacer(),
              // Crisis help — always reachable, even locked.
              TextButton.icon(
                onPressed: () => setState(() => _showCrisis = !_showCrisis),
                icon: Icon(Icons.favorite, color: context.palette.support),
                label: const Text('In crisis? Get help now'),
              ),
              if (_showCrisis)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      for (final r in region.resources)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(r.name,
                                    style: context.text.bodyMedium,),
                              ),
                              if (r.call != null)
                                TextButton(
                                  onPressed: () =>
                                      _dial(Uri(scheme: 'tel', path: r.call)),
                                  child: const Text('Call'),
                                ),
                              if (r.text != null)
                                TextButton(
                                  onPressed: () =>
                                      _dial(Uri(scheme: 'sms', path: r.text)),
                                  child: const Text('Text'),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.length,
    required this.filled,
    required this.error,
  });

  final int length;
  final int filled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final color = error ? context.palette.support : context.colors.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < length; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled ? color : Colors.transparent,
              border: Border.all(color: color, width: 1.6),
            ),
          ),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget key(String label, {VoidCallback? onTap, Widget? child}) {
      return Semantics(
        button: true,
        label: child == null ? label : 'delete',
        child: InkResponse(
          onTap: onTap ?? () => onDigit(label),
          radius: 40,
          child: SizedBox(
            width: 72,
            height: 64,
            child: Center(
              child: child ??
                  Text(label, style: context.text.headlineSmall),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (final d in row) key(d)],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 72),
            key('0'),
            key(
              'backspace',
              onTap: onBackspace,
              child: const Icon(Icons.backspace_outlined),
            ),
          ],
        ),
      ],
    );
  }
}
