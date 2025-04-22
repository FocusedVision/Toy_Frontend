import 'package:bloc/bloc.dart';
import 'package:toyvalley/data/network/net_repository.dart';
import 'package:toyvalley/config/get_it.dart';
import 'package:toyvalley/cubit/profile/state.dart';
import 'package:toyvalley/data/model/apiResponse.dart';
import 'package:toyvalley/data/model/user.dart';
import 'package:toyvalley/data/model/avatar.dart';
import 'package:toyvalley/data/const.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final NetworkRepository networkRepository;

  ProfileCubit([networkRepository])
    : networkRepository = networkRepository ?? getIt.get<NetworkRepository>(),
      super(ProfileState());

  void initialize() async {
    getUser();
    getAvatars();
  }

  Future getUser() async {
    ApiResponse response = await networkRepository.getUser();
    if (response.success) {
      User user = User.fromJson(response.data);
      emit(state.copyWith(user: user, noConnection: false));
    } else if (response.data == noConnection) {
      emit(state.copyWith(noConnection: true));
    }
  }

  Future getAvatars() async {
    if (state.avatars == null) {
      ApiResponse response = await networkRepository.getAvatars();
      if (response.success) {
        List<Avatar> avatars = [];
        response.data.forEach(
          (element) => avatars.add(Avatar.fromJson(element)),
        );
        List<List<Avatar>> chunkedAvatars = [];
        int chunkSize = 9;
        for (var i = 0; i < avatars.length; i += chunkSize) {
          chunkedAvatars.add(
            avatars.sublist(
              i,
              i + chunkSize > avatars.length ? avatars.length : i + chunkSize,
            ),
          );
        }
        emit(state.copyWith(avatars: avatars, chunkedAvatars: chunkedAvatars));
      }
    }
  }

  Future updateUser(String? name, String? image) async {
    ApiResponse response = await networkRepository.updateUser(name, image);
    if (response.success) {
      getUser();
    } else {
      emit(state.copyWith(nameError: 'The name was entered incorrectly'));
      return false;
    }
  }

  void setNewName(String name) {
    emit(state.copyWith(newName: name));
  }

  void setNewAvatar(String image) {
    emit(state.copyWith(newAvatar: image));
  }

  void cleanPreviousData() {
    emit(
      ProfileState(
        user: state.user,
        avatars: state.avatars,
        chunkedAvatars: state.chunkedAvatars,
      ),
    );
  }
}
