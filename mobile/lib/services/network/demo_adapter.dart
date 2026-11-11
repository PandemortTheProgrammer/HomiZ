import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Modo demo (--dart-define=DEMO=true): la app funciona sin API. Este adaptador contesta como la API,
/// con datos de ejemplo guardados en memoria; las pantallas, modelos y repositorios no cambian.
/// Se entra con cualquier contraseña: un correo con «broker» o «admin» abre ese perfil; otro correo, el de cliente.
/// La contraseña «incorrecta» muestra el error de inicio de sesión. Al cerrar la app los cambios se pierden.
class DemoAdapter implements HttpClientAdapter {
  static const _clientId = 'demo-cliente';
  static const _brokerId = 'demo-broker';
  static const _adminId = 'demo-admin';
  static const _permissions = ['appointments.manage', 'leads.manage', 'clients.manage', 'properties.read_all', 'properties.manage', 'documents.manage', 'payments.register', 'maintenance.manage'];

  var _seq = 30;
  Map<String, Object?> _client = {
    'id': _clientId,
    'name': 'Laura Méndez',
    'email': 'cliente@demo.mx',
    'phone': '998 123 4567',
    'type': 'client',
    'initials': 'LM',
    'client': {'id': 'demo-expediente', 'kind': 'inquilino', 'propertyId': 'casa-5', 'hasPets': false, 'petsCount': 0, 'occupants': 2},
  };

  static const Map<String, Object?> _broker = {'id': _brokerId, 'name': 'Mariana Solís', 'email': 'broker@demo.mx', 'phone': '998 100 0002', 'type': 'staff', 'initials': 'MS', 'roles': ['broker'], 'permissions': _permissions};
  static const Map<String, Object?> _admin = {'id': _adminId, 'name': 'Lucía Méndez', 'email': 'admin@demo.mx', 'phone': '998 100 0001', 'type': 'staff', 'initials': 'LM', 'roles': ['admin', 'owner'], 'permissions': [..._permissions, 'contracts.manage', 'users.manage', 'payments.correct', 'documents.delete']};

  static Map<String, Object?> _house(String id, String code, String name, String zone, String operation, num price, int rec, num banos, num m2) => {
    'id': id,
    'code': code,
    'slug': name.toLowerCase().replaceAll(' ', '-'),
    'name': name,
    'type': 'Casa',
    'description': 'Casa de ejemplo en $zone, Cancún.',
    'operation': operation,
    'price': price,
    'rec': rec,
    'banos': banos,
    'm2': m2,
    'est': 2,
    'petsAllowed': true,
    'address': 'Calle Ejemplo 12, $zone',
    'city': 'Cancún, Quintana Roo',
    'zone': zone,
    'status': 'disponible',
    'visibility': 'publicada',
    'amenities': ['Alberca', 'Jardín'],
    'photos': <Object>[],
    'broker': {'id': _brokerId, 'name': 'Mariana Solís'},
  };

  final _houses = [
    _house('casa-1', 'ZUG-001', 'Casa Ceiba', 'Arbolada', 'renta', 28000, 3, 2.5, 180),
    _house('casa-2', 'ZUG-002', 'Casa Zapote', 'Supermanzana 50', 'renta', 24000, 2, 2, 120),
    _house('casa-3', 'ZUG-003', 'Casa Chaká', 'Residencial Palmaris', 'renta', 32000, 3, 3, 210),
    _house('casa-4', 'ZUG-004', 'Casa Nativa', 'Aqua Residencial', 'venta', 4200000, 4, 3.5, 260),
  ];

  late final _requests = <Map<String, Object?>>[
    {
      'id': 'sol-1',
      'folio': 'Z-10001',
      'reason': 'rentar',
      'status': 'en_seguimiento',
      'statusLabel': 'En seguimiento',
      'name': 'Laura Méndez',
      'email': 'cliente@demo.mx',
      'phone': '998 123 4567',
      'message': 'Cerca de escuelas y con jardín.',
      'payload': {'operacion': 'renta', 'zona': 'Arbolada', 'presupuesto': r'$30,000 MXN / mes', 'presupuesto_max': 30000, 'recamaras': '3', 'banos': '2', 'personas': '3', 'mascotas': 'no', 'origen': 'app'},
      'response': 'Te propongo Casa Ceiba: tiene jardín y está cerca de escuelas.',
      'respondedBy': 'Mariana Solís',
      'proposals': [_proposal('prop-1', _houses[0], 'Tiene jardín')],
      'proposalCount': 1,
      'broker': {'id': _brokerId, 'name': 'Mariana Solís'},
      'ownerId': _clientId,
      'createdAt': _ago(3),
    },
    {
      'id': 'sol-2',
      'folio': 'Z-10002',
      'reason': 'comprar',
      'status': 'nuevo',
      'statusLabel': 'Recibida',
      'name': 'Jorge Pech',
      'email': 'jorge@demo.mx',
      'phone': '998 555 0128',
      'message': null,
      'payload': {'operacion': 'compra', 'zona': 'Centro', 'presupuesto': r'Hasta $5,000,000 MXN', 'presupuesto_max': 5000000, 'recamaras': '3', 'forma_pago': 'Infonavit', 'origen': 'app'},
      'proposals': <Object>[],
      'proposalCount': 0,
      'broker': {'id': _brokerId, 'name': 'Mariana Solís'},
      'ownerId': 'otra-persona',
      'createdAt': _ago(1),
    },
    {
      'id': 'sol-3',
      'folio': 'Z-10003',
      'reason': 'publicar',
      'status': 'nuevo',
      'statusLabel': 'Recibida',
      'name': 'Ana Ruiz',
      'email': 'ana@demo.mx',
      'phone': '998 555 0199',
      'message': null,
      'payload': {'inmueble_tipo': 'Casa', 'inmueble_operacion': 'renta', 'inmueble_zona': 'Residencial Cumbres', 'inmueble_recamaras': '3', 'inmueble_banos': '2', 'inmueble_m2': 180, 'origen': 'app'},
      'proposals': <Object>[],
      'proposalCount': 0,
      'broker': null,
      'ownerId': 'otra-persona',
      'createdAt': _now(),
    },
  ];

  late final _appointments = <Map<String, Object?>>[
    {
      'id': 'cita-1',
      'code': 'CIT-019',
      'houseId': 'casa-1',
      'scheduledAt': _ahead(2),
      'status': 'confirmada',
      'ownerId': _clientId,
      'note': 'Quiero conocer el jardín.',
    },
    {
      'id': 'cita-2',
      'code': 'CIT-020',
      'houseId': 'casa-2',
      'scheduledAt': _ahead(4),
      'status': 'por-confirmar',
      'awaiting': 'staff',
      'ownerId': 'otra-persona',
    },
  ];

  final _messages = <String, List<Map<String, Object?>>>{
    'sol-1': [
      {'id': 'm1', 'body': '¿Qué días puedes visitar?', 'fromStaff': true, 'sender': 'Mariana Solís', 'createdAt': _ago(1)},
    ],
    'cita-1': [
      {'id': 'm2', 'body': 'Te espero en la entrada de la casa.', 'fromStaff': true, 'sender': 'Mariana Solís', 'createdAt': _ago(1)},
    ],
  };

  late final _notifications = <Map<String, Object?>>[
    {'id': 'av-1', 'type': 'appointment_confirmed', 'title': 'Cita confirmada', 'message': 'Tu visita a Casa Ceiba quedó confirmada.', 'entity': 'appointment', 'entityId': 'cita-1', 'read': false, 'sentAt': _ago(1)},
    {'id': 'av-2', 'type': 'lead_update', 'title': 'Te proponemos una casa', 'message': 'Tu asesor te propone Casa Ceiba.', 'entity': 'lead', 'entityId': 'sol-1', 'read': true, 'sentAt': _ago(2)},
  ];

  static String _ago(int days) => DateTime.now().subtract(Duration(days: days)).toUtc().toIso8601String();
  static String _ahead(int days) {
    final d = DateTime.now().add(Duration(days: days));
    return DateTime.utc(d.year, d.month, d.day, 15, 30).toIso8601String(); // 10:30 a.m. en Cancún
  }
  static String _now() => DateTime.now().toUtc().toIso8601String();

  static Map<String, Object?> _proposal(String id, Map<String, Object?> house, String? note) => {'id': id, 'note': note, 'property': house};

  static (int, Object?) _error(int status, String code, String message) => (status, {'error': {'code': code, 'message': message}});

  Map<String, Object?> _userOf(String role) => switch (role) { 'broker' => _broker, 'admin' => _admin, _ => _client };
  String _roleOf(RequestOptions o) => '${o.headers['Authorization'] ?? o.headers['authorization'] ?? ''}'.replaceFirst('Bearer demo-', '');

  Map<String, Object?> _session(String role) => {'accessToken': 'demo-$role', 'refreshToken': 'demo-renovar-$role-0000000000', 'user': _userOf(role)};

  Map<String, Object?> _houseById(Object? id) => _houses.firstWhere((h) => h['id'] == id, orElse: () => _houses.first);

  /// Cita como la ve cada perfil: el cliente nunca recibe el campo «client».
  Map<String, Object?> _appointment(Map<String, Object?> a, String role) {
    final h = _houseById(a['houseId']);
    final staff = role != 'client';
    final confirmed = a['status'] == 'confirmada' || a['status'] == 'realizada';
    return {
      ...a,
      'property': {'id': h['id'], 'code': h['code'], 'name': h['name'], 'zone': h['zone'], 'address': confirmed || staff ? h['address'] : null, 'lat': 21.1619, 'lng': -86.8515, 'exactLocation': confirmed || staff},
      'broker': {'id': _brokerId, 'name': 'Mariana Solís', 'phone': '998 100 0002', 'email': 'broker@demo.mx'},
      if (staff) 'client': {'id': 'demo-expediente', 'name': a['ownerId'] == _clientId ? _client['name'] : 'Jorge Pech', 'phone': '998 123 4567', 'email': 'cliente@demo.mx', 'code': 'CLI-0001', 'kind': 'cliente'},
      'canAccept': a['status'] == 'por-confirmar' && a['awaiting'] == (staff ? 'staff' : 'client'),
    };
  }

  List<Map<String, Object?>> _visibleRequests(String role, Map<String, dynamic> q) {
    final mine = switch (role) {
      'client' => _requests.where((r) => r['ownerId'] == _clientId),
      'broker' => _requests.where((r) => (r['broker'] as Map?)?['id'] == _brokerId),
      _ => _requests,
    };
    return mine.where((r) => (q['unassigned'] != 'true' || r['broker'] == null) && (q['status'] == null || r['status'] == q['status'])).toList();
  }

  List<Map<String, Object?>> _visibleAppointments(String role) => [
    for (final a in _appointments)
      if (role != 'client' || a['ownerId'] == _clientId) _appointment(a, role),
  ];

  List<Map<String, Object?>> _chat(String id, String role) => [
    for (final m in _messages[id] ?? const <Map<String, Object?>>[]) {...m, 'mine': (m['fromStaff'] == true) == (role != 'client'), 'sender': role == 'client' && m['fromStaff'] == true ? 'Zugar' : m['sender']},
  ];

  (int, Object?) _send(String id, String role, Object? body) {
    (_messages[id] ??= []).add({'id': 'm${++_seq}', 'body': (body as Map)['body'], 'fromStaff': role != 'client', 'sender': _userOf(role)['name'], 'createdAt': _now()});
    return (201, {'data': _chat(id, role)});
  }

  void _notify(String title, String message, String entity, String id) =>
      _notifications.insert(0, {'id': 'av-${++_seq}', 'type': 'demo', 'title': title, 'message': message, 'entity': entity, 'entityId': id, 'read': false, 'sentAt': _now()});

  Map<String, Object?> _newAppointment(String houseId, String at, String awaiting, String ownerId, {String? note}) {
    final a = {'id': 'cita-${++_seq}', 'code': 'CIT-0$_seq', 'houseId': houseId, 'scheduledAt': at, 'status': 'por-confirmar', 'awaiting': awaiting, 'ownerId': ownerId, 'note': note};
    _appointments.insert(0, a);
    return a;
  }

  (int, Object?) _createRequest(Map<String, Object?> d) {
    final id = 'sol-${++_seq}';
    final slug = d['propertySlug'], code = d['propertyCode'];
    final house = _houses.where((h) => h['slug'] == slug || h['code'] == code).firstOrNull;
    final r = <String, Object?>{
      'id': id,
      'folio': 'Z-10$_seq',
      'reason': d['reason'],
      'status': 'nuevo',
      'statusLabel': 'Recibida',
      'name': _client['name'],
      'email': _client['email'],
      'phone': _client['phone'],
      'message': d['message'],
      'property': house == null ? null : {'id': house['id'], 'name': house['name']},
      'payload': {...(d['payload'] as Map? ?? const {}), 'origen': 'app'},
      'proposals': <Object>[],
      'proposalCount': 0,
      'broker': null,
      'ownerId': _clientId,
      'createdAt': _now(),
    };
    _requests.insert(0, r);
    if (house != null && d['preferredDate'] != null && d['preferredTime'] != null) {
      _newAppointment(house['id']! as String, '${d['preferredDate']}T${d['preferredTime']}:00-05:00', 'staff', _clientId);
    }
    return (201, r);
  }

  (int, Object?) _act(String id, String action, String role, Map<dynamic, dynamic> d) {
    final a = _appointments.firstWhere((x) => x['id'] == id);
    switch (action) {
      case 'confirm':
        a..['status'] = 'confirmada'..['awaiting'] = null;
      case 'reject':
        a..['status'] = 'rechazada'..['reason'] = d['reason'];
      case 'cancel':
        a..['status'] = 'cancelada'..['reason'] = d['reason'];
      case 'complete':
        a['status'] = 'realizada';
      case 'reschedule':
        a..['scheduledAt'] = d['scheduledAt']..['status'] = 'por-confirmar'..['awaiting'] = role == 'client' ? 'staff' : 'client';
    }
    _notify('Cita ${a['code']}', 'La cita cambió a ${a['status']}.', 'appointment', id);
    return (200, _appointment(a, role));
  }

  (int, Object?) _lead(String id, String method, String? tail, String role, Object? data) {
    final r = _requests.firstWhere((x) => x['id'] == id);
    final d = data is Map ? data : const {};
    if (tail == 'messages') return method == 'GET' ? (200, {'data': _chat(id, role)}) : _send(id, role, data);
    if (tail == 'broker') {
      final b = _userOf('broker');
      r['broker'] = {'id': b['id'], 'name': b['name']};
      _notify('Te asignaron una solicitud', 'Folio ${r['folio']}.', 'lead', id);
      return (200, r);
    }
    if (tail == 'proposals') {
      final p = _proposal('prop-${++_seq}', _houseById(d['propertyId']), d['note'] as String?);
      final list = [...(r['proposals']! as List), p];
      r..['proposals'] = list..['proposalCount'] = list.length;
      return (201, r);
    }
    if (tail != null && tail.startsWith('proposals/')) {
      final list = [...(r['proposals']! as List)]..removeWhere((p) => (p as Map)['id'] == tail.split('/').last);
      r..['proposals'] = list..['proposalCount'] = list.length;
      return (200, r);
    }
    if (tail == 'appointment') {
      final a = _newAppointment(d['propertyId']! as String, d['scheduledAt']! as String, 'client', r['ownerId']! as String, note: d['note'] as String?);
      if (d['agreed'] == true) a['status'] = 'confirmada';
      r['appointments'] = [
        {'id': a['id'], 'code': a['code'], 'scheduledAt': a['scheduledAt'], 'status': a['status'], 'property': {'id': a['houseId'], 'name': _houseById(a['houseId'])['name']}, 'broker': 'Mariana Solís'},
      ];
      return (201, {'appointment': {'id': a['id'], 'code': a['code']}, 'lead': r});
    }
    if (method == 'PATCH') {
      if (d['status'] != null) r..['status'] = d['status']..['statusLabel'] = {'nuevo': 'Recibida', 'en_seguimiento': 'En seguimiento', 'cerrado': 'Cerrada'}[d['status']];
      if (d['response'] != null) r..['response'] = d['response']..['respondedBy'] = _userOf(role)['name'];
      return (200, r);
    }
    if (method == 'DELETE') {
      _requests.remove(r);
      return (204, null);
    }
    return (200, r);
  }

  /* ---------- Fases 9 a 12: casa rentada, pagos, reportes, proveedores y compras ---------- */

  static String _dia(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  final Map<String, Object?> _rentada = {
    ..._house('casa-5', 'ZUG-005', 'Casa Las Palmas', 'Zona Hotelera', 'renta', 12000, 3, 2, 170),
    'status': 'rentada',
    'address': 'Blvd. Kukulcán 45, Zona Hotelera',
  };

  late final _notas = _crearNotas();

  List<Map<String, Object?>> _crearNotas() {
    final hoy = DateTime.now();
    return [
      for (var i = 0; i < 12; i++)
        () {
          final vence = DateTime(hoy.year, hoy.month - 4 + i, 5);
          final pagada = i < 3;
          return <String, Object?>{
            'id': 'pagare-${i + 1}',
            'number': i + 1,
            'label': 'Pagaré ${(i + 1).toString().padLeft(2, '0')}',
            'amount': 12000,
            'dueDate': _dia(vence),
            'status': pagada ? 'paid' : (vence.isBefore(hoy) ? 'overdue' : 'pending'),
            'payment': pagada ? {'id': 'pago-${i + 1}', 'amount': 12000, 'paidAt': _dia(vence), 'receiptFolio': 'REC-ZUG-005-${(i + 1).toString().padLeft(2, '0')}', 'registeredBy': 'Lucía Méndez'} : null,
            'proofDocumentId': pagada ? 'doc-recibo-${i + 1}' : null,
            'stamps': <Object>[],
            'property': {'id': 'casa-5', 'name': 'Casa Las Palmas'},
            'client': {'id': 'demo-expediente', 'name': 'Laura Méndez'},
          };
        }(),
    ];
  }

  (int, Object?) _pagares(Map<String, dynamic> q) {
    final filtro = q['status'];
    final estados = filtro is List ? filtro.map((e) => '$e').toList() : (filtro == null ? const <String>[] : ['$filtro']);
    final lista = estados.isEmpty ? _notas : _notas.where((n) => estados.contains(n['status'])).toList();
    final pendientes = _notas.where((n) => n['status'] != 'paid').toList();
    final sig = pendientes.firstOrNull;
    return (200, {
      'data': lista,
      'summary': {
        'total': _notas.length,
        'paid': _notas.length - pendientes.length,
        'remaining': pendientes.length,
        'remainingAmount': pendientes.length * 12000,
        'next': sig == null ? null : {'number': sig['number'], 'dueDate': sig['dueDate'], 'amount': sig['amount']},
      },
    });
  }

  (int, Object?) _registrarPago(String id, Map<dynamic, dynamic> d) {
    final n = _notas.firstWhere((x) => x['id'] == id);
    n['status'] = 'paid';
    n['payment'] = {'id': 'pago-${++_seq}', 'amount': n['amount'], 'paidAt': d['paidAt'] ?? _dia(DateTime.now()), 'receiptFolio': 'REC-ZUG-005-${'${n['number']}'.padLeft(2, '0')}', 'notes': d['notes'], 'registeredBy': 'Demo'};
    return (201, n);
  }

  List<Map<String, Object?>> get _recibos => [
    for (final n in _notas.take(4))
      {
        'id': 'recibo-${n['id']}',
        'kind': n['status'] == 'paid' ? 'bill' : 'charge_slip',
        'concept': '${n['status'] == 'paid' ? 'Recibo' : 'Ficha de cobro'} · ${n['label']}',
        'amount': n['amount'],
        'dueDate': n['dueDate'],
        'status': n['status'],
      },
    {'id': 'recibo-luz', 'kind': 'bill', 'concept': 'Recibo de luz', 'periodLabel': 'sep-oct', 'amount': 1240, 'status': 'pending'},
    {'id': 'recibo-agua', 'kind': 'bill', 'concept': 'Recibo de agua', 'periodLabel': 'oct', 'amount': 415, 'status': 'paid'},
  ];

  (int, Object?) _expediente(String id, String role) {
    final propia = id == 'casa-5';
    final h = propia ? _rentada : _houseById(id);
    final hoy = DateTime.now();
    return (200, {
      'property': {'id': h['id'], 'name': h['name'], 'zone': h['zone'], 'address': h['address'], 'city': h['city'], 'rec': h['rec'], 'banos': h['banos'], 'm2': h['m2'], 'amenities': h['amenities'], 'status': h['status'], 'broker': {'name': 'Mariana Solís', 'phone': '998 100 0002'}},
      'contract': propia ? {'id': 'contrato-1', 'startDate': _dia(DateTime(hoy.year, hoy.month - 4, 5)), 'endDate': _dia(DateTime(hoy.year, hoy.month + 8, 4)), 'monthlyRent': 12000, 'paymentDay': 5, 'deposit': 12000, 'status': 'active'} : null,
      'sections': propia
          ? [
              {'key': 'contract', 'title': 'Contrato de renta', 'subtitle': 'Vigente', 'documentIds': ['doc-contrato']},
              {'key': 'deposit', 'title': 'Depósito en garantía', 'subtitle': r'$12,000 · comprobante', 'documentIds': ['doc-deposito']},
              {'key': 'delivery', 'title': 'Ficha de entrega', 'subtitle': '12 fotos · llaves y estado', 'documentIds': ['doc-entrega']},
              {'key': 'documents', 'title': 'Documentos', 'subtitle': 'Reglamento y anexos · 1 archivo', 'documentIds': ['doc-reglamento']},
            ]
          : <Object>[],
      'documents': propia
          ? [
              for (final (i, n) in const ['Contrato de renta', 'Depósito', 'Ficha de entrega', 'Reglamento'].indexed)
                {'id': const ['doc-contrato', 'doc-deposito', 'doc-entrega', 'doc-reglamento'][i], 'type': const ['contract', 'deposit', 'delivery_sheet', 'other'][i], 'name': n, 'mime': 'application/pdf', 'createdAt': _dia(hoy), 'visibleToClient': true},
            ]
          : <Object>[],
      'utilities': propia ? {'reminderDay': 5, 'electricity': {'company': 'CFE', 'serviceNumber': '402 180 556 901', 'app': 'CFE Contigo', 'url': 'https://www.cfe.mx'}, 'water': {'company': 'Aguakan', 'serviceNumber': '0077 3391 0215', 'app': 'Aguakan', 'url': 'https://www.aguakan.com'}} : null,
      'broker': {'name': 'Mariana Solís', 'phone': '998 100 0002', 'email': 'broker@demo.mx'},
      'tenant': propia && role != 'client' ? {'id': 'demo-expediente', 'name': 'Laura Méndez', 'phone': '998 123 4567', 'email': 'cliente@demo.mx'} : null,
    });
  }

  late final _reportes = <Map<String, Object?>>[_reporte('Fuga en el baño', 'Gotea la llave del lavabo.', 'Plomería', 'alta', 'in_repair', 'En reparación')];

  Map<String, Object?> _reporte(String titulo, String detalle, String categoria, String prioridad, String estado, String etiqueta) => {
    'id': 'reporte-${++_seq}',
    'property': {'id': 'casa-5', 'code': 'ZUG-005', 'name': 'Casa Las Palmas'},
    'title': titulo,
    'description': detalle,
    'category': categoria,
    'priority': prioridad,
    'subtitle': '$categoria - prioridad $prioridad',
    'status': estado,
    'statusLabel': etiqueta,
    'provider': estado == 'in_repair' ? {'id': 'prov-1', 'name': 'Plomería Caribe', 'specialty': 'Plomería', 'phone': '998 200 0101'} : null,
    'createdAt': _now(),
    'timeline': <Map<String, Object?>>[
      {'id': 't${++_seq}', 'status': estado, 'statusLabel': etiqueta, 'comment': 'Reporte de ejemplo.', 'author': 'Demo', 'createdAt': _now()},
    ],
    'photos': {'before': <Object>[], 'after': <Object>[]},
  };

  (int, Object?) _listaReportes(Map<String, dynamic> q) {
    final filtro = q['status'];
    final estados = filtro is List ? filtro.map((e) => '$e').toList() : (filtro == null ? const <String>[] : ['$filtro']);
    return (200, {'data': estados.isEmpty ? _reportes : _reportes.where((r) => estados.contains(r['status'])).toList()});
  }

  (int, Object?) _actualizarReporte(String id, Map<dynamic, dynamic> d) {
    final r = _reportes.firstWhere((x) => x['id'] == id);
    const etiquetas = {'in_review': 'En revisión', 'in_repair': 'En reparación', 'resolved': 'Resuelto', 'cancelled': 'Cancelado'};
    final estado = '${d['status'] ?? r['status']}';
    r['status'] = estado;
    r['statusLabel'] = etiquetas[estado] ?? estado;
    (r['timeline']! as List).insert(0, {'id': 't${++_seq}', 'status': estado, 'statusLabel': r['statusLabel'], 'comment': d['comment'], 'author': 'Demo', 'createdAt': _now()});
    return (200, r);
  }

  static const _proveedores = [
    {'id': 'prov-1', 'name': 'Plomería Caribe', 'specialty': 'Plomería', 'phone': '998 200 0101', 'email': 'plomeria@demo.mx', 'zone': 'Cancún centro', 'notes': 'Atiende urgencias en fin de semana', 'active': true},
    {'id': 'prov-2', 'name': 'Electro Sureste', 'specialty': 'Electricidad', 'phone': '998 200 0102', 'email': 'electro@demo.mx', 'zone': 'Todo Cancún', 'active': true},
    {'id': 'prov-3', 'name': 'Albercas Nichupté', 'specialty': 'Albercas', 'phone': '998 200 0103', 'email': 'albercas@demo.mx', 'zone': 'Zona sur', 'notes': 'Mantenimiento mensual', 'active': true},
  ];

  static const _compras = [
    {'id': 'venta-1', 'folio': 'VEN-001', 'status': 'closed', 'saleDate': '2026-11-01', 'price': 4500000, 'property': {'name': 'Casa Kanán', 'code': 'ZUG-010', 'zone': 'Cumbres'}, 'paymentMethod': 'Crédito bancario', 'notary': 'Notaría 12, Cancún', 'hasDocument': true},
  ];

  (int, Object?) _dashboard(String role) {
    final mine = _visibleAppointments(role);
    if (role == 'client') {
      final next = mine.where((a) => a['status'] == 'por-confirmar' || a['status'] == 'confirmada').firstOrNull;
      return (200, {
        'nextAppointment': next == null ? null : {'id': next['id'], 'code': next['code'], 'propertyName': (next['property']! as Map)['name'], 'scheduledAt': next['scheduledAt'], 'status': next['status']},
        'property': {'id': 'casa-5', 'name': 'Casa Las Palmas', 'zone': 'Zona Hotelera'},
        'nextPayment': () {
          final n = _notas.where((x) => x['status'] != 'paid').firstOrNull;
          return n == null ? null : {'id': n['id'], 'number': n['number'], 'amount': n['amount'], 'dueDate': n['dueDate'], 'status': n['status']};
        }(),
        'openReports': () {
          final abiertos = _reportes.where((r) => r['status'] != 'resolved' && r['status'] != 'cancelled').toList();
          final r = abiertos.firstOrNull;
          return {'count': abiertos.length, 'latest': r == null ? null : {'id': r['id'], 'title': r['title'], 'status': r['status'], 'createdAt': r['createdAt']}};
        }(),
        'unreadNotifications': _notifications.where((n) => n['read'] == false).length,
      });
    }
    final pending = mine.where((a) => a['status'] == 'por-confirmar').toList();
    return (200, {
      'roles': _userOf(role)['roles'],
      'counts': {'overdueNotes': _notas.where((n) => n['status'] == 'overdue').length, 'openReports': _reportes.where((r) => r['status'] != 'resolved' && r['status'] != 'cancelled').length, 'appointmentsToConfirm': pending.length, 'appointmentsToday': 0, 'newLeads': _visibleRequests(role, {'status': 'nuevo'}).length},
      'overdueNotes': [
        for (final n in _notas.where((x) => x['status'] == 'overdue')) {'id': n['id'], 'number': n['number'], 'amount': n['amount'], 'dueDate': n['dueDate'], 'clientName': 'Laura Méndez', 'propertyName': 'Casa Las Palmas', 'propertyId': 'casa-5'},
      ],
      'newReports': [
        for (final r in _reportes.where((x) => x['status'] != 'resolved' && x['status'] != 'cancelled')) {'id': r['id'], 'title': r['title'], 'priority': r['priority'], 'propertyName': 'Casa Las Palmas', 'propertyId': 'casa-5', 'status': r['status'], 'createdAt': r['createdAt']},
      ],
      'pendingAppointments': [
        for (final a in pending) {'id': a['id'], 'code': a['code'], 'clientName': (a['client']! as Map)['name'], 'propertyName': (a['property']! as Map)['name'], 'scheduledAt': a['scheduledAt']},
      ],
    });
  }

  (int, Object?) _route(RequestOptions o) {
    final method = o.method, path = o.path, d = o.data is Map ? o.data as Map : const {};
    final role = _roleOf(o);
    switch ((method, path)) {
      case ('POST', '/auth/login'):
        if (d['password'] == 'incorrecta') return _error(401, 'INVALID_CREDENTIALS', 'Correo o contraseña incorrectos.');
        final email = '${d['email']}'.toLowerCase();
        return (200, _session(email.contains('broker') ? 'broker' : email.contains('admin') ? 'admin' : 'client'));
      case ('POST', '/auth/register'):
        _client = {..._client, 'name': d['name'], 'email': d['email'], 'phone': d['phone']};
        return (201, _session('client'));
      case ('POST', '/auth/refresh'):
        return (200, _session(role.isEmpty ? 'client' : role));
      case ('POST', '/auth/logout' || '/auth/reset-password' || '/devices'):
        return (200, <String, Object?>{});
      case ('POST', '/auth/forgot-password'):
        return (200, {'message': 'En la demo no se envía correo.'});
      case ('POST', '/auth/change-password'):
        return (200, {'message': 'Tu contraseña se actualizó.', ..._session(role)});
      case ('GET', '/users/me'):
        return (200, _userOf(role));
      case ('PATCH', '/users/me'):
        if (role == 'client') _client = {..._client, ...d.cast<String, Object?>(), 'client': {...(_client['client']! as Map), ...(d['client'] as Map? ?? const {})}};
        return (200, _userOf(role));
      case ('DELETE', '/users/me'):
        return (204, null);
      case ('GET', '/users'):
        return (200, {'data': [{..._broker, 'active': true}]});
      case ('GET', '/public/legal'):
        return (200, {'privacyUrl': 'https://zugar.mx/aviso-de-privacidad', 'deleteAccountUrl': 'https://zugar.mx/eliminar-cuenta', 'privacyVersion': 'demo'});
      case ('GET', '/events/seq'):
        return (200, {'seq': _seq});
      case ('GET', '/dashboard'):
        return _dashboard(role);
      case ('GET', '/notifications'):
        return (200, {'data': _notifications, 'unreadCount': _notifications.where((n) => n['read'] == false).length});
      case ('POST', '/notifications/read-all'):
        for (final n in _notifications) {
          n['read'] = true;
        }
        return (204, null);
      case ('GET', '/properties'):
        final q = '${o.queryParameters['q'] ?? ''}'.toLowerCase();
        final casas = [..._houses, if (o.queryParameters['sort'] == 'updated') _rentada];
        return (200, {'data': casas.where((h) => '${h['name']} ${h['code']}'.toLowerCase().contains(q)).toList()});
      case ('GET', '/promissory-notes'):
        return _pagares(o.queryParameters);
      case ('GET', '/receipts'):
        return (200, {'data': _recibos});
      case ('GET', '/maintenance-reports'):
        return _listaReportes(o.queryParameters);
      case ('POST', '/maintenance-reports'):
        final r = _reporte('${d['title']}', '${d['description']}', '${d['category']}', '${d['priority'] ?? 'media'}', 'reported', 'Reportado');
        _reportes.insert(0, r);
        return (201, r);
      case ('GET', '/providers'):
        final texto = '${o.queryParameters['q'] ?? ''}'.toLowerCase();
        return (200, {'data': _proveedores.where((p) => '${p['name']} ${p['specialty']} ${p['zone']}'.toLowerCase().contains(texto)).toList()});
      case ('GET', '/sales'):
        return (200, {'data': role == 'client' ? _compras : const <Object>[]});
      case ('GET', '/requests'):
        return (200, {'data': _visibleRequests('client', const {})});
      case ('POST', '/requests'):
        return _createRequest(d.cast<String, Object?>());
      case ('GET', '/leads'):
        return (200, {'data': _visibleRequests(role, o.queryParameters)});
      case ('GET', '/appointments'):
        return (200, {'data': _visibleAppointments(role)});
      case ('GET', '/appointments/active'):
        return (200, {'appointment': _visibleAppointments(role).where((a) => a['status'] == 'por-confirmar' || a['status'] == 'confirmada').firstOrNull});
      case ('POST', '/appointments'):
        return (201, _appointment(_newAppointment(d['propertyId']! as String, d['scheduledAt']! as String, 'staff', _clientId, note: d['note'] as String?), role));
    }
    final parts = path.split('/').where((s) => s.isNotEmpty).toList();
    final tail = parts.length > 2 ? parts.sublist(2).join('/') : null;
    switch (parts.first) {
      case 'notifications':
        _notifications.firstWhere((n) => n['id'] == parts[1])['read'] = true;
        return (204, null);
      case 'properties':
        if (tail == 'dossier') return _expediente(parts[1], role);
        return (200, parts[1] == 'casa-5' ? _rentada : _houseById(parts[1]));
      case 'promissory-notes':
        if (tail == 'payments' && method == 'POST') return _registrarPago(parts[1], d);
      case 'maintenance-reports':
        if (tail == 'updates' && method == 'POST') return _actualizarReporte(parts[1], d);
        if (parts.length == 2) return (200, _reportes.firstWhere((r) => r['id'] == parts[1]));
      case 'requests' || 'leads':
        return _lead(parts[1], method, tail, role, o.data);
      case 'appointments':
        if (tail == 'messages') return method == 'GET' ? (200, {'data': _chat(parts[1], role)}) : _send(parts[1], role, o.data);
        if (tail != null) return _act(parts[1], tail, role, d);
        return (200, _appointment(_appointments.firstWhere((a) => a['id'] == parts[1]), role));
    }
    return _error(404, 'NOT_FOUND', 'Esta función no está disponible en la demo.');
  }

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    await Future<void>.delayed(const Duration(milliseconds: 250)); // que se vean los estados de carga
    final (status, body) = _route(options);
    return ResponseBody.fromString(body == null ? '' : jsonEncode(body), status, headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }

  @override
  void close({bool force = false}) {}
}
