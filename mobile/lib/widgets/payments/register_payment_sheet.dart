import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/network/api_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../common/primary_button.dart';
import '../../services/repositories/documents_repository.dart';
import '../../models/payment_models.dart';
import '../../services/providers/payments_provider.dart';

/// «Marcar como pagado» en un paso: fecha del pago, el PDF del pagaré firmado y la foto del sello
/// (como se entrega en físico). El folio del recibo lo genera el servidor y el pagaré queda pagado.
Future<bool> showRegisterPaymentSheet(BuildContext context, PromissoryNote note) async {
  final done = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl),
      child: SingleChildScrollView(child: RegisterPaymentSheet(note: note)),
    ),
  );
  if (done != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(done)));
  }
  return done != null;
}

class RegisterPaymentSheet extends ConsumerStatefulWidget {
  const RegisterPaymentSheet({super.key, required this.note});

  final PromissoryNote note;

  @override
  ConsumerState<RegisterPaymentSheet> createState() => _RegisterPaymentSheetState();
}

class _RegisterPaymentSheetState extends ConsumerState<RegisterPaymentSheet> {
  static const _maxPdf = 50 * 1024 * 1024;
  static const _maxPhoto = 10 * 1024 * 1024;

  final _form = GlobalKey<FormState>();
  final _notes = TextEditingController();
  DateTime _paidOn = DateTime.now();
  XFile? _pdf;
  final List<XFile> _stamps = [];
  String? _busy;
  String? _error;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: _paidOn, firstDate: DateTime(now.year - 1), lastDate: now, helpText: 'Fecha del pago');
    if (picked != null) setState(() => _paidOn = picked);
  }

  Future<void> _pickPdf() async {
    final picked = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['pdf']);
    if (picked.isEmpty) return;
    final file = picked.first.xFile;
    if (await file.length() > _maxPdf) return setState(() => _error = 'El PDF pesa más de 50 MB.');
    setState(() {
      _pdf = file;
      _error = null;
    });
  }

  Future<void> _pickStamp(ImageSource source) async {
    final picker = ImagePicker();
    final photos = source == ImageSource.camera
        ? [?await picker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 2400)]
        : await picker.pickMultiImage(imageQuality: 85, maxWidth: 2400);
    for (final p in photos) {
      if (await p.length() > _maxPhoto) return setState(() => _error = 'Una foto pesa más de 10 MB.');
    }
    setState(() {
      _stamps.addAll(photos);
      _error = null;
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = 'Registrando el pago…';
      _error = null;
    });
    final n = widget.note;
    final now = DateTime.now();
    // Hoy: la hora actual. Otro día: mediodía, para no cambiar de fecha por la zona horaria.
    final sameDay = _paidOn.year == now.year && _paidOn.month == now.month && _paidOn.day == now.day;
    final paidAt = sameDay ? now : DateTime(_paidOn.year, _paidOn.month, _paidOn.day, 12);
    try {
      final folio = await ref.read(paymentActionsProvider).register(n, paidAt: paidAt, notes: _notes.text);
      // Ya quedó pagado: si un archivo no sube, se avisa y se puede subir después desde el pagaré
      final missing = <String>[];
      final docs = ref.read(documentsRepositoryProvider);
      if (_pdf != null && n.property != null) {
        if (mounted) setState(() => _busy = 'Subiendo el PDF del pagaré…');
        try {
          await docs.uploadDocument(n.property!.id, _pdf!, type: 'promissory_note', name: '${n.label} firmado', visibleToClient: true, promissoryNoteId: n.id);
        } catch (_) {
          missing.add('el PDF');
        }
      }
      for (final (i, p) in _stamps.indexed) {
        if (n.property == null) break;
        if (mounted) setState(() => _busy = 'Subiendo la foto del sello ${i + 1} de ${_stamps.length}…');
        try {
          await docs.uploadStamp(n.property!.id, n.id, n.label, p, n.stamps.length + i + 1);
        } catch (_) {
          missing.add('la foto ${i + 1}');
        }
      }
      ref.invalidate(notesProvider);
      ref.invalidate(allNotesProvider);
      final files = [if (_pdf != null) 'PDF', if (_stamps.isNotEmpty) _stamps.length == 1 ? 'sello' : '${_stamps.length} sellos'];
      final text = '${n.label} quedó pagado${folio == null || folio.isEmpty ? '' : ' (folio $folio)'}${files.isEmpty ? '' : ' con su ${files.join(' y ')}'}. Avisamos al cliente.'
          '${missing.isEmpty ? '' : ' No se pudo subir ${missing.join(', ')}: súbelo desde el pagaré.'}';
      if (mounted) Navigator.pop(context, text);
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.note;
    final loading = _busy != null;
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Marcar como pagado', style: AppTextStyles.pageTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            [n.label, if (n.client != null) n.client!.name, if (n.property != null) n.property!.name].join(' · '),
            style: AppTextStyles.secondary.copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.lg),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Monto', helperText: 'El pago cubre el pagaré completo. El recibo se genera solo como pagado.'),
            child: Text(Fmt.money(n.amount), style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: loading ? null : _pickDate,
            icon: const Icon(Icons.event_outlined),
            label: Text('Pagado el ${Fmt.longDate(_paidOn)}'),
          ),
          const SizedBox(height: AppSpacing.md),
          // Lo que se entrega en físico: el pagaré firmado (PDF) y el sello (foto)
          OutlinedButton.icon(
            onPressed: loading ? null : _pickPdf,
            icon: Icon(_pdf == null ? Icons.picture_as_pdf_outlined : Icons.check_circle_outline),
            label: Text(_pdf == null ? (n.documentId == null ? 'Adjuntar PDF del pagaré' : 'Reemplazar PDF del pagaré') : 'PDF: ${_pdf!.name}', overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: loading ? null : () => _pickStamp(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Foto del sello'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: loading ? null : () => _pickStamp(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('De la galería'),
                ),
              ),
            ],
          ),
          if (_stamps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text('${_stamps.length} ${_stamps.length == 1 ? 'foto lista' : 'fotos listas'} para subir', style: AppTextStyles.secondary.copyWith(fontSize: 13)),
            ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _notes,
            maxLength: 500,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Notas (opcional)'),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Semantics(liveRegion: true, child: Text(_error!, style: AppTextStyles.secondary.copyWith(color: AppColors.danger, fontSize: 13))),
            ),
          PrimaryButton(label: _busy ?? 'Marcar como pagado', loading: loading, onPressed: _save),
        ],
      ),
    );
  }
}
