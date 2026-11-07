import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_call.dart';
import '../network/api_client.dart';
import '../../models/app_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) => NotificationsRepository(ref.watch(dioProvider)));

class NotificationsRepository {
  NotificationsRepository(this._dio);

  final Dio _dio;

  Future<NotificationsPage> list({int limit = 50}) => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>('/notifications', queryParameters: {'limit': limit});
        return NotificationsPage(
          items: dataList(res.data, AppNotification.fromJson),
          unreadCount: (res.data?['unreadCount'] as num?)?.toInt() ?? 0,
        );
      });

  Future<void> markRead(String id) => apiCall(() => _dio.patch<void>('/notifications/$id/read'));

  Future<void> markAllRead() => apiCall(() => _dio.post<void>('/notifications/read-all'));
}
