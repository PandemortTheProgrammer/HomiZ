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
import '../../services/providers/session_provider.dart';
import '../../services/providers/site_link_provider.dart';

/// «Crea tu contraseña»: se abre con el enlace del correo (?reset=…&email=…).
/// Sirve para la cuenta que se creó sola al enviar un formulario del sitio y para recuperar la contraseña.
/// Al guardarla entra de inmediato y ve sus solicitudes.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final link = ref.read(siteLinkProvider);
    if (!_form.currentState!.validate() || link.resetToken == null) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).resetPassword(link.resetToken!, _password.text);
      if (link.email != null) {
        // Entra con la contraseña nueva; el router lo lleva a «Mis solicitudes».
        await ref.read(sessionProvider.notifier).login(link.email!, _password.text);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listo. Ya puedes entrar con tu nueva contraseña.')));
        ref.read(siteLinkProvider.notifier).clear();
        context.go('/login');
      }
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(siteLinkProvider.select((l) => l.email));
    return Scaffold(
      body: AuthBackground(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              const Center(child: ZugarLogo(height: 40)),
              const SizedBox(height: AppSpacing.xxl),
              Semantics(header: true, child: Text('Crea tu contraseña', style: AppTextStyles.authTitle, textAlign: TextAlign.center)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                email == null ? 'Escribe tu nueva contraseña.' : 'Tu cuenta es $email. Con tu contraseña podrás seguir tu solicitud, ver las casas que te proponemos y agendar visitas.',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AuthTextField(label: 'Contraseña nueva', controller: _password, obscure: true, validator: Validators.password, enabled: !_loading, autofillHints: const [AutofillHints.newPassword]),
              const SizedBox(height: AppSpacing.lg),
              AuthTextField(
                label: 'Confirma tu contraseña',
                controller: _confirm,
                obscure: true,
                textInputAction: TextInputAction.done,
                validator: (v) => v != _password.text ? 'Las contraseñas no coinciden.' : null,
                onSubmitted: (_) => _submit(),
                enabled: !_loading,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Mínimo 8 caracteres, con mayúscula, minúscula y número.', style: AppTextStyles.small.copyWith(color: Colors.white70)),
              const SizedBox(height: AppSpacing.lg),
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
              PrimaryButton(label: 'Guardar y entrar', variant: ButtonVariant.white, loading: _loading, onPressed: _submit),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        ref.read(siteLinkProvider.notifier).clear();
                        context.go('/login');
                      },
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Ya tengo contraseña: iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
