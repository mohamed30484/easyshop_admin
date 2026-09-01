import '../repositories/auth_repository.dart';

class LoginAdminUseCase {
  LoginAdminUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) {
    return _repository.loginAdmin(email: email, password: password);
  }
}
