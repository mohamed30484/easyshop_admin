import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  runApp(const EasyShopAdminApp());
}
