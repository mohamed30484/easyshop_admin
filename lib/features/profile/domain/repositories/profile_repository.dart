import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/admin_entity.dart';
import '../usecases/update_profile_params.dart';

abstract class ProfileRepository {
  Future<Either<Failure, AdminEntity>> getProfile();

  Future<Either<Failure, AdminEntity>> updateProfile(
    UpdateProfileParams params,
  );
}
