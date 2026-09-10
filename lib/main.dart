import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'app/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // لازم يحمّل قبل أي كود تاني لأن `ApiConstants` (baseUrl/apiKey) بتقراها من هنا.
  await dotenv.load(fileName: '.env');

  await setupDependencies();

  runApp(const EasyShopAdminApp());
}
