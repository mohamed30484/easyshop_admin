import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'interceptors/admin_token_interceptor.dart';

class ApiClient {
  ApiClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          headers: const {
            'Accept': 'application/json',
            'x-api-key': ApiConstants.apiKey,
          },
        ),
      ) {
    dio.interceptors.add(AdminTokenInterceptor());
  }

  final Dio dio;
}
