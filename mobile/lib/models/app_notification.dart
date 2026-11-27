import 'package:freezed_annotation/freezed_annotation.dart';

import '../services/utils/json_converters.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// Aviso de la bandeja propia (GET /notifications).
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    @Default('') String type,
    @Default('') String title,
    @Default('') String message,
    @Default(false) bool read,
    @LocalDate() required DateTime sentAt,
    String? entity,
    String? entityId,
  }) = _AppNotification;

  const AppNotification._();

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

  /// Ruta de la pantalla relacionada (null si no hay a dónde ir).
  /// La app solo tiene citas y solicitudes: los avisos de pagos, documentos, reportes o ventas no abren nada.
  String? get route => switch (entity) {
        'appointment' when entityId != null => '/appointments/$entityId',
        'lead' when entityId != null => '/home/requests/$entityId',
        _ => null,
      };
}

class NotificationsPage {
  const NotificationsPage({required this.items, required this.unreadCount});

  final List<AppNotification> items;
  final int unreadCount;
}
