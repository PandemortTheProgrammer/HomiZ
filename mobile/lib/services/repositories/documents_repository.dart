import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../network/api_call.dart';
import '../network/api_client.dart';
import '../network/api_exception.dart';

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) => DocumentsRepository(ref.watch(dioProvider), ref.watch(httpAdapterProvider)));

/// URL firmadas de lectura y subida de fotos de mantenimiento.
class DocumentsRepository {
  DocumentsRepository(this._dio, HttpClientAdapter? adapter) : _upload = Dio() {
    if (adapter != null) _upload.httpClientAdapter = adapter;
  }

  final Dio _dio;

  /// Cliente sin token para el PUT a la URL firmada (la firma ya autoriza).
  final Dio _upload;

  /// URL firmada (15 min) para ver un documento visible para el cliente.
  Future<String> downloadUrl(String documentId) => apiCall(() async {
        final res = await _dio.get<Map<String, dynamic>>('/documents/$documentId/download-url');
        return res.data!['url'] as String;
      });

  static String mimeOf(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.pdf')) return 'application/pdf';
    return 'image/jpeg';
  }

  /// Sube una foto de mantenimiento: pide la URL, hace el PUT y devuelve el `storageKey`.
  Future<String> uploadMaintenancePhoto(String propertyId, XFile file) =>
      apiCall(() => _put(propertyId, 'maintenance_photo', file, 'No se pudo subir una de las fotos. Intenta de nuevo.'));

  /// Sube un archivo al expediente y lo registra (permiso documents.manage).
  /// Con [promissoryNoteId] queda ligado a ese pagaré (su PDF firmado).
  Future<void> uploadDocument(String propertyId, XFile file,
          {required String type, required String name, String? description, required bool visibleToClient, String? promissoryNoteId}) =>
      apiCall(() async {
        final key = await _put(propertyId, 'document', file, 'No se pudo subir el archivo. Intenta de nuevo.');
        await _dio.post<Map<String, dynamic>>('/documents', data: {
          'propertyId': propertyId,
          'storageKey': key,
          'type': type,
          'name': name.trim(),
          'description': (description == null || description.trim().isEmpty) ? null : description.trim(),
          'mime': mimeOf(file.name),
          'visibleToClient': visibleToClient,
          'promissoryNoteId': ?promissoryNoteId,
        });
      });

  /// Contrato firmado (PDF) del contrato: queda en el expediente, visible para el inquilino.
  Future<void> attachContractPdf(String contractId, String propertyId, XFile file) => apiCall(() async {
        final key = await _put(propertyId, 'document', file, 'No se pudo subir el contrato. Intenta de nuevo.');
        await _dio.post<Map<String, dynamic>>('/contracts/$contractId/document', data: {'storageKey': key});
      });

  /// Foto del sello de un pagaré (constancia de entrega en físico y digital); el inquilino la ve en su app.
  Future<void> uploadStamp(String propertyId, String noteId, String noteLabel, XFile photo, int index) =>
      uploadDocument(propertyId, photo, type: 'stamp', name: 'Sello $noteLabel · $index', visibleToClient: true, promissoryNoteId: noteId);

  /// Renombra o muestra/oculta un documento al cliente (permiso documents.manage).
  Future<void> updateDocument(String documentId, {String? name, String? description, bool? visibleToClient}) => apiCall(() async {
        await _dio.patch<Map<String, dynamic>>('/documents/$documentId', data: {
          if (name != null) 'name': name.trim(),
          if (description != null) 'description': description.trim().isEmpty ? null : description.trim(),
          'visibleToClient': ?visibleToClient,
        });
      });

  /// Elimina el documento y su archivo (solo administración: documents.delete).
  Future<void> deleteDocument(String documentId) => apiCall(() async {
        await _dio.delete<void>('/documents/$documentId');
      });

  /// Pide la URL firmada, hace el PUT directo al almacenamiento y devuelve el `storageKey`.
  Future<String> _put(String propertyId, String purpose, XFile file, String failMessage) async {
    final bytes = await file.readAsBytes();
    final mime = mimeOf(file.name);
    final res = await _dio.post<Map<String, dynamic>>('/documents/upload-url', data: {
      'propertyId': propertyId,
      'purpose': purpose,
      'mime': mime,
      'size': bytes.length,
    });
    final upload = res.data!['upload'] as Map<String, dynamic>;
    try {
      // Los bytes tal cual (no como Stream): así funciona también en la versión web y en el navegador del celular
      await _upload.put<void>(
        upload['url'] as String,
        data: bytes,
        options: Options(headers: {...(upload['headers'] as Map? ?? {}), Headers.contentLengthHeader: bytes.length}),
      );
    } on DioException catch (e) {
      if (e.response == null) rethrow;
      throw ApiException(code: 'UPLOAD_FAILED', message: failMessage);
    }
    return res.data!['storageKey'] as String;
  }
}
