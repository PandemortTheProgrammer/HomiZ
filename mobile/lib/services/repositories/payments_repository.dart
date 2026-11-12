import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_call.dart';
import '../network/api_client.dart';
import '../../models/payment_models.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) => PaymentsRepository(ref.watch(dioProvider)));

/// Pagarés con su resumen.
class NotesPage {
  const NotesPage({required this.notes, this.summary});

  final List<PromissoryNote> notes;
  final NotesSummary? summary;
}

class PaymentsRepository {
  PaymentsRepository(this._dio);

  final Dio _dio;

  /// Cliente: los suyos con el resumen del contrato vigente.
  /// Personal: se filtra por [contractId] (incluye el resumen), [propertyId] o [status].
  Future<NotesPage> notes({String? contractId, String? propertyId, List<String>? status}) => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>('/promissory-notes', queryParameters: {
          'limit': 100,
          'contractId': ?contractId,
          'propertyId': ?propertyId,
          if (status != null && status.isNotEmpty) 'status': status,
        });
        final summary = res.data?['summary'];
        return NotesPage(
          notes: dataList(res.data, PromissoryNote.fromJson),
          summary: summary == null ? null : NotesSummary.fromJson(summary as Map<String, dynamic>),
        );
      });

  Future<List<Receipt>> receipts({String? propertyId}) => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>('/receipts', queryParameters: {'limit': 100, 'propertyId': ?propertyId, 'pagares': '1'});
        return dataList(res.data, Receipt.fromJson);
      });

  /// Pago en efectivo (permiso payments.register). El monto debe cubrir el pagaré completo.
  /// El folio lo genera el servidor (`REC-ZUG-012-05`: casa y pagaré) y viene en `payment.receiptFolio`.
  Future<PromissoryNote> registerPayment(String noteId, {required double amount, required DateTime paidAt, String? notes}) =>
      apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>('/promissory-notes/$noteId/payments', data: {
          'amount': amount,
          'paidAt': paidAt.toUtc().toIso8601String(),
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        });
        return PromissoryNote.fromJson(res.data!);
      });

  /// Cambia monto o vencimiento de un pagaré pendiente o vencido (permiso contracts.manage).
  Future<PromissoryNote> updateNote(String noteId, {double? amount, DateTime? dueDate}) => apiCall(() async {
        final res = await _dio.patch<Map<String, dynamic>>('/promissory-notes/$noteId', data: {
          'amount': ?amount,
          if (dueDate != null) 'dueDate': _day(dueDate),
        });
        return PromissoryNote.fromJson(res.data!);
      });

  /// Corrige un pago registrado (solo administración: payments.correct).
  Future<PromissoryNote> correctPayment(String noteId, String paymentId, {double? amount, DateTime? paidAt, String? receiptFolio, String? notes}) =>
      apiCall(() async {
        final res = await _dio.patch<Map<String, dynamic>>('/promissory-notes/$noteId/payments/$paymentId', data: {
          'amount': ?amount,
          if (paidAt != null) 'paidAt': paidAt.toUtc().toIso8601String(),
          if (receiptFolio != null) 'receiptFolio': receiptFolio.trim(),
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        });
        return PromissoryNote.fromJson(res.data!);
      });

  /// Anula un pago: el pagaré vuelve a pendiente o vencido (solo administración).
  Future<PromissoryNote> voidPayment(String noteId, String paymentId, String reason) => apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>('/promissory-notes/$noteId/payments/$paymentId/void', data: {'reason': reason.trim()});
        return PromissoryNote.fromJson(res.data!);
      });

  /// Pagaré adicional del contrato vigente (contracts.manage). El monto es un número.
  Future<PromissoryNote> createNote(String contractId, {required double amount, required DateTime dueDate}) => apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>('/promissory-notes', data: {'contractId': contractId, 'amount': amount, 'dueDate': _day(dueDate)});
        return PromissoryNote.fromJson(res.data!);
      });

  /// Cancela un pagaré que no se cobrará (sin pago registrado); queda en el historial.
  Future<PromissoryNote> cancelNote(String noteId, String reason) => apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>('/promissory-notes/$noteId/cancel', data: {'reason': reason.trim()});
        return PromissoryNote.fromJson(res.data!);
      });

  /// Contrato de renta: la persona pasa a inquilina, se generan sus pagarés y la casa queda rentada (contracts.manage).
  /// Devuelve el id del contrato (para subirle el PDF firmado y los pagarés).
  Future<String> createContract({
    required String propertyId,
    required String clientId,
    required DateTime start,
    required DateTime end,
    required double monthlyRent,
    required int paymentDay,
    double? deposit,
  }) =>
      apiCall(() async {
        final res = await _dio.post<Map<String, dynamic>>('/contracts', data: {
          'propertyId': propertyId,
          'clientId': clientId,
          'startDate': _day(start),
          'endDate': _day(end),
          'monthlyRent': monthlyRent,
          'paymentDay': paymentDay,
          'deposit': ?deposit,
        });
        return res.data!['id'] as String;
      });

  static String _day(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
