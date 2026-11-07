import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_provider.dart';
import '../../models/app_notification.dart';
import '../repositories/notifications_repository.dart';

/// Bandeja de avisos del usuario de la sesión. Se recarga al cambiar de usuario.
final notificationsProvider = AsyncNotifierProvider<NotificationsController, NotificationsPage>(NotificationsController.new);

/// Contador de no leídas para la campana del encabezado (0 mientras carga o si falla).
final unreadCountProvider = Provider<int>((ref) => ref.watch(notificationsProvider).value?.unreadCount ?? 0);

class NotificationsController extends AsyncNotifier<NotificationsPage> {
  NotificationsRepository get _repo => ref.read(notificationsRepositoryProvider);

  @override
  Future<NotificationsPage> build() async {
    final userId = ref.watch(sessionProvider.select((s) => s.value?.id));
    if (userId == null) return const NotificationsPage(items: [], unreadCount: 0);
    return _repo.list();
  }

  Future<void> markRead(String id) async {
    final current = state.value;
    if (current == null) return;
    final target = current.items.where((n) => n.id == id).firstOrNull;
    if (target == null || target.read) return;
    await _repo.markRead(id);
    state = AsyncData(NotificationsPage(
      items: [for (final n in current.items) n.id == id ? n.copyWith(read: true) : n],
      unreadCount: (current.unreadCount - 1).clamp(0, current.unreadCount),
    ));
  }

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null) return;
    await _repo.markAllRead();
    state = AsyncData(NotificationsPage(items: [for (final n in current.items) n.copyWith(read: true)], unreadCount: 0));
  }

  Future<void> reload() async {
    state = await AsyncValue.guard(build);
  }
}
