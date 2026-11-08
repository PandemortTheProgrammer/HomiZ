import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/network/api_exception.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_spacing.dart';
import '../../widgets/theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../../services/utils/validators.dart';
import '../../widgets/common/cards.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/initials_avatar.dart';
import '../../widgets/common/primary_button.dart';
import '../../services/repositories/auth_repository.dart';
import '../../widgets/auth/legal_links.dart';
import '../../services/providers/session_provider.dart';

/// Perfil: datos de la cuenta, editar, cambiar contraseña y cerrar sesión.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  String _role(List<String> roles, bool isClient) {
    if (isClient) return 'Cuenta de cliente';
    if (roles.contains('admin')) return 'Cuenta de administrador';
    if (roles.contains('broker')) return 'Cuenta de asesor';
    return 'Cuenta del personal';
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Cerrar sesión',
      message: '¿Quieres cerrar tu sesión en este dispositivo?',
      confirmLabel: 'Cerrar sesión',
      destructive: true,
    );
    if (ok) await ref.read(sessionProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).value;
    if (user == null) return const Scaffold(body: SizedBox.shrink());
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Center(child: InitialsAvatar(name: user.name, initials: user.initials, size: 80)),
          const SizedBox(height: AppSpacing.md),
          Text(user.name, textAlign: TextAlign.center, style: AppTextStyles.pageTitle),
          Text(_role(user.roles, user.isClient), textAlign: TextAlign.center, style: AppTextStyles.secondary),
          const SizedBox(height: AppSpacing.xl),
          Text('Datos personales', style: AppTextStyles.sectionTitle),
          KeyValueRow(label: 'Nombre completo', value: user.name),
          KeyValueRow(label: 'Correo electrónico', value: user.email),
          KeyValueRow(label: 'Teléfono', value: user.phone ?? 'Sin registrar'),
          KeyValueRow(label: 'Fecha de nacimiento', value: user.birthDate == null ? 'Sin registrar' : Fmt.longDate(Fmt.parse(user.birthDate!)), showDivider: false),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(label: 'Editar información', icon: Icons.edit_outlined, onPressed: () => _openSheet(context, const _EditProfileSheet())),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: 'Cambiar contraseña', icon: Icons.lock_outline_rounded, variant: ButtonVariant.outline, onPressed: () => _openSheet(context, const _ChangePasswordSheet())),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: 'Cerrar sesión', icon: Icons.logout_rounded, variant: ButtonVariant.danger, onPressed: () => _logout(context, ref)),
          const SizedBox(height: AppSpacing.xl),
          // Tus datos: aviso de privacidad y derecho de cancelación (eliminar la cuenta)
          Text('Tus datos', style: AppTextStyles.sectionTitle),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Aviso de privacidad'),
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => openPrivacyNotice(context, ref),
          ),
          if (user.isClient)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
              title: Text('Eliminar mi cuenta', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              subtitle: const Text('Borra tus datos de contacto, solicitudes y mensajes.'),
              onTap: () => _openSheet(context, const _DeleteAccountSheet()),
            ),
        ],
      ),
    );
  }

  void _openSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.screen, 0, AppSpacing.screen, MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xl),
        child: sheet,
      ),
    );
  }
}

/// Mensaje de error de la API dentro de las hojas.
class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Semantics(liveRegion: true, child: Text(message, style: AppTextStyles.secondary.copyWith(color: AppColors.danger, fontSize: 13))),
      );
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet();

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  final _form = GlobalKey<FormState>();
  late final _user = ref.read(sessionProvider).value!;
  late final _name = TextEditingController(text: _user.name);
  late final _phone = TextEditingController(text: _user.phone ?? '');
  late DateTime? _birthDate = _user.birthDate == null ? null : Fmt.parse(_user.birthDate!);
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 30),
      firstDate: DateTime(1920),
      lastDate: now,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Fecha de nacimiento',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  /// AAAA-MM-DD, el formato que acepta la API.
  static String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final updated = await ref.read(authRepositoryProvider).updateProfile(
            name: _name.text,
            phone: _phone.text,
            birthDate: _birthDate == null ? null : _iso(_birthDate!),
          );
      ref.read(sessionProvider.notifier).updateUser(updated);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Editar información', style: AppTextStyles.pageTitle),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre completo'), validator: Validators.name),
          const SizedBox(height: AppSpacing.md),
          TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono'), validator: Validators.phone),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _loading ? null : _pickBirthDate,
            icon: const Icon(Icons.cake_outlined),
            label: Text(_birthDate == null ? 'Fecha de nacimiento' : 'Nació el ${Fmt.longDate(_birthDate!)}'),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_error != null) _ErrorText(_error!),
          PrimaryButton(label: 'Guardar', loading: _loading, onPressed: _save),
        ],
      ),
    );
  }
}

/// «Eliminar mi cuenta»: explica qué se borra, pide la contraseña y confirma. Con contrato vigente la API no lo permite.
class _DeleteAccountSheet extends ConsumerStatefulWidget {
  const _DeleteAccountSheet();

  @override
  ConsumerState<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends ConsumerState<_DeleteAccountSheet> {
  final _password = TextEditingController();
  bool _sure = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (_password.text.isEmpty) return setState(() => _error = 'Escribe tu contraseña para confirmar.');
    if (!_sure) return setState(() => _error = 'Confirma que entiendes que no se puede deshacer.');
    setState(() {
      _loading = true;
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      await ref.read(sessionProvider.notifier).deleteAccount(_password.text);
      nav.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Tu cuenta se eliminó y borramos tus datos de este teléfono.')));
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Eliminar mi cuenta', style: AppTextStyles.pageTitle),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Borramos tus datos de contacto, tus solicitudes, mensajes y avisos, y cancelamos tus citas pendientes. '
          'Si tienes un contrato de renta vigente, conservamos tus datos hasta que termine. Lo que la ley obliga a guardar '
          '(contratos y pagos terminados) queda sin tus datos de contacto.',
          style: AppTextStyles.secondary.copyWith(fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Tu contraseña'), enabled: !_loading),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _sure,
          onChanged: _loading ? null : (v) => setState(() => _sure = v ?? false),
          title: const Text('Entiendo que no se puede deshacer.'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (_error != null) _ErrorText(_error!),
        PrimaryButton(label: 'Eliminar mi cuenta', variant: ButtonVariant.danger, loading: _loading, onPressed: _delete),
      ],
    );
  }
}

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final message = await ref.read(authRepositoryProvider).changePassword(current: _current.text, next: _next.text);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Cambiar contraseña', style: AppTextStyles.pageTitle),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _current,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña actual'),
            validator: (v) => Validators.required(v, 'Escribe tu contraseña actual.'),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(controller: _next, obscureText: true, decoration: const InputDecoration(labelText: 'Nueva contraseña'), validator: Validators.password),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _confirm,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirma la nueva contraseña'),
            validator: (v) => v == _next.text ? null : 'Las contraseñas no coinciden.',
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_error != null) _ErrorText(_error!),
          PrimaryButton(label: 'Actualizar contraseña', loading: _loading, onPressed: _save),
        ],
      ),
    );
  }
}
