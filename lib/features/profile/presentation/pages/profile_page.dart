import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../app/app_router.dart';
import '../../../../app/navigation/app_bar_actions.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/state/currency_manager.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/auth_dependencies.dart';
import '../../data/models/profile_model.dart';
import '../../profile_dependencies.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileModel? _profile;

  bool _loading = true;
  bool _saving = false;
  bool _currencySaving = false;
  bool _editing = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    // Render the locally persisted account immediately. The network request
    // updates it in the background instead of blocking the whole Profile page.
    final local = ProfileModel(
      id: await TokenStorage.getUserId() ?? 0,
      fullName: await TokenStorage.getLocalProfileName() ?? '',
      email: await TokenStorage.getEmail() ?? '',
      phone: await TokenStorage.getLocalProfilePhone() ?? '',
      city: await TokenStorage.getLocalProfileCity() ?? '',
      country: await TokenStorage.getLocalProfileCountry() ?? '',
      bio: '',
      avatarUrl: null,
      preferredLanguage: LocaleManager.instance.currentLocale.languageCode,
      currency: CurrencyManager.instance.currency,
      role: await TokenStorage.getRole() ?? 'tenant',
    );

    if (!mounted) return;
    setState(() {
      _setProfile(local);
      _loading = false;
    });

    try {
      final profile = await ProfileDependencies.getProfile().timeout(
        const Duration(seconds: 10),
      );

      if (!mounted) return;
      setState(() => _setProfile(profile));
    } on TimeoutException {
      // Local profile is already visible; do not block or show an error.
    } catch (_) {
      // Keep the locally persisted profile. A later pull-to-refresh can retry.
    }
  }

  void _setProfile(ProfileModel profile) {
    _profile = profile;

    final currency = profile.currency.trim().toUpperCase();
    if (CurrencyManager.supportedCurrencies.contains(currency)) {
      CurrencyManager.instance.setCurrency(currency);
    }

    _nameController.text = profile.fullName;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _cityController.text = profile.city;
    _countryController.text = profile.country;
    _bioController.text = profile.bio;
    TokenStorage.saveLocalProfile(
      name: profile.fullName,
      phone: profile.phone,
      city: profile.city,
      country: profile.country,
    );
  }

  Future<void> _saveProfile() async {
    final localization = AppLocalization.of(context);

    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      _showError(
        localization.translate('complete_required_fields'),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final profile = await ProfileDependencies.updateProfile(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _setProfile(profile);
        _editing = false;
      });

      _showMessage(
        AppLocalization.of(context).translate('profile_updated_successfully'),
      );
    } on ApiException catch (error) {
      if (mounted) {
        _showError(error.message);
      }
    } catch (error) {
      if (mounted) {
        _showError(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final profile = await ProfileDependencies.uploadAvatar(
        image.path,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _setProfile(profile);
      });

      _showMessage(
        AppLocalization.of(context).translate('profile_photo_updated'),
      );
    } on ApiException catch (error) {
      if (mounted) {
        _showError(error.message);
      }
    } catch (error) {
      if (mounted) {
        _showError(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _showCurrencyPicker() async {
    final current = CurrencyManager.instance.currency;
    final isArabic = LocaleManager.instance.isArabic;

    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Text(
                  AppLocalization.of(context).translate('currency_picker_title'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              RadioGroup<String>(
                groupValue: current,
                onChanged: (value) {
                  if (value != null) {
                    Navigator.pop(context, value);
                  }
                },
                child: Column(
                  children: CurrencyManager.supportedCurrencies.map(
                    (currency) => RadioListTile<String>(
                      value: currency,
                      title: Text(currency),
                      subtitle: Text(
                        _currencyName(currency, isArabic),
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null || selected == current || !mounted) return;

    final profile = _profile;
    if (profile == null) return;

    setState(() => _currencySaving = true);

    try {
      await CurrencyManager.instance.setCurrency(selected);

      // The current backend endpoint returns an acknowledgement, not a full
      // ProfileModel. CurrencyManager is the app-wide source of truth; keep
      // the existing profile object intact.
      await ProfileDependencies.completeProfile(
        preferredLanguage: profile.preferredLanguage.isEmpty
            ? LocaleManager.instance.currentLocale.languageCode
            : profile.preferredLanguage,
        currency: selected,
      );

      if (!mounted) return;
      setState(() {});

      _showMessage(
        AppLocalization.of(context).translate('currency_updated_successfully'),
      );
    } catch (error) {
      await CurrencyManager.instance.setCurrency(current);

      if (mounted) {
        _showError(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _currencySaving = false);
    }
  }

  String _currencyName(String code, bool isArabic) {
    final keys = <String, String>{
      'AED': 'currency_aed',
      'USD': 'currency_usd',
      'EUR': 'currency_eur',
      'GBP': 'currency_gbp',
      'SAR': 'currency_sar',
      'JOD': 'currency_jod',
      'ILS': 'currency_ils',
    };

    final key = keys[code];
    return key == null
        ? code
        : AppLocalization.of(context).translate(key);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          icon: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.logout_rounded,
              color: theme.colorScheme.error,
              size: 28,
            ),
          ),
          title: Text(
            AppLocalization.of(context).translate('confirm_logout'),
            style: AppTextStyles.headingSmall.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppLocalization.of(context).translate('confirm_logout_message'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          actionsPadding:
          const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        false,
                      );
                    },
                    child: Text(
                      AppLocalization.of(context).translate('cancel'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        true,
                      );
                    },
                    style:
                    FilledButton.styleFrom(
                      backgroundColor:
                      theme.colorScheme.error,
                      foregroundColor:
                      theme.colorScheme.onError,
                    ),
                    child: Text(
                      AppLocalization.of(context).translate('logout'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await _logout();
  }

  Future<void> _logout() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      await AuthDependencies.logout();
    } catch (_) {
      // The local session is still cleared by the auth data source when the
      // logout request succeeds. If the server is unavailable, clear the
      // local tokens below so the user is never trapped in a stale session.
      await TokenStorage.clearSession();
    }

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization =
    AppLocalization.of(context);
    final theme = Theme.of(context);
    final isArabic =
        LocaleManager.instance.isArabic;
    final profile = _profile;

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization.translate('profile'),
        ),
        actions: [
          const AgentAppBarAction(),
          const NotificationAppBarAction(),
          IconButton(
            tooltip: _editing
                ? AppLocalization.of(context).translate('save')
                : AppLocalization.of(context).translate('edit'),
            onPressed: _saving
                ? null
                : () {
              if (_editing) {
                _saveProfile();
              } else {
                setState(() {
                  _editing = true;
                });
              }
            },
            icon: Icon(
              _editing
                  ? Icons.check_rounded
                  : Icons.edit_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            36,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints:
                const BoxConstraints(
                  maxWidth: 620,
                ),
                child: Column(
                  children: [
                    _buildProfileHeader(
                      theme,
                      profile,
                      isArabic,
                    ),
                    const SizedBox(height: 28),
                    _buildPersonalSection(
                      theme,
                      isArabic,
                      localization,
                    ),
                    const SizedBox(height: 20),
                    _buildPreferencesSection(
                      theme,
                      isArabic,
                    ),
                    const SizedBox(height: 20),
                    _buildLogoutButton(
                      theme,
                      isArabic,
                    ),
                    // Keep the logout button above the floating bottom navigation.
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      ThemeData theme,
      ProfileModel? profile,
      bool isArabic,
      ) {
    final initials =
    profile?.fullName.trim().isNotEmpty ==
        true
        ? profile!.fullName
        .trim()
        .substring(0, 1)
        .toUpperCase()
        : 'U';

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding:
              const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme
                      .primary
                      .withValues(
                    alpha: 0.18,
                  ),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 54,
                backgroundColor:
                AppColors.navyPrimary,
                backgroundImage:
                profile?.avatarUrl != null
                    ? NetworkImage(
                  profile!.avatarUrl!,
                )
                    : null,
                child:
                profile?.avatarUrl == null
                    ? Text(
                  initials,
                  style: AppTextStyles
                      .headingLarge
                      .copyWith(
                    color:
                    Colors.white,
                    fontSize: 34,
                  ),
                )
                    : null,
              ),
            ),
            PositionedDirectional(
              bottom: 0,
              end: 0,
              child: Material(
                color:
                theme.colorScheme.primary,
                shape:
                const CircleBorder(),
                child: InkWell(
                  onTap: _saving
                      ? null
                      : _pickAvatar,
                  customBorder:
                  const CircleBorder(),
                  child: const Padding(
                    padding:
                    EdgeInsets.all(10),
                    child: Icon(
                      Icons
                          .camera_alt_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          profile?.fullName.isNotEmpty ==
              true
              ? profile!.fullName
              : AppLocalization.of(context).translate('default_user'),
          style:
          AppTextStyles.headingMedium
              .copyWith(
            color:
            theme.colorScheme.onSurface,
            fontWeight:
            FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        if (profile?.email.isNotEmpty ==
            true) ...[
          const SizedBox(height: 4),
          Text(
            profile!.email,
            style:
            AppTextStyles.bodyMedium
                .copyWith(
              color: theme.colorScheme
                  .onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildPersonalSection(
      ThemeData theme,
      bool isArabic,
      AppLocalization localization,
      ) {
    final sectionTitle =
    localization.translate(
      'personal_information',
    );

    return _SectionCard(
      title: sectionTitle,
      child: AnimatedSwitcher(
        duration:
        const Duration(milliseconds: 200),
        child: _editing
            ? _buildEditForm(
          theme,
          isArabic,
        )
            : _buildReadOnlyInfo(
          theme,
          isArabic,
          localization,
        ),
      ),
    );
  }

  Widget _buildReadOnlyInfo(
      ThemeData theme,
      bool isArabic,
      AppLocalization localization,
      ) {
    return Column(
      key: const ValueKey('read-only'),
      children: [
        _InfoRow(
          icon:
          Icons.person_outline_rounded,
          title:
          localization.translate(
            'full_name',
          ),
          value: _valueOrFallback(
            _nameController.text,
            AppLocalization.of(context).translate('profile_not_added'),
          ),
        ),
        _InfoRow(
          icon:
          Icons.email_outlined,
          title:
          localization.translate(
            'email',
          ),
          value: _valueOrFallback(
            _emailController.text,
            AppLocalization.of(context).translate('profile_not_added'),
          ),
        ),
        _InfoRow(
          icon:
          Icons.phone_outlined,
          title:
          localization.translate(
            'phone',
          ),
          value: _valueOrFallback(
            _phoneController.text,
            AppLocalization.of(context).translate('profile_not_added'),
          ),
        ),
        _InfoRow(
          icon:
          Icons.location_city_outlined,
          title:
          AppLocalization.of(context).translate('city'),
          value: _valueOrFallback(
            _cityController.text,
            AppLocalization.of(context).translate('profile_not_added'),
          ),
        ),
        _InfoRow(
          icon:
          Icons.public_outlined,
          title:
          AppLocalization.of(context).translate('country'),
          value: _valueOrFallback(
            _countryController.text,
            AppLocalization.of(context).translate('profile_not_added'),
          ),
        ),
        _InfoRow(
          icon: Icons.notes_rounded,
          title:
          localization.translate(
            'bio',
          ),
          value: _valueOrFallback(
            _bioController.text,
            AppLocalization.of(context).translate('profile_not_added'),
          ),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildEditForm(
      ThemeData theme,
      bool isArabic,
      ) {
    return Column(
      key: const ValueKey('edit-form'),
      children: [
        _buildField(
          controller: _nameController,
          label: AppLocalization.of(context).translate('full_name'),
          icon:
          Icons.person_outline_rounded,
        ),
        _buildField(
          controller: _emailController,
          label: AppLocalization.of(context).translate('email'),
          icon: Icons.email_outlined,
          keyboardType:
          TextInputType.emailAddress,
        ),
        _buildField(
          controller: _phoneController,
          label: AppLocalization.of(context).translate('phone'),
          icon: Icons.phone_outlined,
          keyboardType:
          TextInputType.phone,
        ),
        _buildField(
          controller: _cityController,
          label:
          AppLocalization.of(context).translate('city'),
          icon:
          Icons.location_city_outlined,
        ),
        _buildField(
          controller: _countryController,
          label:
          AppLocalization.of(context).translate('country'),
          icon: Icons.public_outlined,
        ),
        _buildField(
          controller: _bioController,
          label:
          AppLocalization.of(context).translate('bio'),
          icon: Icons.notes_rounded,
          maxLines: 4,
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed:
            _saving ? null : _saveProfile,
            icon:
            const Icon(Icons.check_rounded),
            label: Text(
              AppLocalization.of(context).translate('save_changes'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(
      ThemeData theme,
      bool isArabic,
      ) {
    final localization = AppLocalization.of(context);
    return _SectionCard(
      title: localization.translate('preferences'),
      child: Column(
        children: [
          _PreferenceTile(
            icon: Icons.currency_exchange_rounded,
            title: localization.translate('currency'),
            subtitle: '${CurrencyManager.instance.currency} · ${_currencyName(CurrencyManager.instance.currency, isArabic)}',
            trailing: _currencySaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right_rounded),
            onTap: _currencySaving ? null : _showCurrencyPicker,
          ),
          const Divider(height: 1),
          _PreferenceTile(
            icon: Icons.settings_outlined,
            title: localization.translate('settings'),
            subtitle: localization.translate('settings_subtitle'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => Navigator.pushNamed(context, AppRouter.settingsPage),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(
      ThemeData theme,
      bool isArabic,
      ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed:
        _saving ? null : _confirmLogout,
        icon: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout_rounded),
        label: Text(
          AppLocalization.of(context).translate('logout'),
        ),
        style:
        OutlinedButton.styleFrom(
          foregroundColor:
          theme.colorScheme.error,
          side: BorderSide(
            color: theme.colorScheme.error
                .withValues(
              alpha: 0.40,
            ),
          ),
          minimumSize:
          const Size.fromHeight(54),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController
    controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration:
        InputDecoration(
          labelText: label,
          prefixIcon:
          Icon(icon),
        ),
      ),
    );
  }

  String _valueOrFallback(
      String value,
      String fallback,
      ) {
    final trimmed =
    value.trim();

    if (trimmed.isEmpty) {
      return fallback;
    }

    return trimmed;
  }

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _showError(
      String message,
      ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        Theme.of(context)
            .colorScheme
            .error,
      ),
    );
  }
}

class _SectionCard
    extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles
              .headingSmall
              .copyWith(
            color: theme
                .colorScheme
                .onSurface,
            fontWeight:
            FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.all(16),
          decoration:
          BoxDecoration(
            color: theme
                .colorScheme
                .surface,
            borderRadius:
            BorderRadius.circular(
              20,
            ),
            border: Border.all(
              color: theme
                  .colorScheme
                  .outlineVariant,
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _InfoRow
    extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool isLast;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      children: [
        Padding(
          padding:
          const EdgeInsets.symmetric(
            vertical: 13,
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                BoxDecoration(
                  color: theme
                      .colorScheme
                      .primary
                      .withValues(
                    alpha: 0.09,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color: theme
                      .colorScheme
                      .primary,
                  size: 20,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                      AppTextStyles
                          .labelSmall
                          .copyWith(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      value,
                      style:
                      AppTextStyles
                          .bodyMedium
                          .copyWith(
                        color: theme
                            .colorScheme
                            .onSurface,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: theme
                .colorScheme
                .outlineVariant,
          ),
      ],
    );
  }
}

class _PreferenceTile
    extends StatelessWidget {
  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          vertical: 5,
        ),
      leading: Container(
        width: 42,
        height: 42,
        decoration:
        BoxDecoration(
          color: theme
              .colorScheme
              .primary
              .withValues(
            alpha: 0.09,
          ),
          borderRadius:
          BorderRadius.circular(
            12,
          ),
        ),
        child: Icon(
          icon,
          color: theme
              .colorScheme
              .primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme
            .titleSmall
            ?.copyWith(
          fontWeight:
          FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme
            .bodySmall,
      ),
      trailing: trailing ??
          (onTap == null
              ? null
              : const Icon(Icons.chevron_right_rounded)),
        onTap: onTap,
      ),
    );
  }
}
