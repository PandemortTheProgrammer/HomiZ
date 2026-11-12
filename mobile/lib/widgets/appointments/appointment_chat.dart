import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../services/utils/formatters.dart';
import '../common/auth_background.dart';
import '../../models/appointment.dart';

/// «Mensajes de la cita»: tarjeta tipo chat con burbujas gris (Zugar) y verde (cliente).
class AppointmentChat extends StatefulWidget {
  const AppointmentChat({super.key, required this.messages, required this.onSend, this.enabled = true, this.onClose});

  final List<AppointmentMessage> messages;

  /// Devuelve el error a mostrar o null si se envió.
  final Future<String?> Function(String body) onSend;
  final bool enabled;
  final VoidCallback? onClose;

  @override
  State<AppointmentChat> createState() => _AppointmentChatState();
}

class _AppointmentChatState extends State<AppointmentChat> {
  final _text = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _text.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final error = await widget.onSend(body);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _error = error;
      if (error == null) _text.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.cardAll, boxShadow: AppShadows.soft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm),
            child: Row(
              children: [
                const ZugarIcon(size: 24),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('Zugar', style: AppTextStyles.cardTitle)),
                if (widget.onClose != null) IconButton(tooltip: 'Ocultar mensajes', onPressed: widget.onClose, icon: const Icon(Icons.close_rounded)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: widget.messages.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Text('Aún no hay mensajes. Escribe si tienes alguna duda sobre tu cita.', textAlign: TextAlign.center, style: AppTextStyles.secondary),
                  )
                : Column(children: [for (final m in widget.messages) _Bubble(message: m)]),
          ),
          if (widget.enabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Text(_error!, style: AppTextStyles.secondary.copyWith(color: AppColors.danger)),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _text,
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 2000,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: const InputDecoration(hintText: 'Escribe un mensaje...', counterText: '', isDense: true),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: IconButton.filled(
                          tooltip: 'Enviar mensaje',
                          style: IconButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                          onPressed: _sending ? null : _send,
                          icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final AppointmentMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: mine ? AppColors.success : AppColors.chipInactive,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(mine ? 14 : 4),
              bottomRight: Radius.circular(mine ? 4 : 14),
            ),
          ),
          child: Column(
            crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(message.body, style: AppTextStyles.body.copyWith(color: mine ? Colors.white : AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${mine ? '' : '${message.sender} · '}${Fmt.time(message.createdAt)}',
                style: AppTextStyles.small.copyWith(color: mine ? Colors.white70 : AppColors.textMuted, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
