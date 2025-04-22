part of 'cubit.dart';

class NotificationState {
  final bool isEnabled;
  final bool isLoading;
  final String? error;

  NotificationState({
    this.isEnabled = false,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    bool? isEnabled,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
