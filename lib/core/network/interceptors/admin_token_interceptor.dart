import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminTokenInterceptor extends Interceptor {
  static const String _tokenKey = 'admin_token';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);

      if (savedToken != null && savedToken.trim().isNotEmpty) {
        final token = _normalizeToken(savedToken);

        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Do not block the request if local storage cannot be read.
    }

    handler.next(options);
  }

  String _normalizeToken(String value) {
    final token = value.trim();

    if (token.toLowerCase().startsWith('bearer ')) {
      return token.substring(7).trim();
    }

    return token;
  }
}
