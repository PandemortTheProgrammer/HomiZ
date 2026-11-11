import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/network/api_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../common/file_uploader.dart';
import '../common/primary_button.dart';
import '../../models/property_models.dart';
import '../../services/providers/property_provider.dart';
import '../../services/repositories/documents_repository.dart';

/// Tipos de documento del expediente (los mismos de la API).
const documentTypes = <String, String>{
  'contract': 'Contrato',
  'deposit': 'Depósito en garantía',
  'delivery_sheet': 'Ficha de entrega',
  'rules': 'Reglamento',
  'annex': 'Anexo',
  'receipt': 'Recibo',
  'proof': 'Comprobante de pago',
  'photo': 'Fotografía',
  'other': 'Otro',
};
// El PDF de cada pagaré se sube desde «Pagos» (queda ligado a ese pagaré).

final documentActionsProvider = Provider<DocumentActions>(DocumentActions.new);

/// Cambios al expediente; después se vuelve a leer el expediente de la casa.
class DocumentActions {
  DocumentActions(this._ref);

  final Ref _ref;

  DocumentsRepository get _repo => _ref.read(documentsRepositoryProvider);

  Future<void> upload(String propertyId, XFile file, {required String type, required String name, String? description, required bool visibleToClient}) async {
    await _repo.uploadDocument(propertyId, file, type: type, name: name, description: description, visibleToClient: visibleToClient);
    _ref.invalidate(dossierProvider(propertyId));
  }

  Future<void> update(String propertyId, String documentId, {String? name, String? description, bool? visibleToClient}) async {
    await _repo.updateDocument(documentId, name: name, description: description, visibleToClient: visibleToClient);
    _ref.invalidate(dossierProvider(propertyId));
  }

  Future<void> delete(String propertyId, String documentId) async {
    await _repo.deleteDocument(documentId);
    _ref.invalidate(dossierProvider(propertyId));
  }
}

/// «Subir documento» (sin [document]) o «Editar documento». Devuelve true si se guardó.
Future<bool> showDocumentSheet(BuildContext context, {required String propertyId, DossierDocument? document}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl),
      child: SingleChildScrollView(child: DocumentSheet(propertyId: propertyId, document: document)),
    ),
  );
  return saved ?? false;
}

class DocumentSheet extends ConsumerStatefulWidget {
  const DocumentSheet({super.key, required this.propertyId, this.document});

  final String propertyId;
  final DossierDocument? document;

  @override
  ConsumerState<DocumentSheet> createState() => _DocumentSheetState();
}

class _DocumentSheetState extends ConsumerState<DocumentSheet> {
  static const _maxBytes = 50 * 1024 * 1024;

  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.document?.name ?? '');
  late final _description = TextEditingController(text: widget.document?.description ?? '');
  late bool _visible = widget.document?.visibleToClient ?? true;
  String _type = 'annex';
  List<XFile> _files = [];
  bool _loading = false;
  String? _error;

  bool get _editing => widget.document != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _onFiles(List<XFile> files) {
    setState(() => _files = files);
    // Sugerir el nombre a partir del archivo
    if (files.isNotEmpty && _name.text.trim().isEmpty) {
      _name.text = files.first.name.replaceAll(RegExp(r'\.[^.]+$'), '').replaceAll(RegExp(r'[-_]+'), ' ');
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (!_editing && _files.isEmpty) return setState(() => _error = 'Elige el archivo (PDF o foto).');
    setState(() {
      _loading = true;
      _error = null;
    });
    final actions = ref.read(documentActionsProvider);
    try {
      if (_editing) {
        await actions.update(widget.propertyId, widget.document!.id, name: _name.text, description: _description.text, visibleToClient: _visible);
      } else {
        if (await _files.first.length() > _maxBytes) throw const ApiException(code: 'FILE_TOO_LARGE', message: 'El archivo pesa más de 50 MB.');
        await actions.upload(widget.propertyId, _files.first, type: _type, name: _name.text, description: _description.text, visibleToClient: _visible);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_editing ? 'Editar documento' : 'Subir documento', style: AppTextStyles.pageTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _editing ? documentTypes[widget.document!.type] ?? widget.document!.type : 'PDF o foto de hasta 50 MB. Se guarda de forma privada.',
            style: AppTextStyles.secondary.copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!_editing) ...[
            FileUploader(files: _files, onChanged: _onFiles, maxFiles: 1, label: 'Elegir archivo'),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipo de documento'),
              items: [for (final e in documentTypes.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
              onChanged: _loading ? null : (v) => setState(() => _type = v ?? 'annex'),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          TextFormField(
            controller: _name,
            maxLength: 120,
            decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Por ejemplo: Anexo C · Mascotas'),
            validator: (v) => (v ?? '').trim().length < 2 ? 'Escribe el nombre del documento.' : null,
          ),
          TextFormField(controller: _description, maxLength: 200, decoration: const InputDecoration(labelText: 'Descripción (opcional)')),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _visible,
            onChanged: _loading ? null : (v) => setState(() => _visible = v),
            title: const Text('Visible para el cliente'),
            subtitle: const Text('Si lo apagas, solo lo ve el personal.'),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Semantics(liveRegion: true, child: Text(_error!, style: AppTextStyles.secondary.copyWith(color: AppColors.danger, fontSize: 13))),
            ),
          PrimaryButton(label: _editing ? 'Guardar cambios' : 'Subir documento', loading: _loading, onPressed: _save),
        ],
      ),
    );
  }
}
