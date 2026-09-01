import '../../presentation/models/admin_registration_data.dart';
import '../entities/admin_entity.dart';

abstract class AuthRepository {
  Future<AdminEntity> registerAdmin(AdminRegistrationData registrationData);

  Future<void> loginAdmin({required String email, required String password});
}
