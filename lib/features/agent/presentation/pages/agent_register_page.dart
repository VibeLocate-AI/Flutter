import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/localization/localization.dart';
import '../../../auth/auth_dependencies.dart';
import '../../../auth/presentation/pages/verification_page.dart';

class AgentRegisterPage extends StatefulWidget {
  const AgentRegisterPage({super.key});

  @override
  State<AgentRegisterPage> createState() => _AgentRegisterPageState();
}

class _AgentRegisterPageState extends State<AgentRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _agency = TextEditingController();
  final _license = TextEditingController();
  final _city = TextEditingController(text: 'Dubai');
  final _country = TextEditingController(text: 'UAE');

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    for (final controller in [
      _first,
      _last,
      _email,
      _phone,
      _password,
      _confirm,
      _agency,
      _license,
      _city,
      _country,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate() || _loading) return;

    setState(() => _loading = true);
    try {
      await AuthDependencies.registerAgent(
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        city: _city.text.trim(),
        country: _country.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
        passwordConfirmation: _confirm.text,
        agencyName: _agency.text.trim(),
        licenseNumber: _license.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRouter.verification,
        arguments: VerificationPageArgs(
          email: _email.text.trim(),
          purpose: VerificationPurpose.emailVerification,
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final required = _required(value, 'Email');
    if (required != null) return required;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final required = _required(value, 'Password');
    if (required != null) return required;
    if (value!.length < 8) return 'Minimum 8 characters';
    return null;
  }

  String? _confirmValidator(String? value) {
    final required = _required(value, 'Confirm password');
    if (required != null) return required;
    if (value != _password.text) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final contentWidth = width > 760 ? 620.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('agent_register')),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  width < 380 ? 16 : 22,
                  18,
                  width < 380 ? 16 : 22,
                  28,
                ),
                children: [
                  Text(
                    localization.translate('agent_register_subtitle'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  _field(
                    label: localization.translate('first_name_label'),
                    controller: _first,
                    validator: (value) => _required(value, localization.translate('first_name_label')),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    label: localization.translate('last_name_label'),
                    controller: _last,
                    validator: (value) => _required(value, localization.translate('last_name_label')),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    label: localization.translate('agency_name'),
                    controller: _agency,
                    validator: (value) =>
                        _required(value, localization.translate('agency_name')),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    label: localization.translate('license_number'),
                    controller: _license,
                    validator: (value) => _required(
                      value,
                      localization.translate('license_number'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    label: localization.translate('email_label'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    label: localization.translate('phone_label'),
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) => _required(value, localization.translate('phone_label')),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          label: localization.translate('city_label'),
                          controller: _city,
                          validator: (value) => _required(value, localization.translate('city_label')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          label: localization.translate('country_label'),
                          controller: _country,
                          validator: (value) => _required(value, localization.translate('country_label')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    validator: _passwordValidator,
                    decoration: InputDecoration(
                      labelText: localization.translate('password_label'),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    label: localization.translate('confirm_password_label'),
                    controller: _confirm,
                    obscureText: true,
                    validator: _confirmValidator,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              localization.translate('create_agent_account'),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    localization.translate('after_agent_registration'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: TextCapitalization.sentences,
      autofillHints: _autofillHints(label),
      decoration: InputDecoration(labelText: label),
    );
  }

  Iterable<String>? _autofillHints(String label) {
    final lower = label.toLowerCase();
    if (lower == 'email') return const [AutofillHints.email];
    if (lower == 'phone') return const [AutofillHints.telephoneNumber];
    if (lower == 'password') return const [AutofillHints.newPassword];
    return null;
  }
}
