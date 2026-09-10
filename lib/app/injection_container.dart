import 'package:get_it/get_it.dart';

import '../../core/network/api_client.dart';

import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_admin_usecase.dart';
import '../features/auth/domain/usecases/logout_admin_usecase.dart';
import '../features/auth/domain/usecases/register_admin_usecase.dart';
import '../features/auth/domain/usecases/resend_otp_admin_usecase.dart';
import '../features/auth/domain/usecases/verify_otp_admin_usecase.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';

import '../features/categories/data/datasources/categories_remote_data_source.dart';
import '../features/categories/data/repositories/categories_repository_impl.dart';
import '../features/categories/domain/repositories/categories_repository.dart';
import '../features/categories/domain/usecases/create_category_usecase.dart';
import '../features/categories/domain/usecases/delete_category_usecase.dart';
import '../features/categories/domain/usecases/get_categories_usecase.dart';
import '../features/categories/domain/usecases/update_category_usecase.dart';
import '../features/categories/presentation/cubit/categories_cubit.dart';

import '../features/home/presentation/cubit/home_cubit.dart';

import '../features/orders/data/datasources/orders_remote_data_source.dart';
import '../features/orders/data/repositories/orders_repository_impl.dart';
import '../features/orders/domain/repositories/orders_repository.dart';
import '../features/orders/domain/usecases/get_orders_usecase.dart';
import '../features/orders/presentation/cubit/orders_cubit.dart';

import '../features/products/data/datasources/products_remote_data_source.dart';
import '../features/products/data/repositories/products_repository_impl.dart';
import '../features/products/domain/repositories/products_repository.dart';
import '../features/products/domain/usecases/create_product_usecase.dart';
import '../features/products/domain/usecases/delete_product_usecase.dart';
import '../features/products/domain/usecases/get_products_usecase.dart';
import '../features/products/domain/usecases/update_product_usecase.dart';
import '../features/products/presentation/cubit/products_cubit.dart';

import '../features/profile/data/datasources/profile_remote_data_source.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/profile/domain/usecases/get_profile_usecase.dart';
import '../features/profile/domain/usecases/update_profile_usecase.dart';
import '../features/profile/presentation/cubit/profile_cubit.dart';

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

  sl.registerLazySingleton<LogoutAdminUseCase>(
    () => LogoutAdminUseCase(sl<AuthRepository>()),
  );

  // Auth - Presentation
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      sl<RegisterAdminUseCase>(),
      sl<LoginAdminUseCase>(),
      sl<VerifyOtpAdminUseCase>(),
      sl<ResendOtpAdminUseCase>(),
      sl<LogoutAdminUseCase>(),
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

  sl.registerLazySingleton<CreateCategoryUseCase>(
    () => CreateCategoryUseCase(sl<CategoriesRepository>()),
  );

  sl.registerLazySingleton<UpdateCategoryUseCase>(
    () => UpdateCategoryUseCase(sl<CategoriesRepository>()),
  );

  sl.registerLazySingleton<DeleteCategoryUseCase>(
    () => DeleteCategoryUseCase(sl<CategoriesRepository>()),
  );

  // Categories - Presentation
  sl.registerFactory<CategoriesCubit>(
    () => CategoriesCubit(
      sl<GetCategoriesUseCase>(),
      sl<CreateCategoryUseCase>(),
      sl<UpdateCategoryUseCase>(),
      sl<DeleteCategoryUseCase>(),
    ),
  );

  // Orders - Data
  sl.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(sl<OrdersRemoteDataSource>()),
  );

  // Orders - Domain
  sl.registerLazySingleton<GetOrdersUseCase>(
    () => GetOrdersUseCase(sl<OrdersRepository>()),
  );

  // Orders - Presentation
  sl.registerFactory<OrdersCubit>(() => OrdersCubit(sl<GetOrdersUseCase>()));

  // Home - Presentation (بيعيد استخدام نفس use cases المنتجات/الطلبات/التصنيفات
  // المسجلة فوق، مفيش endpoint مخصص للـ dashboard).
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      sl<GetProductsUseCase>(),
      sl<GetOrdersUseCase>(),
      sl<GetCategoriesUseCase>(),
    ),
  );

  // Profile - Data
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );

  // Profile - Domain
  sl.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(sl<ProfileRepository>()),
  );

  sl.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(sl<ProfileRepository>()),
  );

  // Profile - Presentation
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(sl<GetProfileUseCase>(), sl<UpdateProfileUseCase>()),
  );
}
