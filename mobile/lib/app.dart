import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/push/push_controller.dart';
import 'screens/app_router.dart';
import 'services/providers/session_provider.dart';
import 'widgets/theme/app_theme.dart';

/// Raíz de la app: tema, idioma es_MX y router.
class HomizApp extends ConsumerWidget {
  const HomizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Avisos push: al iniciar sesión (o recuperar la guardada) se registra este dispositivo.
    ref.listen(sessionProvider.select((s) => s.value?.id), (_, id) {
      if (id != null) unawaited(ref.read(pushProvider).register());
    });
    return MaterialApp.router(
      title: 'Homiz',
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: ref.watch(routerProvider),
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX'), Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Horas en formato de 24 horas en toda la app (también el reloj para elegir la hora)
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false), child: child!),
    );
  }
}
