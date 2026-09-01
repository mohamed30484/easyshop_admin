import '../../presentation/models/admin_registration_data.dart';
import '../entities/admin_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterAdminUseCase {
  RegisterAdminUseCase(this._repository);

  final AuthRepository _repository;

  Future<AdminEntity> call(AdminRegistrationData registrationData) {
    return _repository.registerAdmin(registrationData);
  }
}
