import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_call.dart';
import '../network/api_client.dart';
import '../../models/client_dashboard.dart';
import '../../models/staff_dashboard.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) => DashboardRepository(ref.watch(dioProvider)));

/// GET /dashboard: la API responde según el perfil de la sesión.
class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  Future<ClientDashboard> client() => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>('/dashboard');
        return ClientDashboard.fromJson(res.data!);
      });

  Future<StaffDashboard> staff() => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>('/dashboard');
        return StaffDashboard.fromJson(res.data!);
      });
}
