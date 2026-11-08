import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/app_notification.dart';
import '../../services/providers/notifications_provider.dart';
import '../../services/utils/formatters.dart';
import '../../widgets/common/states.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_spacing.dart';
import '../../widgets/theme/app_text_styles.dart';

/// Bandeja de notificaciones del usuario.
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (state.value?.unreadCount != 0)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
              child: const Text('Marcar todo'),
            ),
        ],
      ),
      body: switch (state) {
        AsyncData(:final value) when value.items.isEmpty => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text('Sin notificaciones por ahora.', textAlign: TextAlign.center),
            ),
          ),
        AsyncData(:final value) => RefreshIndicator(
            onRefresh: () => ref.read(notificationsProvider.notifier).reload(),
            child: ListView.separated(
              itemCount: value.items.length,
              separatorBuilder: (context, i) => const Divider(height: 1),
              itemBuilder: (context, i) => _NotificationTile(item: value.items[i]),
            ),
          ),
        AsyncError(:final error) => ErrorState(
            error: error,
            onRetry: () => ref.invalidate(notificationsProvider),
          ),
        _ => const LoadingState(items: 5, itemHeight: 72),
      },
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.item});

  final AppNotification item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      tileColor: item.read ? null : AppColors.primaryCard.withValues(alpha: .06),
      leading: Icon(
        item.read ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
        color: item.read ? AppColors.navIconInactive : AppColors.navIcon,
      ),
      title: Text(item.title, style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.secondary),
          const SizedBox(height: 2),
          Text(Fmt.dayMonthShort(item.sentAt), style: AppTextStyles.secondary.copyWith(fontSize: 11)),
        ],
      ),
      onTap: () {
        if (!item.read) ref.read(notificationsProvider.notifier).markRead(item.id);
        final route = item.route;
        if (route != null && context.mounted) context.go(route);
      },
    );
  }
}
