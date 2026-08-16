import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountdownTimerState {
  final int initialDurationSeconds;
  final int startedAtMs;
  final String labelText;
  final bool isActive;

  CountdownTimerState({
    this.initialDurationSeconds = 20538, // 5h 42m 18s default
    this.startedAtMs = 0,
    this.labelText = '🔥 Sale Ends In:',
    this.isActive = true,
  });

  int get remainingSeconds {
    if (!isActive) return 0;
    if (startedAtMs == 0) return initialDurationSeconds;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final elapsedSec = ((nowMs - startedAtMs) / 1000).floor();
    final rem = initialDurationSeconds - elapsedSec;
    if (rem <= 0) {
      return initialDurationSeconds > 0 ? (rem.abs() % initialDurationSeconds) : 0;
    }
    return rem;
  }

  CountdownTimerState copyWith({
    int? initialDurationSeconds,
    int? startedAtMs,
    String? labelText,
    bool? isActive,
  }) {
    return CountdownTimerState(
      initialDurationSeconds: initialDurationSeconds ?? this.initialDurationSeconds,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      labelText: labelText ?? this.labelText,
      isActive: isActive ?? this.isActive,
    );
  }
}

class CountdownTimerNotifier extends StateNotifier<CountdownTimerState> {
  static const _durationKey = 'cosmyra_timer_duration_sec';
  static const _startMsKey = 'cosmyra_timer_start_ms';
  static const _labelKey = 'cosmyra_timer_label';
  static const _activeKey = 'cosmyra_timer_active';

  CountdownTimerNotifier() : super(CountdownTimerState()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dur = prefs.getInt(_durationKey) ?? 20538;
      var startMs = prefs.getInt(_startMsKey) ?? 0;
      final label = prefs.getString(_labelKey) ?? '🔥 Sale Ends In:';
      final active = prefs.getBool(_activeKey) ?? true;

      if (startMs == 0) {
        startMs = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt(_startMsKey, startMs);
      }

      state = CountdownTimerState(
        initialDurationSeconds: dur,
        startedAtMs: startMs,
        labelText: label,
        isActive: active,
      );
    } catch (_) {}
  }

  Future<void> resetTimer({int? hours, int? minutes, int? seconds, String? labelText}) async {
    final h = hours ?? 5;
    final m = minutes ?? 42;
    final s = seconds ?? 18;
    final totalSec = (h * 3600) + (m * 60) + s;
    final startMs = DateTime.now().millisecondsSinceEpoch;
    final label = labelText ?? state.labelText;

    state = state.copyWith(
      initialDurationSeconds: totalSec,
      startedAtMs: startMs,
      labelText: label,
      isActive: true,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_durationKey, totalSec);
      await prefs.setInt(_startMsKey, startMs);
      await prefs.setString(_labelKey, label);
      await prefs.setBool(_activeKey, true);
    } catch (_) {}
  }

  Future<void> toggleActive(bool active) async {
    state = state.copyWith(isActive: active);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_activeKey, active);
    } catch (_) {}
  }
}

final countdownTimerProvider = StateNotifierProvider<CountdownTimerNotifier, CountdownTimerState>((ref) {
  return CountdownTimerNotifier();
});
