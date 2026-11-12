import 'package:freezed_annotation/freezed_annotation.dart';

import '../services/utils/json_converters.dart';

part 'payment_models.freezed.dart';
part 'payment_models.g.dart';

/// Pagaré mensual del contrato.
@freezed
abstract class PromissoryNote with _$PromissoryNote {
  const factory PromissoryNote({
    required String id,
    required int number,
    required String label,
    required double amount,
    @LocalDate() required DateTime dueDate,
    required String status,
    NotePayment? payment,
    String? proofDocumentId,
    // PDF del pagaré firmado.
    String? documentId,
    // Fotos de los sellos (entrega en físico y digital).
    @Default(<NoteStamp>[]) List<NoteStamp> stamps,
    NoteRef? property,
    // Solo para el personal:
    NoteRef? client,
  }) = _PromissoryNote;

  const PromissoryNote._();

  bool get isPayable => status == 'pending' || status == 'overdue';

  factory PromissoryNote.fromJson(Map<String, dynamic> json) => _$PromissoryNoteFromJson(json);
}

/// Foto del sello de un pagaré.
@freezed
abstract class NoteStamp with _$NoteStamp {
  const factory NoteStamp({required String id, required String name, @LocalDate() required DateTime createdAt}) = _NoteStamp;

  factory NoteStamp.fromJson(Map<String, dynamic> json) => _$NoteStampFromJson(json);
}

@freezed
abstract class NoteRef with _$NoteRef {
  const factory NoteRef({required String id, required String name}) = _NoteRef;

  factory NoteRef.fromJson(Map<String, dynamic> json) => _$NoteRefFromJson(json);
}

@freezed
abstract class NotePayment with _$NotePayment {
  const factory NotePayment({
    required String id,
    required double amount,
    @LocalDate() required DateTime paidAt,
    String? receiptFolio,
    String? notes,
    // Solo para el personal:
    String? registeredBy,
  }) = _NotePayment;

  factory NotePayment.fromJson(Map<String, dynamic> json) => _$NotePaymentFromJson(json);
}

/// «Estado de pagos»: pagados X de N, faltan Y por $Z y el próximo pagaré.
@freezed
abstract class NotesSummary with _$NotesSummary {
  const factory NotesSummary({
    required int total,
    required int paid,
    required int remaining,
    @Default(0) double remainingAmount,
    NextNote? next,
  }) = _NotesSummary;

  const NotesSummary._();

  factory NotesSummary.fromJson(Map<String, dynamic> json) => _$NotesSummaryFromJson(json);

  double get progress => total == 0 ? 0 : paid / total;
}

@freezed
abstract class NextNote with _$NextNote {
  const factory NextNote({required int number, @LocalDate() required DateTime dueDate, required double amount}) = _NextNote;

  factory NextNote.fromJson(Map<String, dynamic> json) => _$NextNoteFromJson(json);
}

/// Recibo de luz/agua (`bill`) o ficha de cobro (`charge_slip`).
@freezed
abstract class Receipt with _$Receipt {
  const factory Receipt({
    required String id,
    required String kind,
    required String concept,
    String? periodLabel,
    required double amount,
    @LocalDateOrNull() DateTime? dueDate,
    @LocalDateOrNull() DateTime? paidAt,
    required String status,
    String? documentId,
  }) = _Receipt;

  factory Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);
}
