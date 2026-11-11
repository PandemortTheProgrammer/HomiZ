import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_call.dart';
import '../network/api_client.dart';
import '../utils/formatters.dart';

/// Compra cerrada con la inmobiliaria (venta registrada por administración). Solo es el comprobante:
/// la casa vendida no se administra después.
class Purchase {
  const Purchase({
    required this.id,
    required this.folio,
    required this.status,
    required this.saleDate,
    required this.price,
    required this.propertyName,
    required this.propertyCode,
    this.address,
    this.zone,
    this.paymentMethod,
    this.notary,
    this.hasDocument = false,
    this.voidReason,
  });

  factory Purchase.fromJson(Map<String, dynamic> j) {
    final p = (j['property'] as Map?)?.cast<String, dynamic>() ?? const {};
    return Purchase(
      id: j['id'] as String,
      folio: j['folio'] as String,
      status: j['status'] as String,
      saleDate: Fmt.parse(j['saleDate'] as String),
      price: (j['price'] as num).toDouble(),
      propertyName: p['name'] as String? ?? 'Casa',
      propertyCode: p['code'] as String? ?? '',
      address: p['address'] as String?,
      zone: p['zone'] as String?,
      paymentMethod: j['paymentMethod'] as String?,
      notary: j['notary'] as String?,
      hasDocument: j['hasDocument'] as bool? ?? false,
      voidReason: j['voidReason'] as String?,
    );
  }

  final String id;
  final String folio;

  /// closed (vendida) · voided (anulada por la inmobiliaria)
  final String status;
  final DateTime saleDate;
  final double price;
  final String propertyName;
  final String propertyCode;
  final String? address;
  final String? zone;
  final String? paymentMethod;
  final String? notary;
  final bool hasDocument;
  final String? voidReason;

  bool get isClosed => status == 'closed';
}

final salesRepositoryProvider = Provider<SalesRepository>((ref) => SalesRepository(ref.watch(dioProvider)));

class SalesRepository {
  SalesRepository(this._dio);

  final Dio _dio;

  /// Mis compras (el cliente solo recibe las suyas).
  Future<List<Purchase>> mine() => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>('/sales', queryParameters: {'limit': 50});
        return [for (final j in (res.data!['data'] as List)) Purchase.fromJson((j as Map).cast<String, dynamic>())];
      });

  /// URL firmada del comprobante en PDF (se genera al momento).
  Future<String> receiptUrl(String id) => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>('/sales/$id/receipt-url');
        return res.data!['url'] as String;
      });

  /// URL firmada del contrato firmado (si la inmobiliaria lo subió).
  Future<String> contractUrl(String id) => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>('/sales/$id/document-url');
        return res.data!['url'] as String;
      });
}

final myPurchasesProvider = FutureProvider.autoDispose<List<Purchase>>((ref) => ref.watch(salesRepositoryProvider).mine());
