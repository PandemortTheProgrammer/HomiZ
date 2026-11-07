import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'services/push/push_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX');
  final firebaseReady = await initFirebase(); // avisos push; sin configuración la app sigue sin ellos
  runApp(ProviderScope(
    overrides: [firebaseReadyProvider.overrideWithValue(firebaseReady)],
    child: const HomizApp(),
  ));
}
