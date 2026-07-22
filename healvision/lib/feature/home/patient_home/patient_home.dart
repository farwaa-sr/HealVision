import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/widgets/containers/primary_header_container.dart';
import '../../../utilis/constants/colors.dart';
import '../../../utilis/constants/size.dart';
import '../../personalization/screens/setting/settings.dart';
import '../../recovery/controllers/recovery_controller.dart';
import '../../recovery/models/mood_log.dart';
import 'p_home_app_bar.dart';
import 'patient_features/assesment_screens/assesment_intro_screen.dart';
import 'patient_features/chat_bot/chat_bot_screen.dart';

class PatientHome extends StatelessWidget {
  const PatientHome({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecoveryController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: WColors.primary,
        title: Text(
          'My Recovery',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.to(const SettingScreen()),
            icon: const Icon(Icons.settings, size: 28, color: WColors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const TPrimaryHeaderContainer(child: PatientHomeAppBar()),
              Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StreakCard(controller: controller),
                    const SizedBox(height: TSizes.spaceBtwItem),
                    _MotivationCard(controller: controller),
                    const SizedBox(height: TSizes.spaceBtwItem),
                    _MoodCard(controller: controller),
                    const SizedBox(height: TSizes.spaceBtwItem),
                    _AssessmentTrendCard(controller: controller),
                    const SizedBox(height: TSizes.spaceBtwSections),
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

/// Reusable rounded card wrapper.
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StreakCard extends StatelessWidget {
  final RecoveryController controller;
  const _StreakCard({required this.controller});

  String _milestone(int days) {
    if (days >= 365) return 'One year strong 🎉';
    if (days >= 90) return '90+ days — incredible';
    if (days >= 30) return 'Over a month clean';
    if (days >= 7) return 'One week down';
    if (days >= 1) return 'Every day counts';
    return 'Set your quit date to begin';
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.profile.value.quitDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) controller.setQuitDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final days = controller.streakDays;
      final hasDate = controller.profile.value.quitDate != null;
      return _Card(
        child: Column(
          children: [
            Text('Days Free',
                style: GoogleFonts.outfit(
                    fontSize: 16, color: WColors.textSecondary)),
            const SizedBox(height: 6),
            Text('$days',
                style: GoogleFonts.outfit(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: WColors.primary)),
            Text(_milestone(days),
                style: GoogleFonts.outfit(
                    fontSize: 14, color: WColors.textPrimary)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pickDate(context),
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(hasDate ? 'Change quit date' : 'Set quit date'),
            ),
          ],
        ),
      );
    });
  }
}

class _MotivationCard extends StatelessWidget {
  final RecoveryController controller;
  const _MotivationCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: WColors.primary),
              const SizedBox(width: 8),
              Text('Today\'s Encouragement',
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Obx(() => controller.loadingMotivation.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                      onPressed: controller.fetchMotivation,
                      icon: const Icon(Icons.refresh, size: 20),
                    )),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                controller.motivation.value.isEmpty
                    ? 'Loading a little encouragement…'
                    : controller.motivation.value,
                style: GoogleFonts.outfit(
                    fontSize: 15, color: WColors.textPrimary, height: 1.4),
              )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.to(const ChatBotScreen()),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Talk it through'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final RecoveryController controller;
  const _MoodCard({required this.controller});

  static const moods = ['Great', 'Okay', 'Low', 'Struggling'];

  void _openLogSheet(BuildContext context) {
    String selected = 'Okay';
    double craving = 0;
    final noteCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How are you feeling?',
                  style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: moods
                    .map((m) => ChoiceChip(
                          label: Text(m),
                          selected: selected == m,
                          selectedColor: WColors.primary.withOpacity(0.2),
                          onSelected: (_) => setState(() => selected = m),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text('Craving level: ${craving.round()}/10',
                  style: GoogleFonts.outfit(fontSize: 15)),
              Slider(
                value: craving,
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: WColors.primary,
                label: craving.round().toString(),
                onChanged: (v) => setState(() => craving = v),
              ),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  hintText: 'Add a note (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.logMood(
                        selected, craving.round(), noteCtrl.text.trim());
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Save check-in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Mood & Cravings',
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _openLogSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Log'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Obx(() {
            if (controller.moods.isEmpty) {
              return Text('No check-ins yet. Tap "Log" to record how you feel.',
                  style: GoogleFonts.outfit(
                      fontSize: 14, color: WColors.textSecondary));
            }
            return Column(
              children: controller.moods
                  .take(5)
                  .map((m) => _MoodRow(log: m))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _MoodRow extends StatelessWidget {
  final MoodLog log;
  const _MoodRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final d = log.createdAt;
    final date = '${d.day}/${d.month}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 4,
            backgroundColor:
                log.craving >= 7 ? WColors.error : WColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${log.mood} · craving ${log.craving}/10'
              '${log.note.isNotEmpty ? ' — ${log.note}' : ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(fontSize: 14),
            ),
          ),
          Text(date,
              style: GoogleFonts.outfit(
                  fontSize: 12, color: WColors.textSecondary)),
        ],
      ),
    );
  }
}

class _AssessmentTrendCard extends StatelessWidget {
  final RecoveryController controller;
  const _AssessmentTrendCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Assessment Trend',
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(
                onPressed: () => Get.to(const AssesmentIntroScreen()),
                child: const Text('Take again'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final history = controller.scoreHistory;
            if (history.isEmpty) {
              return Text(
                  'Take the self-assessment to start tracking your progress.',
                  style: GoogleFonts.outfit(
                      fontSize: 14, color: WColors.textSecondary));
            }
            final scores =
                history.map((e) => (e['score'] as int)).toList();
            final maxScore =
                scores.reduce((a, b) => a > b ? a : b).clamp(1, 100);
            final latest = scores.last;
            final trendDown = scores.length >= 2 && latest < scores[scores.length - 2];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: scores
                      .map((s) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 8 + (s / maxScore) * 60,
                              decoration: BoxDecoration(
                                color: WColors.primary.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('Latest: $latest',
                        style: GoogleFonts.outfit(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Icon(
                      trendDown
                          ? Icons.trending_down
                          : Icons.trending_up,
                      color: trendDown ? WColors.success : WColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trendDown ? 'lower risk' : 'watch this',
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: WColors.textSecondary),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
