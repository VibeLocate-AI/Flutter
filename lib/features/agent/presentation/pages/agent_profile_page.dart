import 'package:flutter/material.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';

/// Agent-only verification screen.
///
/// The Laravel Postman contract exposes POST /api/agent/onboarding/license
/// without a request body. Therefore this screen does not invent BRN/ORN/
/// license fields and pretend that the endpoint accepts them.
class AgentProfilePage extends StatefulWidget {
  const AgentProfilePage({super.key});

  @override
  State<AgentProfilePage> createState() => _AgentProfilePageState();
}

class _AgentProfilePageState extends State<AgentProfilePage> {
  String _name = 'Real Estate Agent';
  String _email = '';
  String _phone = '';
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    final name = await TokenStorage.getLocalProfileName();
    final email = await TokenStorage.getEmail();
    final phone = await TokenStorage.getLocalProfilePhone();

    if (!mounted) return;
    setState(() {
      _name = name?.trim().isNotEmpty == true ? name!.trim() : _name;
      _email = email?.trim() ?? '';
      _phone = phone?.trim() ?? '';
      _loading = false;
    });
  }

  Future<void> _submitLicense() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      // Avoid sending an expired access token when this screen has been open
      // for a while. ApiClient also retries on 401, but refreshing here makes
      // the Agent action reliable before the request starts.
      final refreshed = await ApiClient.refreshSession();
      if (!refreshed) {
        final token = await TokenStorage.getAccessToken();
        if (token == null || token.isEmpty) {
          throw Exception('Your session has expired. Please log in again.');
        }
      }

      final response = await ApiClient.post(
        ApiEndpoints.agentLicense,
        authenticated: true,
      );

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('License request sent'),
          content: SingleChildScrollView(
            child: Text(
              _pretty(response),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _pretty(dynamic value) {
    if (value == null) return 'No response body.';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Verification')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 34),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(23),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    _initial,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (_email.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          _email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      if (_phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(_phone, style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          Icons.verified_user_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          'Agent Verification',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Text(
                    'The current Laravel Agent contract exposes one verification action: submit the agent license onboarding request.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Backend action',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 5),
                        SelectableText(
                          'POST /api/agent/onboarding/license',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Authentication: Bearer token • Request body: none',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _submitting ? null : _submitLicense,
                      icon: const Icon(Icons.send_rounded),
                      label: Text(
                        _submitting ? 'Submitting…' : 'Submit License Verification',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why there are no extra license fields',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'The endpoint contract currently available in the Postman collection does not define BRN, ORN, trade-license or document fields for this request. They were intentionally not added here so the Flutter UI does not send data the backend does not accept.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _initial {
    final value = _name.trim();
    return value.isEmpty ? 'A' : value.substring(0, 1).toUpperCase();
  }
}
