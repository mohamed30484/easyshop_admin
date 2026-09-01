import 'package:get_it/get_it.dart';

import '../core/network/api_client.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_admin_usecase.dart';
import '../features/auth/domain/usecases/register_admin_usecase.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  sl.registerLazySingleton<ApiClient>(ApiClient.new);

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<RegisterAdminUseCase>(
    () => RegisterAdminUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LoginAdminUseCase>(
    () => LoginAdminUseCase(sl<AuthRepository>()),
  );

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(sl<RegisterAdminUseCase>(), sl<LoginAdminUseCase>()),
  );
}
