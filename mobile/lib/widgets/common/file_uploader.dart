import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Selector de archivos (cámara, galería o documentos) con máximo [maxFiles].
/// Las fotos se comprimen al tomarlas (lado mayor 1600 px, calidad 80).
class FileUploader extends StatelessWidget {
  const FileUploader({super.key, required this.files, required this.onChanged, this.maxFiles = 5, this.allowDocuments = true, this.label = 'Adjuntar archivos'});

  final List<XFile> files;
  final ValueChanged<List<XFile>> onChanged;
  final int maxFiles;
  final bool allowDocuments;
  final String label;

  static const _maxSide = 1600.0;
  static const _quality = 80;

  int get _remaining => maxFiles - files.length;

  Future<void> _pick(BuildContext context) async {
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.photo_camera_outlined), title: const Text('Tomar foto'), onTap: () => Navigator.pop(context, 'camera')),
            ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Elegir de la galería'), onTap: () => Navigator.pop(context, 'gallery')),
            if (allowDocuments)
              ListTile(leading: const Icon(Icons.description_outlined), title: const Text('Elegir documento (PDF)'), onTap: () => Navigator.pop(context, 'document')),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final List<XFile> picked = switch (source) {
      'camera' => [?await picker.pickImage(source: ImageSource.camera, maxWidth: _maxSide, maxHeight: _maxSide, imageQuality: _quality)],
      'gallery' => await picker.pickMultiImage(maxWidth: _maxSide, maxHeight: _maxSide, imageQuality: _quality, limit: _remaining > 1 ? _remaining : null),
      _ => (await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'])).map((f) => f.xFile).toList(),
    };
    if (picked.isEmpty) return;
    if (picked.length > _remaining && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solo puedes adjuntar $maxFiles archivos.')));
    }
    onChanged([...files, ...picked.take(_remaining)]);
  }

  bool _isImage(XFile f) => RegExp(r'\.(jpe?g|png|heic|webp)$', caseSensitive: false).hasMatch(f.name);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (var i = 0; i < files.length; i++)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.inputAll,
                    child: Container(
                      width: 72,
                      height: 72,
                      color: AppColors.placeholderBox,
                      child: _isImage(files[i])
                          ? Image.file(File(files[i].path), fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.image_outlined))
                          : Padding(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.picture_as_pdf_outlined, color: AppColors.danger),
                                  Text(files[i].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.small),
                                ],
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: -10,
                    right: -10,
                    child: IconButton(
                      tooltip: 'Quitar ${files[i].name}',
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(backgroundColor: Colors.white),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      onPressed: () => onChanged([...files]..removeAt(i)),
                    ),
                  ),
                ],
              ),
            if (_remaining > 0)
              Semantics(
                button: true,
                label: label,
                child: InkWell(
                  borderRadius: AppRadius.inputAll,
                  onTap: () => _pick(context),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: AppRadius.inputAll, border: Border.all(color: AppColors.divider)),
                    child: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('${files.length} de $maxFiles archivos', style: AppTextStyles.secondary),
      ],
    );
  }
}
