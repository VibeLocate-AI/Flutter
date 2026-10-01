import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../localization/security_strings.dart';
import '../../security_dependencies.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _otpController = TextEditingController();
  bool _loading = false;
  bool _otpSent = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_currentController.text.isEmpty || _newController.text.isEmpty || _confirmController.text.isEmpty) {
      _message(SecurityStrings.completeFields);
      return;
    }
    if (_newController.text != _confirmController.text) {
      _message(SecurityStrings.passwordsMismatch);
      return;
    }
    setState(() => _loading = true);
    try {
      await SecurityDependencies.sendChangePasswordOtp(currentPassword: _currentController.text, newPassword: _newController.text);
      if (!mounted) return;
      setState(() => _otpSent = true);
      _message(SecurityStrings.codeSent);
    } catch (error) {
      if (mounted) _message(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirm() async {
    if (_otpController.text.trim().length < 4) {
      _message(SecurityStrings.enterCode);
      return;
    }
    setState(() => _loading = true);
    try {
      await SecurityDependencies.changePassword(currentPassword: _currentController.text, newPassword: _newController.text, otp: _otpController.text.trim());
      if (!mounted) return;
      _message(SecurityStrings.passwordChanged);
      Navigator.pop(context);
    } catch (error) {
      if (mounted) _message(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(SecurityStrings.changePassword)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.lock_reset_rounded, size: 42, color: theme.colorScheme.primary),
                    const SizedBox(height: 14),
                    Text(SecurityStrings.changePassword, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(SecurityStrings.protectAccount, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 22),
                    _field(_currentController, SecurityStrings.currentPassword),
                    const SizedBox(height: 14),
                    _field(_newController, SecurityStrings.newPassword),
                    const SizedBox(height: 14),
                    _field(_confirmController, SecurityStrings.confirmPassword),
                    const SizedBox(height: 22),
                    if (!_otpSent)
                      _button(SecurityStrings.sendCode, _sendOtp)
                    else ...[
                      TextField(controller: _otpController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: InputDecoration(labelText: SecurityStrings.emailCode, prefixIcon: const Icon(Icons.mark_email_read_outlined)),),
                      const SizedBox(height: 16),
                      _button(SecurityStrings.confirmChange, _confirm),
                    ],
                    if (_loading) const Padding(padding: EdgeInsets.only(top: 14), child: LinearProgressIndicator()),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) => TextField(controller: controller, obscureText: true, decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.password_rounded)));

  Widget _button(String label, VoidCallback action) => SizedBox(width: double.infinity, child: FilledButton(onPressed: _loading ? null : action, child: Text(label)));
}
