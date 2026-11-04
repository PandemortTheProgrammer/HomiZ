import 'package:freezed_annotation/freezed_annotation.dart';

import '../services/utils/formatters.dart';
import '../services/utils/json_converters.dart';

part 'appointment.freezed.dart';
part 'appointment.g.dart';

/// Cita. El cliente también recibe a su asesor (broker) con teléfono y correo: el contacto es mutuo.
@freezed
abstract class Appointment with _$Appointment {
  const factory Appointment({
    required String id,
    required String code,
    required AppointmentProperty property,
    @LocalDate() required DateTime scheduledAt,
    @Default(60) int durationMin,
    required String status,

    /// Por confirmar: de quién se espera que acepte la fecha («staff» o «client»): la otra parte de quien la propuso
    String? awaiting,

    /// Quien ve la cita puede aceptar la fecha (la propuso la otra parte)
    @Default(false) bool canAccept,
    String? note,
    String? reason,

    /// Formulario que llenó la persona: el de la solicitud de la cita o su solicitud más reciente
    /// (mismo formato que una solicitud; «linked» = salió de esa solicitud).
    Map<String, dynamic>? lead,

    /// Asesor de la cita (lo ven el cliente y el personal)
    PersonRef? broker,
    // Solo para el personal:
    PersonRef? client,
    String? confirmedBy,
  }) = _Appointment;

  const Appointment._();

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);

  /// Se puede cancelar mientras esté por confirmar o confirmada y no haya pasado.
  bool get isActive => (status == 'por-confirmar' || status == 'confirmada') && scheduledAt.isAfter(Fmt.now());

  bool get acceptsMessages => status != 'cancelada' && status != 'rechazada';
}

@freezed
abstract class AppointmentProperty with _$AppointmentProperty {
  const factory AppointmentProperty({
    required String id,
    String? code,
    required String name,
    String? zone,
    String? address,
    String? photo,

    /// Punto exacto: al cliente le llega cuando la cita está confirmada (o la visita ya se hizo)
    double? lat,
    double? lng,
    @Default(true) bool exactLocation,
  }) = _AppointmentProperty;

  const AppointmentProperty._();

  factory AppointmentProperty.fromJson(Map<String, dynamic> json) => _$AppointmentPropertyFromJson(json);

  bool get hasPoint => exactLocation && lat != null && lng != null;
}

/// Persona ligada a un registro (cliente o broker) con sus datos de contacto.
/// [code] es el ID visible de la persona (CLI-0004) y [kind] «cliente» o «inquilino» (solo para el personal).
@freezed
abstract class PersonRef with _$PersonRef {
  const factory PersonRef({required String id, required String name, String? phone, String? email, String? code, String? kind}) = _PersonRef;

  factory PersonRef.fromJson(Map<String, dynamic> json) => _$PersonRefFromJson(json);
}

/// Mensaje del chat de la cita (cada quien ve el nombre de la otra persona).
@freezed
abstract class AppointmentMessage with _$AppointmentMessage {
  const factory AppointmentMessage({required String id, required bool mine, required String sender, required bool fromStaff, required String body, @LocalDate() required DateTime createdAt}) =
      _AppointmentMessage;

  factory AppointmentMessage.fromJson(Map<String, dynamic> json) => _$AppointmentMessageFromJson(json);
}
