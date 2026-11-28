import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_call.dart';
import '../network/api_client.dart';
import '../../models/maintenance_report.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) => MaintenanceRepository(ref.watch(dioProvider)));

class MaintenanceRepository {
  MaintenanceRepository(this._dio);

  final Dio _dio;

  Future<List<MaintenanceReport>> list({String? propertyId, List<String>? status}) => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>('/maintenance-reports', queryParameters: {
          'limit': 100,
          'propertyId': ?propertyId,
          if (status != null && status.isNotEmpty) 'status': status,
        });
        return dataList(res.data, MaintenanceReport.fromJson);
      });

  /// Cambio de estado (permiso maintenance.manage). Avisa al cliente que lo reportó.
  Future<MaintenanceReport> addUpdate(String id, {required String status, String? comment, String? providerId}) => apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>('/maintenance-reports/$id/updates', data: {
          'status': status,
          if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
          'providerId': ?providerId,
        });
        return MaintenanceReport.fromJson(res.data!);
      });

  /// Detalle con línea de tiempo y fotos antes/después.
  Future<MaintenanceReport> get(String id) => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>('/maintenance-reports/$id');
        return MaintenanceReport.fromJson(res.data!);
      });

  Future<MaintenanceReport> create({
    required String propertyId,
    required String title,
    required String description,
    required String category,
    required String priority,
    List<String> photos = const [],
  }) =>
      apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>('/maintenance-reports', data: {
          'propertyId': propertyId,
          'title': title.trim(),
          'description': description.trim(),
          'category': category,
          'priority': priority,
          'photos': photos,
        });
        return MaintenanceReport.fromJson(res.data!);
      });
}
