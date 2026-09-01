import '../../domain/repositories/auth_repository.dart';

class ResendOtpAdminUseCase {
  ResendOtpAdminUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email}) async {
    final result = await _repository.resendOtpAdmin(email: email);

    result.fold((failure) => throw failure, (_) {});
  }
}
