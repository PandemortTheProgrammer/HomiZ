import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/providers/session_provider.dart';

/// Muestra [child] solo si el usuario de la sesión tiene [permission]. La API vuelve a validar siempre.
class PermissionGate extends ConsumerWidget {
  const PermissionGate({super.key, required this.permission, required this.child, this.fallback = const SizedBox.shrink()});

  final String permission;
  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(sessionProvider.select((s) => s.value?.can(permission) ?? false));
    return allowed ? child : fallback;
  }
}
