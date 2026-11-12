import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../common/net_image.dart';

/// Foto grande con radio 12. Sin URL muestra el recuadro gris (las fotos se subirán después).
/// [overlay] se dibuja abajo, sobre una franja translúcida o como chip.
class PropertyHero extends StatelessWidget {
  const PropertyHero({super.key, this.url, this.height = 200, this.overlay, this.semanticLabel});

  final String? url;
  final double height;
  final Widget? overlay;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    const empty = ColoredBox(color: AppColors.placeholderBox);
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: AppRadius.cardAll,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url == null) empty else NetImage(url!),
              if (overlay != null) Positioned(left: 0, right: 0, bottom: 0, child: overlay!),
            ],
          ),
        ),
      ),
    );
  }
}

/// Galería de la casa: se desliza entre fotos, muestra «3/7» y miniaturas, y al tocar
/// una foto la abre a pantalla completa con zoom. Sin fotos queda el recuadro gris.
class PropertyGallery extends StatefulWidget {
  const PropertyGallery({super.key, required this.urls, this.height = 210, this.overlay, required this.title});

  final List<String> urls;
  final double height;
  final Widget? overlay;

  /// Nombre de la casa: para el lector de pantalla y el visor.
  final String title;

  @override
  State<PropertyGallery> createState() => _PropertyGalleryState();
}

class _PropertyGalleryState extends State<PropertyGallery> {
  final _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int i) => _pages.animateToPage(i, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

  Future<void> _open(int i) async {
    final back = await Navigator.of(context).push<int>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => GalleryViewer(urls: widget.urls, initial: i, title: widget.title)),
    );
    if (back != null && back != _index && mounted) _pages.jumpToPage(back);
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.urls;
    if (urls.isEmpty) {
      return PropertyHero(height: widget.height, overlay: widget.overlay, semanticLabel: '${widget.title}: aún no tiene fotos');
    }
    final many = urls.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          image: true,
          label: 'Foto ${_index + 1} de ${urls.length} de ${widget.title}. Toca para ampliarla.',
          child: ClipRRect(
            borderRadius: AppRadius.cardAll,
            child: SizedBox(
              height: widget.height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pages,
                    itemCount: urls.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => GestureDetector(onTap: () => _open(i), child: NetImage(urls[i])),
                  ),
                  if (many)
                    Positioned(
                      top: AppSpacing.md,
                      right: AppSpacing.md,
                      child: _Counter(text: '${_index + 1}/${urls.length}'),
                    ),
                  if (widget.overlay != null) Positioned(left: 0, right: 0, bottom: 0, child: IgnorePointer(child: widget.overlay!)),
                ],
              ),
            ),
          ),
        ),
        if (many) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: urls.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) => Semantics(
                button: true,
                selected: i == _index,
                label: 'Ver foto ${i + 1}',
                child: GestureDetector(
                  onTap: () => _go(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: i == _index ? AppColors.primary : Colors.transparent, width: 2),
                    ),
                    child: ClipRRect(borderRadius: BorderRadius.circular(6), child: NetImage(urls[i])),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: AppRadius.pillAll),
        child: Text(text, style: AppTextStyles.badge.copyWith(color: Colors.white, fontSize: 12)),
      );
}

/// Fotos a pantalla completa: se deslizan y se acercan con dos dedos (o doble toque).
/// Al cerrar regresa la foto en la que se quedó, para que la galería quede en la misma.
class GalleryViewer extends StatefulWidget {
  const GalleryViewer({super.key, required this.urls, required this.initial, required this.title});

  final List<String> urls;
  final int initial;
  final String title;

  @override
  State<GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  late final _pages = PageController(initialPage: widget.initial);
  late int _index = widget.initial;
  final _zoom = <int, TransformationController>{};
  bool _zoomed = false;

  @override
  void dispose() {
    _pages.dispose();
    for (final z in _zoom.values) {
      z.dispose();
    }
    super.dispose();
  }

  TransformationController _ctrl(int i) => _zoom.putIfAbsent(i, () {
        final c = TransformationController();
        c.addListener(() {
          final z = c.value.getMaxScaleOnAxis() > 1.01;
          if (z != _zoomed && i == _index) setState(() => _zoomed = z);
        });
        return c;
      });

  void _toggleZoom(int i) {
    final c = _ctrl(i);
    c.value = c.value.getMaxScaleOnAxis() > 1.01 ? Matrix4.identity() : (Matrix4.identity()..scaleByDouble(2.5, 2.5, 1, 1));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_index);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text('${widget.title} · ${_index + 1}/${widget.urls.length}', style: AppTextStyles.cardTitle.copyWith(color: Colors.white)),
          leading: IconButton(tooltip: 'Cerrar', icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop(_index)),
        ),
        body: PageView.builder(
          controller: _pages,
          // Con la foto ampliada se mueve la foto, no se cambia de página
          physics: _zoomed ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
          itemCount: widget.urls.length,
          onPageChanged: (i) => setState(() {
            _index = i;
            _zoomed = false;
            for (final z in _zoom.values) {
              z.value = Matrix4.identity();
            }
          }),
          itemBuilder: (_, i) => GestureDetector(
            onDoubleTap: () => _toggleZoom(i),
            child: InteractiveViewer(
              transformationController: _ctrl(i),
              minScale: 1,
              maxScale: 4,
              child: Center(child: NetImage(widget.urls[i], fit: BoxFit.contain)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Franja translúcida inferior: nombre en blanco y debajo pin + ubicación.
class HeroCaption extends StatelessWidget {
  const HeroCaption({super.key, required this.title, this.location});

  final String title;
  final String? location;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.38),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontSize: 18)),
          if (location != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.white),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: Text(location!, style: AppTextStyles.secondary.copyWith(color: Colors.white))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Chip translúcido con pin («Cancún») abajo a la izquierda de la foto.
class LocationChip extends StatelessWidget {
  const LocationChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: AppRadius.pillAll),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_outlined, size: 14, color: Colors.white),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTextStyles.badge.copyWith(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// Fila de características con íconos: «5 habitaciones», «3 baños», «Alberca».
class FeatureRow extends StatelessWidget {
  const FeatureRow({super.key, this.rec, this.banos, this.amenities = const []});

  final int? rec;
  final double? banos;
  final List<String> amenities;

  static String _num(double v) => v % 1 == 0 ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String)>[
      if (rec != null) (Icons.bed_outlined, '$rec ${rec == 1 ? 'habitación' : 'habitaciones'}'),
      if (banos != null) (Icons.bathtub_outlined, '${_num(banos!)} ${banos == 1 ? 'baño' : 'baños'}'),
      for (final a in amenities.take(3)) (a.toLowerCase().contains('alberca') ? Icons.pool_outlined : Icons.check_circle_outline, a),
    ];
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (icon, text) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(text, style: AppTextStyles.label),
            ],
          ),
      ],
    );
  }
}
