import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_params.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._getProfileUseCase, this._updateProfileUseCase)
    : super(const ProfileInitial());

  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  Future<void> getProfile() async {
    emit(const ProfileLoading());

    try {
      final admin = await _getProfileUseCase();

      emit(ProfileLoaded(admin));
    } catch (error) {
      emit(ProfileFailure(_errorMessage(error)));
    }
  }

  Future<void> updateProfile(UpdateProfileParams params) async {
    emit(const ProfileUpdating());

    try {
      final admin = await _updateProfileUseCase(params);

      emit(ProfileUpdated(admin));
    } catch (error) {
      emit(ProfileUpdateFailure(_errorMessage(error)));
    }
  }

  String _errorMessage(Object error) {
    final message = error.toString();

    const failurePrefix = 'ServerFailure(message: ';
    if (message.startsWith(failurePrefix) && message.endsWith(')')) {
      return message.substring(failurePrefix.length, message.length - 1).trim();
    }

    return message.replaceFirst('Exception: ', '').trim();
  }
}
