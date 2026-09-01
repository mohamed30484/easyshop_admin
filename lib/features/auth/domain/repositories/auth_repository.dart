import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../presentation/models/admin_registration_data.dart';
import '../entities/admin_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AdminEntity>> registerAdmin(
    AdminRegistrationData registrationData,
  );

  Future<Either<Failure, void>> loginAdmin({
    required String email,
    required String password,
  });

  Future<Either<Failure, Map<String, dynamic>>> verifyOtpAdmin({
    required String email,
    required String otpCode,
  });

  Future<Either<Failure, void>> resendOtpAdmin({required String email});
}
