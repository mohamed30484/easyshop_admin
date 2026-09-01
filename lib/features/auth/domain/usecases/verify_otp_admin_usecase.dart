import '../../domain/repositories/auth_repository.dart';

class VerifyOtpAdminUseCase {
  VerifyOtpAdminUseCase(this._repository);

  final AuthRepository _repository;

  Future<Map<String, dynamic>> call({
    required String email,
    required String otpCode,
  }) async {
    final result = await _repository.verifyOtpAdmin(
      email: email,
      otpCode: otpCode,
    );

    return result.fold((failure) => throw failure, (data) => data);
  }
}
