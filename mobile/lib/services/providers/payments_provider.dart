import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_provider.dart';
import 'dashboard_provider.dart';
import '../../models/payment_models.dart';
import '../repositories/payments_repository.dart';

/// Pagarés con resumen. Cliente: `null` (su contrato vigente). Personal: el id del contrato de la casa.
final notesProvider = FutureProvider.family<NotesPage, String?>((ref, contractId) {
  ref.watch(sessionProvider.select((s) => s.value?.id));
  return ref.watch(paymentsRepositoryProvider).notes(contractId: contractId);
});

/// Recibos y fichas. Cliente: `null` (su casa). Personal: el id de la casa.
final receiptsProvider = FutureProvider.family<List<Receipt>, String?>((ref, propertyId) {
  ref.watch(sessionProvider.select((s) => s.value?.id));
  return ref.watch(paymentsRepositoryProvider).receipts(propertyId: propertyId);
});

/// Pagarés vencidos de las casas del personal.
final overdueNotesProvider = FutureProvider<List<PromissoryNote>>((ref) async {
  ref.watch(sessionProvider.select((s) => s.value?.id));
  return (await ref.watch(paymentsRepositoryProvider).notes(status: const ['overdue'])).notes;
});

/// Personal: todos sus pagarés (administración: de todas las casas), para «Pagos y pagarés».
final allNotesProvider = FutureProvider<List<PromissoryNote>>((ref) async {
  ref.watch(sessionProvider.select((s) => s.value?.id));
  return (await ref.watch(paymentsRepositoryProvider).notes()).notes;
});

final paymentActionsProvider = Provider<PaymentActions>(PaymentActions.new);

class PaymentActions {
  PaymentActions(this._ref);

  final Ref _ref;

  /// Devuelve el folio que generó el servidor.
  Future<String?> register(PromissoryNote note, {required DateTime paidAt, String? notes}) async {
    final paid = await _ref.read(paymentsRepositoryProvider).registerPayment(note.id, amount: note.amount, paidAt: paidAt, notes: notes);
    _refresh();
    return paid.payment?.receiptFolio;
  }

  Future<void> updateNote(PromissoryNote note, {double? amount, DateTime? dueDate}) async {
    await _ref.read(paymentsRepositoryProvider).updateNote(note.id, amount: amount, dueDate: dueDate);
    _refresh();
  }

  Future<void> correct(PromissoryNote note, {double? amount, DateTime? paidAt, String? receiptFolio, String? notes}) async {
    await _ref.read(paymentsRepositoryProvider).correctPayment(note.id, note.payment!.id, amount: amount, paidAt: paidAt, receiptFolio: receiptFolio, notes: notes);
    _refresh();
  }

  Future<void> voidPayment(PromissoryNote note, String reason) async {
    await _ref.read(paymentsRepositoryProvider).voidPayment(note.id, note.payment!.id, reason);
    _refresh();
  }

  Future<PromissoryNote> createNote(String contractId, {required double amount, required DateTime dueDate}) async {
    final n = await _ref.read(paymentsRepositoryProvider).createNote(contractId, amount: amount, dueDate: dueDate);
    _refresh();
    return n;
  }

  Future<void> cancelNote(PromissoryNote note, String reason) async {
    await _ref.read(paymentsRepositoryProvider).cancelNote(note.id, reason);
    _refresh();
  }

  void _refresh() {
    _ref.invalidate(notesProvider);
    _ref.invalidate(overdueNotesProvider);
    _ref.invalidate(allNotesProvider);
    _ref.invalidate(staffDashboardProvider);
  }
}
