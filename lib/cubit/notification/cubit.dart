import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toyvalley/data/network/net_repository.dart';
import 'package:toyvalley/config/get_it.dart';

part 'state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final _networkRepository = getIt.get<NetworkRepository>();

  NotificationCubit() : super(NotificationState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await _networkRepository.getNotification();
      print("Notification State: ${response.data['isEnabled']}");
      if (response.success) {
        emit(
          state.copyWith(
            isEnabled: response.data['isEnabled'],
            isLoading: false,
          ),
        );
      } else {
        emit(
          state.copyWith(isLoading: false, error: 'Failed to load settings'),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> toggleNewToysNotifications(bool value) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await _networkRepository.updateNotification(
        isEnabled: value,
      );
      if (response.success) {
        emit(state.copyWith(isEnabled: value, isLoading: false));
      } else {
        emit(
          state.copyWith(isLoading: false, error: 'Failed to update settings'),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
