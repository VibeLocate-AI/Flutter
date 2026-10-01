import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/models/two_factor_model.dart';
import '../../localization/security_strings.dart';
import '../../security_dependencies.dart';

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
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _codeController.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final status = await SecurityDependencies.getTwoFactor();
      if (!mounted) return;
      setState(() { _status = status; _loading = false; });
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
      if (!mounted) return;
      setState(() { _secret = setup.secret; _otpauthUrl = setup.otpauthUrl; });
      _message(SecurityStrings.setupStarted);
    } catch (error) {
      if (mounted) _message(error.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) { _message(SecurityStrings.code6); return; }
    setState(() => _busy = true);
    try {
      await SecurityDependencies.verifyTwoFactor(code);
      if (!mounted) return;
      _codeController.clear();
      await _load();
      _message(SecurityStrings.enabledMessage);
    } catch (error) {
      if (mounted) _message(error.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _disable() async {
    setState(() => _busy = true);
    try {
      await SecurityDependencies.disableTwoFactor();
      if (!mounted) return;
      setState(() { _status = const TwoFactorModel(method: null, isEnabled: false, verifiedAt: null); _secret = null; _otpauthUrl = null; });
      _message(SecurityStrings.disabledMessage);
    } catch (error) {
      if (mounted) _message(error.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  void _message(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final enabled = _status?.isEnabled == true;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(SecurityStrings.twoFactor)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
            children: [
              Card(child: SwitchListTile(value: enabled, onChanged: _busy ? null : (value) => value ? _start() : _disable(), title: Text(SecurityStrings.authenticator, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(enabled ? SecurityStrings.enabled : SecurityStrings.notEnabled))),
              if (!enabled && (_secret != null || _otpauthUrl != null)) ...[
                const SizedBox(height: 18),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(children: [
                      Icon(Icons.qr_code_2_rounded, size: 38, color: theme.colorScheme.primary),
                      const SizedBox(height: 10),
                      Text(SecurityStrings.setup, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(SecurityStrings.scanQr, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 20),
                      if (_otpauthUrl?.isNotEmpty == true) Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.colorScheme.outlineVariant)), child: QrImageView(data: _otpauthUrl!, size: 230, backgroundColor: theme.colorScheme.surface, errorCorrectionLevel: QrErrorCorrectLevel.M)),
                      const SizedBox(height: 16),
                      if (_secret?.isNotEmpty == true) ExpansionTile(title: Text(SecurityStrings.cannotScan), children: [Padding(padding: const EdgeInsets.all(12), child: Row(children: [Expanded(child: SelectableText(_secret!, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.1))), IconButton(onPressed: () async { await Clipboard.setData(ClipboardData(text: _secret!)); if (mounted) _message(SecurityStrings.copied); }, icon: const Icon(Icons.copy_outlined))]))]),
                      const SizedBox(height: 8),
                      TextField(controller: _codeController, keyboardType: TextInputType.number, maxLength: 6, inputFormatters: [FilteringTextInputFormatter.digitsOnly], textAlign: TextAlign.center, decoration: InputDecoration(labelText: SecurityStrings.code6, prefixIcon: const Icon(Icons.password_rounded), counterText: '')),
                      const SizedBox(height: 12),
                      SizedBox(width: double.infinity, child: FilledButton(onPressed: _busy ? null : _verify, child: _busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(SecurityStrings.verifyEnable))),
                    ]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
