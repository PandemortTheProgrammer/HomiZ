import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'appointments/appointment_detail_page.dart';
import 'appointments/appointments_page.dart';
import 'appointments/catalog_page.dart';
import '../services/providers/pending_visit_provider.dart';
import 'appointments/request_visit_page.dart';
import '../services/providers/session_provider.dart';
import 'auth/create_password_page.dart';
import 'auth/login_page.dart';
import '../services/providers/site_link_provider.dart';
import 'auth/register_page.dart';
import 'auth/reset_password_page.dart';
import 'auth/splash_page.dart';
import 'home/home_page.dart';
import 'notifications/notifications_page.dart';
import 'profile/profile_page.dart';
import 'requests/new_request_page.dart';
import 'requests/request_detail_page.dart';
import 'requests/requests_page.dart';
import '../services/providers/requests_provider.dart';
import '../services/live/live_updates.dart';
import '../widgets/common/homiz_bottom_nav.dart';

const _authRoutes = {'/login', '/register', '/reset'};
const _createPassword = '/create-password';

int? _intParam(GoRouterState state, String name) => int.tryParse(state.uri.queryParameters[name] ?? '');

/// Decide a dónde ir según la sesión. Pura para poder probarla sin widgets.
/// [pendingVisit]: casa elegida en el sitio; sin sesión se pide crear cuenta y al entrar se abre su visita.
/// [resetLink]: llegó con el enlace del correo para crear su contraseña.
/// [fromSite]: acaba de enviar un formulario del sitio; al entrar ve sus solicitudes.
/// [mustChangePassword]: entró con la contraseña temporal del correo; antes de todo crea la suya.
/// [start]: entró por un QR sin llenar datos; al entrar se le pregunta «¿Qué quieres hacer?» (con su casa, si la hay).
@visibleForTesting
String? sessionRedirect({
  required bool splashDone,
  required AsyncValue<Object?> session,
  required String location,
  String? pendingVisit,
  bool resetLink = false,
  bool fromSite = false,
  bool mustChangePassword = false,
  bool start = false,
}) {
  // Mientras se recupera la sesión guardada (o si no hubo red) se queda en la bienvenida.
  if (!splashDone || session.isLoading || session.hasError) return location == '/splash' ? null : '/splash';
  final signedIn = session.value != null;
  if (!signedIn) {
    if (_authRoutes.contains(location)) return null;
    return resetLink ? '/reset' : pendingVisit != null ? '/register' : '/login';
  }
  if (mustChangePassword) return location == _createPassword ? null : _createPassword;
  if (location == '/splash' || location == _createPassword || _authRoutes.contains(location)) {
    if (start) return '/home/requests/new?bienvenida=1${pendingVisit != null ? '&casa=$pendingVisit' : ''}';
    if (pendingVisit != null) return '/appointments/visit/$pendingVisit';
    return fromSite ? '/home/requests' : '/home';
  }
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  // Avisa al router cuando cambia la sesión o termina la bienvenida.
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  ref.listen(splashDelayProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final user = session.value;
      final link = ref.read(siteLinkProvider);
      // Solo los clientes solicitan visitas; el personal entra a su inicio de siempre.
      final pendingVisit = user == null || user.isClient ? ref.read(pendingVisitProvider) : null;
      // Cuenta nueva sin QR ni enlace del sitio: el mismo formulario de Contáctanos, para que administración asigne broker.
      final newAccount = ref.read(sessionProvider.notifier).justRegistered && pendingVisit == null && !link.fromSite;
      final target = sessionRedirect(
        splashDone: ref.read(splashDelayProvider).hasValue,
        session: session,
        location: state.matchedLocation,
        pendingVisit: pendingVisit,
        resetLink: link.resetToken != null,
        fromSite: link.fromSite && (user == null || user.isClient),
        mustChangePassword: user?.mustChangePassword ?? false,
        start: (link.start || newAccount) && (user == null || user.isClient),
      );
      // Ya entró: el enlace del sitio o del correo no se vuelve a usar.
      if (target == '/home/requests') Future.microtask(ref.read(siteLinkProvider.notifier).clear);
      return target;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(path: '/reset', builder: (_, _) => const ResetPasswordPage()),
      // Entró con la contraseña temporal del correo: crea la suya antes de seguir
      GoRoute(path: _createPassword, builder: (_, _) => const CreatePasswordPage()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationsPage()),
      // Avisos de pagos, contratos o mantenimiento: esas pantallas no están en esta versión
      GoRoute(
        path: '/property',
        redirect: (_, _) => '/home',
        routes: [
          GoRoute(path: 'maintenance/:id', redirect: (_, _) => '/home'),
          GoRoute(path: ':id', redirect: (_, _) => '/home'),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TabsShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (_, _) => const HomePage(),
              routes: [
                // Solicitudes: cliente «Mis solicitudes» y «Busco casa»; personal, las del sitio y la app.
                GoRoute(path: 'requests', builder: (_, _) => const RequestsPage()),
                GoRoute(
                  path: 'requests/new',
                  builder: (_, state) => NewRequestPage(slug: state.uri.queryParameters['casa'], welcome: state.uri.queryParameters['bienvenida'] == '1'),
                ),
                GoRoute(path: 'requests/:id', builder: (_, state) => RequestDetailPage(requestId: state.pathParameters['id']!)),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/appointments',
              builder: (_, state) => AppointmentsPage(initialFilter: _intParam(state, 'filter')),
              routes: [
                // «catalog» va antes que «:id» para que no se tome como id de cita.
                GoRoute(path: 'catalog', builder: (_, _) => const CatalogPage()),
                GoRoute(path: 'catalog/:propertyId', builder: (_, state) => RequestVisitPage(propertyId: state.pathParameters['propertyId']!)),
                // Casa elegida en el sitio de Zugar (por su slug).
                GoRoute(path: 'visit/:slug', builder: (_, state) => VisitFromSitePage(slug: state.pathParameters['slug']!)),
                GoRoute(path: ':id', builder: (_, state) => AppointmentDetailPage(appointmentId: state.pathParameters['id']!)),
              ],
            ),
          ]),
          // Pestaña «Solicitudes» del personal (leads.manage): acceso directo para los brokers.
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/requests',
              builder: (_, _) => const RequestsPage(),
              routes: [
                GoRoute(path: ':id', builder: (_, state) => RequestDetailPage(requestId: state.pathParameters['id']!)),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class _TabsShell extends ConsumerWidget {
  const _TabsShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tiempo real mientras se usa la app (avisos, citas y solicitudes se actualizan solos)
    ref.watch(liveUpdatesProvider);
    final user = ref.watch(sessionProvider).value;
    // Solicitudes como pestaña propia para quien las atiende (brokers y administración)
    final showRequests = user != null && user.isStaff && user.can('leads.manage');
    final newRequests = showRequests ? ref.watch(requestsProvider('nuevo')).value?.length ?? 0 : 0;
    return Scaffold(
      body: shell,
      bottomNavigationBar: HomizBottomNav(
        currentIndex: shell.currentIndex,
        showRequests: showRequests,
        newRequests: newRequests,
        // Tocar la pestaña activa regresa a su inicio.
        onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}
