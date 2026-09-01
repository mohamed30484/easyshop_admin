import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/models/admin_registration_data.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AdminEntity> registerAdmin(AdminRegistrationData registrationData) {
    return _remoteDataSource.registerAdmin(registrationData);
  }

  @override
  Future<void> loginAdmin({required String email, required String password}) {
    return _remoteDataSource.loginAdmin(email: email, password: password);
  }
}
