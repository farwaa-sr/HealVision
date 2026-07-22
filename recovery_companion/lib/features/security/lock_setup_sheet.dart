import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_ext.dart';
import '../../shared/widgets/app_button.dart';
import 'data/app_lock_repository.dart';
import 'providers/security_providers.dart';

/// Set up, change, or turn off the optional app lock. The PIN is stored only as
/// a salted hash; biometrics are offered when the device supports them.
class LockSetupSheet extends ConsumerStatefulWidget {
  const LockSetupSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const LockSetupSheet(),
    );
  }

  @override
  ConsumerState<LockSetupSheet> createState() => _LockSetupSheetState();
}

class _LockSetupSheetState extends ConsumerState<LockSetupSheet> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  bool _useBiometrics = false;
  bool _changing = false;
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  AppLockRepository get _repo => ref.read(appLockRepositoryProvider);

  Future<void> _enableOrChange({required bool alreadyOn}) async {
    final pin = _pin.text.trim();
    final confirm = _confirm.text.trim();
    if (pin.length != 4) {
      setState(() => _error = 'Choose a 4-digit PIN.');
      return;
    }
    if (pin != confirm) {
      setState(() => _error = 'Those PINs don’t match.');
      return;
    }
    if (alreadyOn) {
      await _repo.changePin(pin);
    } else {
      await _repo.enableWithPin(pin, biometrics: _useBiometrics);
    }
    ref.invalidate(appLockConfigProvider);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _turnOff() async {
    await _repo.disable();
    ref.invalidate(appLockConfigProvider);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _toggleBiometrics(bool value) async {
    await _repo.setBiometrics(value);
    ref.invalidate(appLockConfigProvider);
  }

  @override
  Widget build(BuildContext context) {
    final config =
        ref.watch(appLockConfigProvider).valueOrNull ?? AppLockConfig.off;
    final bioAvailable =
        ref.watch(biometricAvailableProvider).valueOrNull ?? false;
    final on = config.enabled && config.hasPin;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(on ? 'App lock' : 'Set up app lock',
                style: context.text.titleLarge,),
            const SizedBox(height: 4),
            Text(
              'A PIN (and biometrics, if you like) to keep this private on a '
              'shared or lost device. Optional, and only on this device.',
              style: context.text.bodySmall
                  ?.copyWith(color: context.palette.muted),
            ),
            const SizedBox(height: 20),

            if (on && !_changing) ...[
              if (bioAvailable)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: config.biometrics,
                  onChanged: _toggleBiometrics,
                  title: const Text('Unlock with biometrics'),
                ),
              AppButton(
                label: 'Change PIN',
                variant: AppButtonVariant.tonal,
                onPressed: () => setState(() => _changing = true),
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Turn off app lock',
                variant: AppButtonVariant.secondary,
                onPressed: _turnOff,
              ),
            ] else ...[
              _PinField(
                controller: _pin,
                hint: on ? 'New 4-digit PIN' : 'Choose a 4-digit PIN',
              ),
              const SizedBox(height: 12),
              _PinField(controller: _confirm, hint: 'Confirm PIN'),
              if (!on && bioAvailable) ...[
                const SizedBox(height: 4),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _useBiometrics,
                  onChanged: (v) => setState(() => _useBiometrics = v),
                  title: const Text('Also allow biometrics'),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: context.text.bodySmall
                        ?.copyWith(color: context.palette.support),),
              ],
              const SizedBox(height: 16),
              AppButton(
                label: on ? 'Save new PIN' : 'Turn on app lock',
                onPressed: () => _enableOrChange(alreadyOn: on),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PinField extends StatelessWidget {
  const _PinField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 4,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(hintText: hint, counterText: ''),
    );
  }
}
