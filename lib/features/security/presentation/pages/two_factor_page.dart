import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/models/two_factor_model.dart';
import '../../localization/security_strings.dart';
import '../../security_dependencies.dart';
import '../../../../core/storage/token_storage.dart';

class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({super.key});

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  TwoFactorModel? _status;
  bool _loading = true;
  bool _busy = false;
  String? _secret;
  String? _otpauthUrl;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final status = await SecurityDependencies.getTwoFactor();
      if (!mounted) return;
      setState(() {
        _status = status;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _start() async {
    setState(() => _busy = true);
    try {
      final setup = await SecurityDependencies.startTwoFactor();
      final qrData = await _resolveQrData(setup);
      if (!mounted) return;
      setState(() {
        _secret = setup.secret.trim().isEmpty ? null : setup.secret.trim();
        _otpauthUrl = qrData;
      });
      if (qrData == null || qrData.isEmpty) {
        _message('The server did not return a QR/provisioning value. The secret is shown below.');
      } else {
        _message(SecurityStrings.setupStarted);
      }
    } catch (error) {
      if (mounted) {
        _message(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _resolveQrData(TwoFactorSetupModel setup) async {
    final direct = setup.otpauthUrl.trim();
    if (direct.isNotEmpty) return direct;

    final secret = setup.secret.trim();
    if (secret.isEmpty) return null;

    // Laravel implementations sometimes return only the secret. In that case
    // build the standard TOTP provisioning URI locally so qr_flutter can render
    // the QR code immediately.
    final email = (await TokenStorage.getEmail() ?? 'account').trim();
    final account = email.isEmpty ? 'account' : email;
    return Uri(
      scheme: 'otpauth',
      host: 'totp',
      path: '/VibeLocate:$account',
      queryParameters: <String, String>{
        'secret': secret,
        'issuer': 'VibeLocate',
      },
    ).toString();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      _message(SecurityStrings.code6);
      return;
    }
    setState(() => _busy = true);
    try {
      await SecurityDependencies.verifyTwoFactor(code);
      if (!mounted) return;
      _codeController.clear();
      await _load();
      _message(SecurityStrings.enabledMessage);
    } catch (error) {
      if (mounted) {
        _message(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disable() async {
    setState(() => _busy = true);
    try {
      await SecurityDependencies.disableTwoFactor();
      if (!mounted) return;
      setState(() {
        _status = const TwoFactorModel(
          method: null,
          isEnabled: false,
          verifiedAt: null,
        );
        _secret = null;
        _otpauthUrl = null;
      });
      _message(SecurityStrings.disabledMessage);
    } catch (error) {
      if (mounted) {
        _message(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final enabled = _status?.isEnabled == true;
    final theme = Theme.of(context);
    final hasSetup = _secret?.isNotEmpty == true || _otpauthUrl?.isNotEmpty == true;

    return Scaffold(
      appBar: AppBar(title: Text(SecurityStrings.twoFactor)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  Card(
                    child: SwitchListTile(
                      value: enabled,
                      onChanged: _busy
                          ? null
                          : (value) => value ? _start() : _disable(),
                      title: Text(
                        SecurityStrings.authenticator,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        enabled
                            ? SecurityStrings.enabled
                            : SecurityStrings.notEnabled,
                      ),
                      secondary: Icon(
                        Icons.security_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (hasSetup && !enabled) ...[
                    const SizedBox(height: 16),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              SecurityStrings.setup,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 7),
                            Text(
                              SecurityStrings.scanQr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (_otpauthUrl?.isNotEmpty == true)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                child: QrImageView(
                                  data: _otpauthUrl!,
                                  size: 230,
                                  backgroundColor: Colors.white,
                                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                                ),
                              ),
                            if (_secret?.isNotEmpty == true) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SelectableText(
                                        _secret!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: SecurityStrings.copied,
                                      onPressed: () async {
                                        await Clipboard.setData(
                                          ClipboardData(text: _secret!),
                                        );
                                        if (mounted) {
                                          _message(SecurityStrings.copied);
                                        }
                                      },
                                      icon: const Icon(Icons.copy_outlined),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            TextField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText: SecurityStrings.code6,
                                prefixIcon: const Icon(Icons.password_rounded),
                                counterText: '',
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _busy ? null : _verify,
                                child: _busy
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(SecurityStrings.verifyEnable),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
