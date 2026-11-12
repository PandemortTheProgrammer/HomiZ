import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_provider.freezed.dart';
part 'service_provider.g.dart';

/// Proveedor de mantenimiento del directorio (plomería, electricidad…).
@freezed
abstract class ServiceProvider with _$ServiceProvider {
  const factory ServiceProvider({
    required String id,
    required String name,
    required String specialty,
    String? phone,
    String? email,
    String? zone,
    String? notes,
    @Default(true) bool active,
  }) = _ServiceProvider;

  factory ServiceProvider.fromJson(Map<String, dynamic> json) => _$ServiceProviderFromJson(json);
}
