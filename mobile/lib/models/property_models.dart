import 'package:freezed_annotation/freezed_annotation.dart';

import '../services/utils/json_converters.dart';
import 'appointment.dart';

part 'property_models.freezed.dart';
part 'property_models.g.dart';

/// Ficha de propiedad (GET /properties/:id y catálogo GET /properties).
@freezed
abstract class PropertyDetail with _$PropertyDetail {
  const factory PropertyDetail({
    required String id,
    String? code,
    required String name,
    /// Tipo de inmueble: Casa, Departamento, Terreno, Local comercial…
    String? type,
    String? description,
    String? operation,
    @Default(0) double price,
    int? rec,
    double? banos,
    double? m2,
    int? est,
    @Default(false) bool petsAllowed,
    String? furnished,
    String? address,
    String? city,
    String? zone,
    String? status,
    String? visibility,
    @Default(<String>[]) List<String> amenities,
    @Default(<PropertyPhoto>[]) List<PropertyPhoto> photos,
    PersonRef? broker,
  }) = _PropertyDetail;

  const PropertyDetail._();

  factory PropertyDetail.fromJson(Map<String, dynamic> json) => _$PropertyDetailFromJson(json);

  /// Primera foto con URL (las del sitio aún no tienen archivo: se muestra el recuadro gris).
  String? get coverUrl => photos.where((p) => p.url != null).firstOrNull?.url;

  /// Fotos con archivo, en orden: la primera es la portada.
  List<String> get photoUrls => [for (final p in photos) if (p.url != null) p.url!];
}

@freezed
abstract class PropertyPhoto with _$PropertyPhoto {
  const factory PropertyPhoto({String? id, String? label, String? url}) = _PropertyPhoto;

  factory PropertyPhoto.fromJson(Map<String, dynamic> json) => _$PropertyPhotoFromJson(json);
}

/// Expediente del cliente (GET /properties/:id/dossier, vista restringida).
@freezed
abstract class Dossier with _$Dossier {
  const factory Dossier({
    required DossierProperty property,
    DossierContract? contract,
    @Default(<DossierSection>[]) List<DossierSection> sections,
    @Default(<DossierDocument>[]) List<DossierDocument> documents,
    /// Servicios de agua y luz (números que captura administración)
    DossierUtilities? utilities,
    /// Asesor de la casa (contacto mutuo: también lo ve el inquilino)
    DossierContact? broker,
    // Solo para el personal:
    PersonRef? tenant,
  }) = _Dossier;

  factory Dossier.fromJson(Map<String, dynamic> json) => _$DossierFromJson(json);
}

@freezed
abstract class DossierContact with _$DossierContact {
  const factory DossierContact({required String name, String? phone, String? email}) = _DossierContact;

  factory DossierContact.fromJson(Map<String, dynamic> json) => _$DossierContactFromJson(json);
}

/// Luz (CFE) y agua (Aguakan): número de servicio y la app donde se consulta el recibo.
@freezed
abstract class DossierUtilities with _$DossierUtilities {
  const factory DossierUtilities({@Default(1) int reminderDay, UtilityService? electricity, UtilityService? water}) = _DossierUtilities;

  factory DossierUtilities.fromJson(Map<String, dynamic> json) => _$DossierUtilitiesFromJson(json);
}

@freezed
abstract class UtilityService with _$UtilityService {
  const factory UtilityService({required String company, required String serviceNumber, String? app, String? url}) = _UtilityService;

  factory UtilityService.fromJson(Map<String, dynamic> json) => _$UtilityServiceFromJson(json);
}

@freezed
abstract class DossierProperty with _$DossierProperty {
  const factory DossierProperty({
    required String id,
    required String name,
    String? zone,
    String? address,
    String? city,
    int? rec,
    double? banos,
    double? m2,
    @Default(<String>[]) List<String> amenities,
    String? status,
    DossierBroker? broker,
  }) = _DossierProperty;

  factory DossierProperty.fromJson(Map<String, dynamic> json) => _$DossierPropertyFromJson(json);
}

/// Broker responsable (solo en el expediente del personal).
@freezed
abstract class DossierBroker with _$DossierBroker {
  const factory DossierBroker({String? name, String? phone}) = _DossierBroker;

  factory DossierBroker.fromJson(Map<String, dynamic> json) => _$DossierBrokerFromJson(json);
}

@freezed
abstract class DossierContract with _$DossierContract {
  const factory DossierContract({
    required String id,
    @LocalDate() required DateTime startDate,
    @LocalDate() required DateTime endDate,
    required double monthlyRent,
    required int paymentDay,
    double? deposit,
    required String status,
  }) = _DossierContract;

  factory DossierContract.fromJson(Map<String, dynamic> json) => _$DossierContractFromJson(json);
}

/// Sección lista para la pestaña «Expediente» (Contrato, Depósito, Ficha de entrega, Documentos).
@freezed
abstract class DossierSection with _$DossierSection {
  const factory DossierSection({
    required String key,
    required String title,
    String? subtitle,
    @Default(<String>[]) List<String> documentIds,
  }) = _DossierSection;

  factory DossierSection.fromJson(Map<String, dynamic> json) => _$DossierSectionFromJson(json);
}

@freezed
abstract class DossierDocument with _$DossierDocument {
  const factory DossierDocument({
    required String id,
    required String type,
    required String name,
    String? description,
    String? mime,
    int? size,
    @LocalDateOrNull() DateTime? createdAt,
    // Solo para el personal: si el cliente lo ve en su expediente.
    bool? visibleToClient,
  }) = _DossierDocument;

  factory DossierDocument.fromJson(Map<String, dynamic> json) => _$DossierDocumentFromJson(json);
}
