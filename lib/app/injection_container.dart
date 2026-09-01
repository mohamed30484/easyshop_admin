import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_admin_usecase.dart';
import '../features/auth/domain/usecases/register_admin_usecase.dart';
import '../features/auth/domain/usecases/verify_otp_admin_usecase.dart';
import '../features/auth/domain/usecases/resend_otp_admin_usecase.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  sl.registerLazySingleton<ApiClient>(ApiClient.new);

  // Data
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  // Domain
  sl.registerLazySingleton<RegisterAdminUseCase>(
    () => RegisterAdminUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LoginAdminUseCase>(
    () => LoginAdminUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<VerifyOtpAdminUseCase>(
    () => VerifyOtpAdminUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<ResendOtpAdminUseCase>(
    () => ResendOtpAdminUseCase(sl<AuthRepository>()),
  );

  // Presentation
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      sl<RegisterAdminUseCase>(),
      sl<LoginAdminUseCase>(),
      sl<VerifyOtpAdminUseCase>(),
      sl<ResendOtpAdminUseCase>(),
    ),
  );
}
