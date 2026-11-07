import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/network/api_exception.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_spacing.dart';
import '../../widgets/theme/app_text_styles.dart';
import '../../services/utils/validators.dart';
import '../../widgets/common/auth_background.dart';
import '../../widgets/common/auth_text_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../services/repositories/auth_repository.dart';
import '../../services/providers/pending_visit_provider.dart';
import '../../services/providers/session_provider.dart';
import '../../services/providers/site_link_provider.dart';

/// Pantalla 2 · Iniciar sesión. Al entrar, el router lleva a /home.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;
  /// Aviso tras pedir la contraseña temporal
  String? _notice;
  Map<String, String> _fieldErrors = const {};

  @override
  void initState() {
    super.initState();
    // Viene de enviar un formulario del sitio: su correo ya va escrito.
    _email.text = ref.read(siteLinkProvider).email ?? '';
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _fieldErrors = const {};
    });
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await ref.read(sessionProvider.notifier).login(_email.text, _password.text);
    } catch (e) {
      final api = ApiException.from(e);
      if (mounted) {
        setState(() {
          _error = api.message;
          _fieldErrors = api.fieldErrors;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = await showDialog<String>(context: context, builder: (_) => _ForgotPasswordDialog(initialEmail: _email.text));
    if (email == null || Validators.email(email) != null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authRepositoryProvider).forgotPassword(email);
      // Queda en el acceso con el correo escrito: entra con la contraseña temporal y luego crea la suya
      _email.text = email.trim();
      _password.clear();
      setState(() => _notice = 'Si $email está registrado, te enviamos una contraseña temporal (revisa también el correo no deseado). Escríbela aquí; al entrar te pediremos crear la tuya.');
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(ApiException.from(e).message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: AutofillGroup(
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                Text('Homiz', textAlign: TextAlign.center, style: AppTextStyles.brand),
                Text('by', textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: Colors.white70)),
                const SizedBox(height: AppSpacing.xs),
                const Center(child: ZugarLogo(height: 40)),
                const SizedBox(height: AppSpacing.xxl),
                Semantics(header: true, child: Text('Iniciar sesión', style: AppTextStyles.authTitle)),
                if (ref.watch(siteLinkProvider.select((l) => l.email != null)) && ref.watch(pendingVisitProvider) == null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Te creamos tu cuenta con tu solicitud. Entra con la contraseña temporal que te enviamos por correo; luego crearás la tuya.',
                    style: AppTextStyles.body.copyWith(color: Colors.white70),
                  ),
                ],
                if (ref.watch(pendingVisitProvider) != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text('Entra para agendar la visita a la casa que elegiste en el sitio.', style: AppTextStyles.body.copyWith(color: Colors.white70)),
                ],
                const SizedBox(height: AppSpacing.xl),
                AuthTextField(
                  label: 'Correo electrónico',
                  controller: _email,
                  hint: 'nombre@correo.com',
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                  errorText: _fieldErrors['email'],
                  enabled: !_loading,
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(
                  label: 'Contraseña',
                  controller: _password,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: (v) => Validators.required(v, 'Escribe tu contraseña.'),
                  errorText: _fieldErrors['password'],
                  onSubmitted: (_) => _submit(),
                  enabled: !_loading,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _loading ? null : _forgotPassword,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                if (_notice != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: AppRadius.inputAll),
                      child: Text(_notice!, style: AppTextStyles.secondary.copyWith(color: Colors.white, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (_error != null) ...[
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: AppRadius.inputAll),
                      child: Text(_error!, style: AppTextStyles.secondary.copyWith(color: AppColors.danger, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                const SizedBox(height: AppSpacing.sm),
                PrimaryButton(label: 'Ingresar', variant: ButtonVariant.white, loading: _loading, onPressed: _submit),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white38)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text('o', style: AppTextStyles.body.copyWith(color: Colors.white70)),
                    ),
                    const Expanded(child: Divider(color: Colors.white38)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(label: 'Regístrate aquí', onPressed: _loading ? null : () => context.go('/register')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pide el correo para recuperar la contraseña. El controlador se libera cuando el diálogo termina de cerrarse.
class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final _controller = TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recuperar contraseña', textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Correo electrónico'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(onPressed: () => Navigator.pop(context, _controller.text), child: const Text('Enviar')),
      ],
    );
  }
}
