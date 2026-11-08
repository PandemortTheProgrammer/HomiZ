import '../services/utils/formatters.dart';

/// Casa que el asesor propone en una solicitud.
class ProposedHouse {
  const ProposedHouse({
    required this.id,
    this.note,
    required this.propertyId,
    required this.name,
    required this.zone,
    this.city,
    required this.operation,
    required this.price,
    required this.rec,
    required this.banos,
    this.photo,
  });

  factory ProposedHouse.fromJson(Map<String, dynamic> j) {
    final p = j['property'] as Map<String, dynamic>;
    return ProposedHouse(
      id: j['id'] as String,
      note: j['note'] as String?,
      propertyId: p['id'] as String,
      name: p['name'] as String,
      zone: p['zone'] as String? ?? '',
      city: p['city'] as String?,
      operation: p['operation'] as String? ?? 'renta',
      price: (p['price'] as num?)?.toDouble() ?? 0,
      rec: (p['rec'] as num?)?.toInt() ?? 0,
      banos: (p['banos'] as num?)?.toDouble() ?? 0,
      photo: p['photo'] as String?,
    );
  }

  final String id;
  final String? note;
  final String propertyId;
  final String name;
  final String zone;
  final String? city;
  final String operation;
  final double price;
  final int rec;
  final double banos;
  final String? photo;
}

/// Cita agendada desde una solicitud (solo la ve el personal).
class RequestAppointment {
  const RequestAppointment({required this.id, required this.code, required this.scheduledAt, required this.status, this.propertyId, required this.propertyName, this.broker});

  factory RequestAppointment.fromJson(Map<String, dynamic> j) => RequestAppointment(
    id: j['id'] as String,
    code: j['code'] as String,
    scheduledAt: Fmt.parse(j['scheduledAt'] as String),
    status: j['status'] as String,
    propertyId: (j['property'] as Map<String, dynamic>?)?['id'] as String?,
    propertyName: (j['property'] as Map<String, dynamic>?)?['name'] as String? ?? '',
    broker: j['broker'] as String?,
  );

  final String id;
  final String code;
  final DateTime scheduledAt;
  final String status;
  final String? propertyId;
  final String propertyName;

  /// Por confirmar o confirmada: «Agendar» la reprograma en lugar de crear otra.
  bool get isActive => status == 'por-confirmar' || status == 'confirmada';
  final String? broker;
}

/// Solicitud: «Busco casa» de la app o formulario del sitio, con la respuesta y las casas propuestas.
class LeadRequest {
  const LeadRequest({
    required this.id,
    required this.folio,
    required this.reason,
    required this.status,
    required this.statusLabel,
    this.name,
    this.email,
    this.phone,
    this.message,
    this.propertyId,
    this.propertyName,
    this.preferredDate,
    this.preferredTime,
    this.payload = const {},
    this.response,
    this.respondedBy,
    this.proposalCount = 0,
    this.proposals = const [],
    this.appointmentCount = 0,
    this.appointments = const [],
    this.others = const [],
    this.brokerId,
    this.brokerName,
    required this.createdAt,
  });

  /// Resumen de otra solicitud de la misma persona (en «others» la casa llega solo con su nombre).
  factory LeadRequest.summaryFromJson(Map<String, dynamic> j) => LeadRequest(
    id: j['id'] as String,
    folio: j['folio'] as String,
    reason: j['reason'] as String,
    status: j['status'] as String,
    statusLabel: j['statusLabel'] as String? ?? '',
    message: j['message'] as String?,
    propertyName: j['property'] as String?,
    payload: {for (final e in ((j['payload'] as Map?) ?? const {}).entries) e.key as String: '${e.value}'},
    createdAt: Fmt.parse(j['createdAt'] as String),
  );

  factory LeadRequest.fromJson(Map<String, dynamic> j) => LeadRequest(
    id: j['id'] as String,
    folio: j['folio'] as String,
    reason: j['reason'] as String,
    status: j['status'] as String,
    statusLabel: j['statusLabel'] as String? ?? '',
    name: j['name'] as String?,
    email: j['email'] as String?,
    phone: j['phone'] as String?,
    message: j['message'] as String?,
    propertyId: (j['property'] as Map<String, dynamic>?)?['id'] as String?,
    propertyName: (j['property'] as Map<String, dynamic>?)?['name'] as String?,
    preferredDate: j['preferredDate'] as String?,
    preferredTime: j['preferredTime'] as String?,
    payload: {for (final e in ((j['payload'] as Map?) ?? const {}).entries) e.key as String: '${e.value}'},
    response: j['response'] as String?,
    respondedBy: j['respondedBy'] as String?,
    proposalCount: (j['proposalCount'] as num?)?.toInt() ?? 0,
    proposals: [for (final p in (j['proposals'] as List? ?? const [])) ProposedHouse.fromJson(p as Map<String, dynamic>)],
    appointmentCount: (j['appointmentCount'] as num?)?.toInt() ?? 0,
    appointments: [for (final a in (j['appointments'] as List? ?? const [])) RequestAppointment.fromJson(a as Map<String, dynamic>)],
    others: [for (final o in (j['others'] as List? ?? const [])) LeadRequest.summaryFromJson(o as Map<String, dynamic>)],
    brokerId: (j['broker'] as Map<String, dynamic>?)?['id'] as String?,
    brokerName: (j['broker'] as Map<String, dynamic>?)?['name'] as String?,
    createdAt: Fmt.parse(j['createdAt'] as String),
  );

  final String id;
  final String folio;
  final String reason;
  final String status;
  final String statusLabel;
  // Solo para el personal:
  final String? name;
  final String? email;
  final String? phone;
  final String? message;
  final String? propertyId;
  final String? propertyName;

  /// Fecha y hora que pidió para la visita (YYYY-MM-DD y HH:MM), si las dio
  final String? preferredDate;
  final String? preferredTime;
  final Map<String, String> payload;
  final String? response;
  final String? respondedBy;
  final int proposalCount;
  final List<ProposedHouse> proposals;
  final int appointmentCount;
  final List<RequestAppointment> appointments;

  /// Otras solicitudes de la misma persona (solo el personal)
  final List<LeadRequest> others;

  /// Broker que la atiende (lo asigna administración; null = sin asignar). Solo el personal.
  final String? brokerId;
  final String? brokerName;
  final DateTime createdAt;

  static const reasons = {'visita': 'Visita a una casa', 'rentar': 'Quiero rentar', 'comprar': 'Quiero comprar', 'publicar': 'Publicar mi casa', 'otro': 'Otro motivo'};

  String get reasonLabel => reasons[reason] ?? reason;

  /// «$15,000 · 3 rec. · Puerto Morelos»
  String get summary => [
    payload['presupuesto'],
    if ((payload['recamaras'] ?? '').isNotEmpty) '${payload['recamaras']} rec.',
    payload['zona'] ?? payload['inmueble_zona'],
  ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
}

/// Mensaje de la solicitud (cliente ↔ asesor). Para el cliente, el personal aparece como «Zugar».
class RequestMessage {
  const RequestMessage({required this.id, required this.body, required this.fromStaff, required this.mine, required this.sender, required this.createdAt});

  factory RequestMessage.fromJson(Map<String, dynamic> j) => RequestMessage(
    id: j['id'] as String,
    body: j['body'] as String,
    fromStaff: j['fromStaff'] as bool? ?? false,
    mine: j['mine'] as bool? ?? false,
    sender: j['sender'] as String? ?? '',
    createdAt: Fmt.parse(j['createdAt'] as String),
  );

  final String id;
  final String body;
  final bool fromStaff;
  final bool mine;
  final String sender;
  final DateTime createdAt;
}
