import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/network/api_exception.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_spacing.dart';
import '../../widgets/theme/app_text_styles.dart';
import '../../services/utils/validators.dart';
import '../../widgets/common/auth_background.dart';
import '../../widgets/common/auth_text_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../services/providers/session_provider.dart';

/// «Crea tu contraseña»: aparece al entrar con la contraseña temporal del correo («olvidé mi contraseña»
/// o la cuenta que se creó sola desde el sitio). Hasta crearla no se puede usar el resto de la app.
class CreatePasswordPage extends ConsumerStatefulWidget {
  const CreatePasswordPage({super.key});

  @override
  ConsumerState<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends ConsumerState<CreatePasswordPage> {
  final _form = GlobalKey<FormState>();
  final _temporary = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  /// Si acaba de entrar con la temporal ya la tenemos; si volvió a abrir la app, se pide otra vez.
  String? get _known => ref.read(sessionProvider.notifier).temporaryPassword;

  @override
  void dispose() {
    _temporary.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // El router lo lleva a su inicio en cuanto la sesión ya no pide cambiarla.
      await ref.read(sessionProvider.notifier).createOwnPassword(current: _known ?? _temporary.text, next: _password.text);
    } catch (e) {
      if (mounted) setState(() => _error = ApiException.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(sessionProvider.select((s) => s.value?.name.split(' ').first));
    return Scaffold(
      body: AuthBackground(
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                '${name != null ? 'Hola, $name. ' : ''}Entraste con una contraseña temporal. Crea la tuya para seguir; la temporal dejará de servir.',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_known == null) ...[
                AuthTextField(
                  label: 'Contraseña temporal del correo',
                  controller: _temporary,
                  obscure: true,
                  validator: (v) => Validators.required(v, 'Escribe la contraseña temporal del correo.'),
                  enabled: !_loading,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
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
                onPressed: _loading ? null : () => ref.read(sessionProvider.notifier).logout(),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Salir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
