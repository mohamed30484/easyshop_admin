import '../../domain/repositories/auth_repository.dart';

class LogoutAdminUseCase {
  LogoutAdminUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() async {
    final result = await _repository.logoutAdmin();

    result.fold((failure) => throw failure, (_) {});
  }
}
