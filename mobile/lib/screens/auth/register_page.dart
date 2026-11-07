import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/network/api_exception.dart';
import '../../widgets/theme/app_colors.dart';
import '../../widgets/theme/app_spacing.dart';
import '../../widgets/theme/app_text_styles.dart';
import '../../services/utils/validators.dart';
import '../../widgets/common/auth_background.dart';
import '../../widgets/common/auth_text_field.dart';
import '../../widgets/common/password_strength_bar.dart';
import '../../widgets/auth/legal_links.dart';
import '../../widgets/common/primary_button.dart';
import '../../services/providers/pending_visit_provider.dart';
import '../../services/providers/session_provider.dart';

/// Pantalla 3 · Crea tu cuenta (solo clientes). Al registrarse entra directo a /home.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _consent = false;
  String? _consentError;
  String? _error;
  Map<String, String> _fieldErrors = const {};

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _fieldErrors = const {};
    });
    final valid = _form.currentState!.validate();
    // Consentimiento expreso del aviso de privacidad (sin él no se crea la cuenta)
    setState(() => _consentError = _consent ? null : 'Acepta el aviso de privacidad para crear tu cuenta.');
    if (!valid || !_consent) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await ref.read(sessionProvider.notifier).register(name: _name.text, email: _email.text, phone: _phone.text, password: _password.text);
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'Regresar a iniciar sesión',
                    onPressed: _loading ? null : () => context.go('/login'),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Center(child: ZugarLogo(height: 40)),
                const SizedBox(height: AppSpacing.xl),
                Semantics(header: true, child: Text('Crea tu cuenta', style: AppTextStyles.authTitle)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ref.watch(pendingVisitProvider) != null
                      ? 'Crea tu cuenta para agendar la visita a la casa que elegiste. Después eliges el día y la hora.'
                      : 'Consulta tu propiedad, pagos y citas desde tu celular.',
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: AppSpacing.xl),
                AuthTextField(
                  label: 'Nombre completo',
                  controller: _name,
                  autofillHints: const [AutofillHints.name],
                  validator: Validators.name,
                  errorText: _fieldErrors['name'],
                  enabled: !_loading,
                ),
                const SizedBox(height: AppSpacing.lg),
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
                  label: 'Teléfono',
                  controller: _phone,
                  hint: '998 123 4567',
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\s+()-]')), LengthLimitingTextInputFormatter(20)],
                  validator: Validators.phone,
                  errorText: _fieldErrors['phone'],
                  enabled: !_loading,
                ),
                const SizedBox(height: AppSpacing.lg),
                AuthTextField(
                  label: 'Contraseña',
                  controller: _password,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: Validators.password,
                  errorText: _fieldErrors['password'],
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _submit(),
                  enabled: !_loading,
                ),
                const SizedBox(height: AppSpacing.sm),
                PasswordStrengthBar(password: _password.text),
                const SizedBox(height: AppSpacing.md),
                PrivacyConsentField(value: _consent, error: _consentError, color: Colors.white, onChanged: (v) => setState(() {
                      _consent = v;
                      if (v) _consentError = null;
                    })),
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
                PrimaryButton(label: 'Crear cuenta', variant: ButtonVariant.white, loading: _loading, onPressed: _submit),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: _loading ? null : () => context.go('/login'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
