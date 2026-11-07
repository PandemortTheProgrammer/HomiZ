import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Barra inferior: ícono con su nombre (Inicio, Citas y, para el personal que atiende
/// solicitudes, Solicitudes). La pestaña activa y la que tiene el puntero encima se pintan de color.
class HomizBottomNav extends StatelessWidget {
  const HomizBottomNav({super.key, required this.currentIndex, required this.onTap, this.showRequests = false, this.newRequests = 0});

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Cuarta pestaña «Solicitudes» (brokers y administración con leads.manage).
  final bool showRequests;

  /// Solicitudes nuevas: número sobre el ícono de Solicitudes.
  final int newRequests;

  static const _requests = (Icons.mark_email_unread_outlined, Icons.mark_email_unread_rounded, 'Solicitudes');

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, Icons.home_rounded, 'Inicio'),
      (Icons.calendar_today_outlined, Icons.calendar_today_rounded, 'Citas'),
      if (showRequests) _requests,
    ];
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, -2))]),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: items[i].$1,
                    activeIcon: items[i].$2,
                    label: items[i].$3,
                    selected: i == currentIndex,
                    badge: items[i] == _requests ? newRequests : 0,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.selected, required this.badge, required this.onTap});

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final lit = widget.selected || _hover;
    final color = lit ? AppColors.navIcon : AppColors.navIconInactive;
    return Semantics(
      selected: widget.selected,
      button: true,
      label: widget.badge > 0 ? '${widget.label}, ${widget.badge} nuevas' : widget.label,
      child: ExcludeSemantics(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  // Pastilla de color: fuerte en la activa, suave al pasar el puntero
                  color: widget.selected ? AppColors.navIcon.withValues(alpha: .12) : _hover ? AppColors.navIcon.withValues(alpha: .06) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Badge(
                      isLabelVisible: widget.badge > 0,
                      label: Text(widget.badge > 99 ? '99+' : '${widget.badge}'),
                      child: Icon(widget.selected ? widget.activeIcon : widget.icon, size: 24, color: color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, height: 1.2, color: color, fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
