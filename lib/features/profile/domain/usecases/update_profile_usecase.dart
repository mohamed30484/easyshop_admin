import '../../../auth/domain/entities/admin_entity.dart';
import '../repositories/profile_repository.dart';
import 'update_profile_params.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<AdminEntity> call(UpdateProfileParams params) async {
    final result = await _repository.updateProfile(params);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (admin) => admin,
    );
  }
}
