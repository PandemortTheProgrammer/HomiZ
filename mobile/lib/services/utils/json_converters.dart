import 'package:freezed_annotation/freezed_annotation.dart';

import 'formatters.dart';

/// Fechas de la API («2026-11-05» o ISO con zona) convertidas a la hora local del teléfono.
class LocalDate implements JsonConverter<DateTime, String> {
  const LocalDate();

  @override
  DateTime fromJson(String json) => Fmt.parse(json);

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}

class LocalDateOrNull implements JsonConverter<DateTime?, String?> {
  const LocalDateOrNull();

  @override
  DateTime? fromJson(String? json) => json == null ? null : Fmt.parse(json);

  @override
  String? toJson(DateTime? object) => object?.toUtc().toIso8601String();
}
