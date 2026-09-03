import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';

import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_admin_usecase.dart';
import '../features/auth/domain/usecases/register_admin_usecase.dart';
import '../features/auth/domain/usecases/resend_otp_admin_usecase.dart';
import '../features/auth/domain/usecases/verify_otp_admin_usecase.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';

import '../features/categories/data/datasources/categories_remote_data_source.dart';
import '../features/categories/data/repositories/categories_repository_impl.dart';
import '../features/categories/domain/repositories/categories_repository.dart';
import '../features/categories/domain/usecases/get_categories_usecase.dart';
import '../features/categories/presentation/cubit/categories_cubit.dart';

import '../features/products/data/datasources/products_remote_data_source.dart';
import '../features/products/data/repositories/products_repository_impl.dart';
import '../features/products/domain/repositories/products_repository.dart';
import '../features/products/domain/usecases/create_product_usecase.dart';
import '../features/products/domain/usecases/delete_product_usecase.dart';
import '../features/products/domain/usecases/get_products_usecase.dart';
import '../features/products/domain/usecases/update_product_usecase.dart';
import '../features/products/presentation/cubit/products_cubit.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  sl.registerLazySingleton<ApiClient>(ApiClient.new);

  // Auth - Data
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  // Auth - Domain
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

  // Auth - Presentation
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      sl<RegisterAdminUseCase>(),
      sl<LoginAdminUseCase>(),
      sl<VerifyOtpAdminUseCase>(),
      sl<ResendOtpAdminUseCase>(),
    ),
  );

  // Products - Data
  sl.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(sl<ProductsRemoteDataSource>()),
  );

  // Products - Domain
  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(sl<ProductsRepository>()),
  );

  sl.registerLazySingleton<CreateProductUseCase>(
    () => CreateProductUseCase(sl<ProductsRepository>()),
  );

  sl.registerLazySingleton<DeleteProductUseCase>(
    () => DeleteProductUseCase(sl<ProductsRepository>()),
  );

  sl.registerLazySingleton<UpdateProductUseCase>(
    () => UpdateProductUseCase(sl<ProductsRepository>()),
  );

  // Products - Presentation
  sl.registerFactory<ProductsCubit>(
    () => ProductsCubit(
      sl<GetProductsUseCase>(),
      sl<CreateProductUseCase>(),
      sl<DeleteProductUseCase>(),
      sl<UpdateProductUseCase>(),
    ),
  );

  // Categories - Data
  sl.registerLazySingleton<CategoriesRemoteDataSource>(
    () => CategoriesRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(sl<CategoriesRemoteDataSource>()),
  );

  // Categories - Domain
  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl<CategoriesRepository>()),
  );

  // Categories - Presentation
  sl.registerFactory<CategoriesCubit>(
    () => CategoriesCubit(sl<GetCategoriesUseCase>()),
  );
}
