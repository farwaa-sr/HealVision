import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';

import '../../../data/assesment_repsitories/assesment_repsitory.dart';
import '../../../data/repositories/recovery/recovery_repository.dart';
import '../../../utilis/loaders/loaders.dart';
import '../../personalization/controllers/user_controller.dart';
import '../models/mood_log.dart';
import '../models/recovery_profile.dart';

/// Drives the recovery dashboard: sobriety streak, daily motivation (Claude),
/// mood/craving log, and the assessment score trend.
class RecoveryController extends GetxController {
  static RecoveryController get instance => Get.find();

  final _repo = RecoveryRepository();
  final _assessmentRepo = Get.put(AssessmentRepository());
  final _userController = Get.put(UserController());
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  final Rx<RecoveryProfile> profile = RecoveryProfile.empty().obs;
  final RxList<MoodLog> moods = <MoodLog>[].obs;
  final RxList<Map<String, dynamic>> scoreHistory =
      <Map<String, dynamic>>[].obs;

  final RxString motivation = ''.obs;
  final RxBool loadingProfile = false.obs;
  final RxBool loadingMotivation = false.obs;

  StreamSubscription? _moodSub;

  String get _uid => _userController.user.value.id;
  int get streakDays => profile.value.streakDays;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    _moodSub?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    if (_uid.isEmpty) return;
    loadingProfile.value = true;
    try {
      profile.value = await _repo.fetchProfile(_uid);
      _moodSub ??= _repo.streamMoods(_uid).listen(moods.assignAll);
      scoreHistory.assignAll(await _assessmentRepo.fetchScoreHistory(_uid));
      fetchMotivation();
    } catch (_) {
      // keep defaults
    } finally {
      loadingProfile.value = false;
    }
  }

  Future<void> setQuitDate(DateTime date) async {
    try {
      final updated =
          RecoveryProfile(quitDate: date, reasons: profile.value.reasons);
      await _repo.saveProfile(_uid, updated);
      profile.value = updated;
      fetchMotivation();
      TLoaders.successSnackBar(
          title: 'Saved', message: 'Your quit date has been set.');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Could not save date.');
    }
  }

  Future<void> setReasons(String reasons) async {
    try {
      final updated = RecoveryProfile(
          quitDate: profile.value.quitDate, reasons: reasons);
      await _repo.saveProfile(_uid, updated);
      profile.value = updated;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Could not save.');
    }
  }

  Future<void> logMood(String mood, int craving, String note) async {
    try {
      await _repo.addMood(
        _uid,
        MoodLog(
            mood: mood,
            craving: craving,
            note: note,
            createdAt: DateTime.now()),
      );
      TLoaders.successSnackBar(
          title: 'Logged', message: 'Mood check-in saved.');
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Could not save mood.');
    }
  }

  Future<void> fetchMotivation() async {
    loadingMotivation.value = true;
    try {
      final callable = _functions.httpsCallable('dailyMotivation');
      final result = await callable.call<Map<String, dynamic>>({
        'streakDays': streakDays,
        'reasons': profile.value.reasons,
      });
      motivation.value = (result.data['message'] as String?)?.trim() ??
          'One day at a time. You are doing this.';
    } catch (_) {
      motivation.value = 'One day at a time. You are doing this.';
    } finally {
      loadingMotivation.value = false;
    }
  }
}
