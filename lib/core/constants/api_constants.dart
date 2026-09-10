import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConstants {
  /// القيم دي بتتقرأ من ملف `.env` (متجاهل من Git) بدل ما تكون مكتوبة هنا
  /// في الكود مباشرة. لازم `dotenv.load()` يتنفذ في `main.dart` الأول
  /// (قبل `runApp`) عشان القيم دي تبقى متاحة.
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://easylearn.devawy.com/api';

  /// دومين السيرفر بدون `/api` — بيتستخدم لبناء روابط كاملة
  /// للصور/الملفات لو الـ API رجّع مسار نسبي بدل رابط كامل.
  static String get storageBaseUrl =>
      dotenv.env['STORAGE_BASE_URL'] ?? 'https://easylearn.devawy.com';

  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  static const String adminLogin = '/admin/login';
  static const String adminLogout = '/admin/logout';

  static const String adminOtpVerify = '/admin/otp/verify';
  static const String adminOtpResend = '/admin/otp/resend';

  static const String adminRegister = '/admin/register';
  static const String adminProfile = '/admin/profile';
  static const String adminProfileUpdate = '/admin/profile/update';

  static const String adminCategories = '/admin/categories';
  static const String adminProducts = '/admin/products';
  static const String adminOrders = '/admin/orders';
}
