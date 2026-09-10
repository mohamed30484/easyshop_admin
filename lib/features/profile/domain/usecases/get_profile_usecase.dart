import '../../../auth/domain/entities/admin_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<AdminEntity> call() async {
    final result = await _repository.getProfile();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (admin) => admin,
    );
  }
}
