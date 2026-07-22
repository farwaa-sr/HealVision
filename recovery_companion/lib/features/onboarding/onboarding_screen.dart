import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/secure_store_provider.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/theme_ext.dart';
import '../../shared/widgets/app_button.dart';
import 'onboarding_providers.dart';

/// A short, warm first-run flow. Sets the tone, is honest about what the app is
/// and isn't (a companion alongside professional care — never a replacement),
/// and reassures on privacy and always-available help.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardPage(
      icon: Icons.spa_outlined,
      title: 'You’re here. That matters.',
      body:
          'This is a calm, private space to support your recovery — one day, '
          'one moment at a time. However today is going, you’re welcome exactly '
          'as you are.',
    ),
    _OnboardPage(
      icon: Icons.volunteer_activism_outlined,
      title: 'A companion, not a replacement',
      body:
          'This app walks alongside professional treatment, meetings and '
          'groups, and the people who care about you — it doesn’t replace them. '
          'It’s not a therapist, doctor, or crisis service, and it won’t '
          'pretend to be.',
    ),
    _OnboardPage(
      icon: Icons.lock_outline,
      title: 'Private by design',
      body:
          'Your data stays on your device, encrypted. No accounts, no tracking, '
          'nothing sold or shared. You can add an app lock, and export or delete '
          'everything whenever you want.',
    ),
    _OnboardPage(
      icon: Icons.favorite,
      title: 'Help is always a tap away',
      body:
          'Crisis resources — like 988 — are reachable from every screen, any '
          'time. You can also save your own people to reach in one tap. You '
          'never have to do the hard moments alone.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(secureStoreProvider).write(kOnboardingDoneKey, 'true');
    ref.read(onboardingDoneProvider.notifier).state = true;
    if (mounted) context.goNamed(AppRoute.dashboard.routeName);
  }

  void _next() {
    if (_page == _pages.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(isLast ? '' : 'Skip'),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: _pages,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? context.colors.primary
                          : context.palette.ringTrack,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: AppButton(
                label: isLast ? 'Get started' : 'Next',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.primaryContainer,
            ),
            child: Icon(icon, size: 46, color: context.colors.primary),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.text.headlineSmall,
          ),
          const SizedBox(height: 14),
          Text(
            body,
            textAlign: TextAlign.center,
            style: context.text.bodyLarge?.copyWith(
              color: context.palette.muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
