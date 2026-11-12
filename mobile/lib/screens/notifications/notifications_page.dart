import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/network/api_exception.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_spacing.dart';
import '../../widgets/theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../../widgets/common/states.dart';
import '../../models/app_notification.dart';
import '../../services/providers/notifications_provider.dart';

/// Pantalla 12 · Notificaciones: tocar una la marca como leída y abre la pantalla relacionada.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ApiException.from(e).message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(notificationsProvider);
    final controller = ref.read(notificationsProvider.notifier);
    final hasUnread = (inbox.value?.unreadCount ?? 0) > 0;

    Future<void> open(AppNotification n) async {
      await _run(context, () => controller.markRead(n.id));
      final route = n.route;
      if (route != null && context.mounted) context.go(route);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (hasUnread) TextButton(onPressed: () => _run(context, controller.markAllRead), child: const Text('Marcar todas')),
        ],
      ),
      body: switch (inbox) {
        AsyncData(:final value) when value.items.isEmpty => const EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'Sin notificaciones',
            message: 'Aquí te avisaremos de pagos, citas y mantenimiento.',
          ),
        AsyncData(:final value) => RefreshIndicator(
            onRefresh: controller.reload,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: value.items.length,
              separatorBuilder: (_, _) => const Divider(indent: AppSpacing.screen, endIndent: AppSpacing.screen),
              itemBuilder: (context, i) => NotificationTile(notification: value.items[i], onTap: () => open(value.items[i])),
            ),
          ),
        AsyncError(:final error) => ErrorState(error: error, onRetry: controller.reload),
        _ => const LoadingState(),
      },
    );
  }
}

/// Ícono por tipo, título, mensaje, hora y punto azul si no está leída.
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  static IconData iconFor(String type) {
    if (type.startsWith('appointment')) return Icons.calendar_today_outlined;
    if (type.startsWith('payment') || type.startsWith('promissory')) return Icons.payments_outlined;
    if (type.startsWith('receipt')) return Icons.bolt_outlined;
    if (type.startsWith('maintenance')) return Icons.handyman_outlined;
    if (type.startsWith('document')) return Icons.description_outlined;
    return Icons.notifications_none_rounded;
  }

  static String when(DateTime d) {
    final now = Fmt.now();
    final sameDay = d.year == now.year && d.month == now.month && d.day == now.day;
    return sameDay ? Fmt.time(d) : '${Fmt.dayMonthShort(d)} · ${Fmt.time(d)}';
  }

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Semantics(
      button: true,
      label: '${n.read ? '' : 'Sin leer. '}${n.title}. ${n.message}',
      child: InkWell(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen, vertical: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: AppColors.infoBg, shape: BoxShape.circle),
                  child: Icon(iconFor(n.type), color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(n.title, style: AppTextStyles.cardTitle.copyWith(fontWeight: n.read ? FontWeight.w500 : FontWeight.w700))),
                          Text(when(n.sentAt), style: AppTextStyles.secondary),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(n.message, style: AppTextStyles.body.copyWith(fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(color: n.read ? Colors.transparent : AppColors.primary, shape: BoxShape.circle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
