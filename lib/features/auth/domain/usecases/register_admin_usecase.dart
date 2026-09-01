import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/models/admin_registration_data.dart';

class RegisterAdminUseCase {
  RegisterAdminUseCase(this._repository);

  final AuthRepository _repository;

  Future<AdminEntity> call(AdminRegistrationData registrationData) async {
    final result = await _repository.registerAdmin(registrationData);

    return result.fold((failure) => throw failure, (admin) => admin);
  }
}
