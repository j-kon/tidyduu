import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_provider.dart';

enum FocusTimerStatus { idle, running, paused }

class FocusTimerState {
  final FocusTimerStatus status;
  final int durationSeconds;
  final int remainingSeconds;
  final bool isBreak;
  final String? focusTodoId;

  FocusTimerState({
    this.status = FocusTimerStatus.idle,
    this.durationSeconds = 25 * 60,
    this.remainingSeconds = 25 * 60,
    this.isBreak = false,
    this.focusTodoId,
  });

  FocusTimerState copyWith({
    FocusTimerStatus? status,
    int? durationSeconds,
    int? remainingSeconds,
    bool? isBreak,
    String? Function()? focusTodoId,
  }) {
    return FocusTimerState(
      status: status ?? this.status,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isBreak: isBreak ?? this.isBreak,
      focusTodoId: focusTodoId != null ? focusTodoId() : this.focusTodoId,
    );
  }
}

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  final Ref _ref;
  Timer? _timer;

  FocusTimerNotifier(this._ref) : super(FocusTimerState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setFocusTask(String? todoId) {
    _timer?.cancel();
    if (todoId == null) {
      state = FocusTimerState();
    } else {
      state = FocusTimerState(
        status: FocusTimerStatus.idle,
        durationSeconds: 25 * 60,
        remainingSeconds: 25 * 60,
        isBreak: false,
        focusTodoId: todoId,
      );
    }
  }

  void start() {
    if (state.status == FocusTimerStatus.running) return;

    state = state.copyWith(status: FocusTimerStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(status: FocusTimerStatus.paused);
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      status: FocusTimerStatus.idle,
      remainingSeconds: state.durationSeconds,
    );
  }

  void skipSession() {
    _timer?.cancel();
    _toggleSession(userInitiated: true);
  }

  void _tick() {
    if (state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    } else {
      _timer?.cancel();
      _toggleSession(userInitiated: false);
    }
  }

  void _toggleSession({required bool userInitiated}) {
    final nextIsBreak = !state.isBreak;
    final nextDuration = nextIsBreak ? 5 * 60 : 25 * 60;

    state = state.copyWith(
      status: FocusTimerStatus.idle,
      isBreak: nextIsBreak,
      durationSeconds: nextDuration,
      remainingSeconds: nextDuration,
    );

    if (!userInitiated) {
      // Trigger notification
      final notificationService = _ref.read(notificationServiceProvider);
      if (nextIsBreak) {
        notificationService.showInstantNotification(
          'Focus Session Completed! ☀️',
          'Time for a well-deserved 5-minute break.',
        );
      } else {
        notificationService.showInstantNotification(
          'Break Ended! 🎯',
          'Ready to focus again? Let\'s get started.',
        );
      }
    }
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerState>((ref) {
      return FocusTimerNotifier(ref);
    });
