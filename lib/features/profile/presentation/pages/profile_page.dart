import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/localization/locale_manager.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_manager.dart';
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
    setState(() {
      _loading = true;
    });

    try {
      final profile = await ProfileDependencies.getProfile();

      if (!mounted) return;

      setState(() {
        _setProfile(profile);
      });
    } catch (error) {
      if (!mounted) return;

      _showError(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (!mounted){

      setState(() {
        _loading = false;
      });
    }
  }
  }

  void _setProfile(ProfileModel profile) {
    _profile = profile;

    _nameController.text = profile.fullName;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _cityController.text = profile.city;
    _countryController.text = profile.country;
    _bioController.text = profile.bio;
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

      if (!mounted) return;

      setState(() {
        _setProfile(profile);
        _editing = false;
      });

      _showMessage(
        LocaleManager.instance.isArabic
            ? 'تم تحديث الملف الشخصي بنجاح'
            : 'Profile updated successfully.',
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
      if (!mounted){

      setState(() {
        _saving = false;
      });
    }}
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (image == null) return;

    setState(() {
      _saving = true;
    });

    try {
      final profile = await ProfileDependencies.uploadAvatar(
        image.path,
      );

      if (!mounted) return;

      setState(() {
        _setProfile(profile);
      });

      _showMessage(
        LocaleManager.instance.isArabic
            ? 'تم تحديث الصورة الشخصية'
            : 'Profile photo updated.',
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
      if (!mounted){

      setState(() {
        _saving = false;
      });
    }
  }}

  Future<void> _changeLanguage(Locale locale) async {
    final previousLocale = LocaleManager.instance.currentLocale;

    LocaleManager.instance.setLocale(locale);

    try {
      final profile = _profile;

      if (profile == null) {
        return;
      }

      setState(() {
        _saving = true;
      });

      final updated = await ProfileDependencies.completeProfile(
        preferredLanguage: locale.languageCode,
        currency: profile.currency.isEmpty
            ? 'AED'
            : profile.currency,
      );

      if (!mounted) return;

      setState(() {
        _setProfile(updated);
      });
    } catch (error) {
      LocaleManager.instance.setLocale(previousLocale);

      if (mounted) {
        _showError(error.toString());
      }
    } finally {
      if (!mounted) {

      setState(() {
        _saving = false;
      });
    }}
  }

  void _changeTheme(ThemeMode mode) {
    ThemeManager.instance.setThemeMode(mode);
  }

  Future<void> _confirmLogout() async {
    final isArabic = LocaleManager.instance.isArabic;

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
            isArabic
                ? 'تأكيد تسجيل الخروج'
                : 'Confirm logout',
            style: AppTextStyles.headingSmall.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            isArabic
                ? 'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟'
                : 'Are you sure you want to log out of your account?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
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
                      Navigator.pop(context, false);
                    },
                    child: Text(
                      isArabic
                          ? 'إلغاء'
                          : 'Cancel',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    child: Text(
                      isArabic
                          ? 'تسجيل الخروج'
                          : 'Log out',
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
    try {
      await AuthDependencies.logout();
    } catch (_) {}

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
          (_) => false,
    );
  }

  Future<void> _showLanguagePicker() async {
    final isArabic = LocaleManager.instance.isArabic;
    final selected = LocaleManager.instance.currentLocale;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isArabic
                      ? 'اختيار اللغة'
                      : 'Choose language',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _PreferenceOption(
                  icon: Icons.language_rounded,
                  title: 'English',
                  selected: selected.languageCode == 'en',
                  onTap: () async {
                    Navigator.pop(context);
                    await _changeLanguage(
                      const Locale('en'),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _PreferenceOption(
                  icon: Icons.language_rounded,
                  title: 'العربية',
                  selected: selected.languageCode == 'ar',
                  onTap: () async {
                    Navigator.pop(context);
                    await _changeLanguage(
                      const Locale('ar'),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showThemePicker() async {
    final isArabic = LocaleManager.instance.isArabic;
    final currentMode = ThemeManager.instance.themeMode;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isArabic
                      ? 'مظهر التطبيق'
                      : 'App appearance',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _PreferenceOption(
                  icon: Icons.brightness_auto_rounded,
                  title: isArabic
                      ? 'النظام'
                      : 'System',
                  selected: currentMode == ThemeMode.system,
                  onTap: () {
                    _changeTheme(ThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                _PreferenceOption(
                  icon: Icons.light_mode_rounded,
                  title: isArabic
                      ? 'الوضع الفاتح'
                      : 'Light',
                  selected: currentMode == ThemeMode.light,
                  onTap: () {
                    _changeTheme(ThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                _PreferenceOption(
                  icon: Icons.dark_mode_rounded,
                  title: isArabic
                      ? 'الوضع الداكن'
                      : 'Dark',
                  selected: currentMode == ThemeMode.dark,
                  onTap: () {
                    _changeTheme(ThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final theme = Theme.of(context);
    final isArabic = LocaleManager.instance.isArabic;
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
          IconButton(
            tooltip: _editing
                ? (isArabic ? 'حفظ' : 'Save')
                : (isArabic ? 'تعديل' : 'Edit'),
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
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            36,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
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
    final initials = profile?.fullName.trim().isNotEmpty == true
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
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(
                    alpha: 0.18,
                  ),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 54,
                backgroundColor: AppColors.navyPrimary,
                backgroundImage: profile?.avatarUrl != null
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null
                    ? Text(
                  initials,
                  style: AppTextStyles.headingLarge
                      .copyWith(
                    color: Colors.white,
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
                color: theme.colorScheme.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: _saving ? null : _pickAvatar,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.camera_alt_rounded,
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
          profile?.fullName.isNotEmpty == true
              ? profile!.fullName
              : (isArabic ? 'المستخدم' : 'User'),
          style: AppTextStyles.headingMedium.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        if (profile?.email.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(
            profile!.email,
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
    final sectionTitle = localization.translate(
      'personal_information',
    );

    return _SectionCard(
      title: sectionTitle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
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
          icon: Icons.person_outline_rounded,
          title: localization.translate('full_name'),
          value: _valueOrFallback(
            _nameController.text,
            isArabic ? 'غير مضاف' : 'Not added',
          ),
        ),
        _InfoRow(
          icon: Icons.email_outlined,
          title: localization.translate('email'),
          value: _valueOrFallback(
            _emailController.text,
            isArabic ? 'غير مضاف' : 'Not added',
          ),
        ),
        _InfoRow(
          icon: Icons.phone_outlined,
          title: localization.translate('phone'),
          value: _valueOrFallback(
            _phoneController.text,
            isArabic ? 'غير مضاف' : 'Not added',
          ),
        ),
        _InfoRow(
          icon: Icons.location_city_outlined,
          title: isArabic ? 'المدينة' : 'City',
          value: _valueOrFallback(
            _cityController.text,
            isArabic ? 'غير مضاف' : 'Not added',
          ),
        ),
        _InfoRow(
          icon: Icons.public_outlined,
          title: isArabic ? 'الدولة' : 'Country',
          value: _valueOrFallback(
            _countryController.text,
            isArabic ? 'غير مضاف' : 'Not added',
          ),
        ),
        _InfoRow(
          icon: Icons.notes_rounded,
          title: localization.translate('bio'),
          value: _valueOrFallback(
            _bioController.text,
            isArabic ? 'غير مضاف' : 'Not added',
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
          label: isArabic ? 'الاسم الكامل' : 'Full name',
          icon: Icons.person_outline_rounded,
        ),
        _buildField(
          controller: _emailController,
          label: isArabic
              ? 'البريد الإلكتروني'
              : 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        _buildField(
          controller: _phoneController,
          label: isArabic ? 'رقم الهاتف' : 'Phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        _buildField(
          controller: _cityController,
          label: isArabic ? 'المدينة' : 'City',
          icon: Icons.location_city_outlined,
        ),
        _buildField(
          controller: _countryController,
          label: isArabic ? 'الدولة' : 'Country',
          icon: Icons.public_outlined,
        ),
        _buildField(
          controller: _bioController,
          label: isArabic ? 'نبذة عني' : 'Bio',
          icon: Icons.notes_rounded,
          maxLines: 4,
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saving ? null : _saveProfile,
            icon: const Icon(Icons.check_rounded),
            label: Text(
              isArabic
                  ? 'حفظ التغييرات'
                  : 'Save changes',
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
    final themeManager = ThemeManager.instance;

    return _SectionCard(
      title: isArabic ? 'التفضيلات' : 'Preferences',
      child: Column(
        children: [
          _PreferenceTile(
            icon: Icons.language_rounded,
            title: isArabic
                ? 'اللغة'
                : 'Language',
            subtitle: LocaleManager.instance.isArabic
                ? 'العربية'
                : 'English',
            onTap: _saving
                ? null
                : _showLanguagePicker,
          ),
          const Divider(height: 1),
          _PreferenceTile(
            icon: themeManager.isDark
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            title: isArabic
                ? 'المظهر'
                : 'Appearance',
            subtitle: _themeLabel(
              themeManager.themeMode,
              isArabic,
            ),
            onTap: _showThemePicker,
          ),
          const Divider(height: 1),
          _PreferenceTile(
            icon: Icons.payments_outlined,
            title: isArabic ? 'العملة' : 'Currency',
            subtitle: _profile?.currency.isNotEmpty == true
                ? _profile!.currency
                : 'AED',
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
        onPressed: _saving ? null : _confirmLogout,
        icon: const Icon(Icons.logout_rounded),
        label: Text(
          isArabic
              ? 'تسجيل الخروج'
              : 'Log out',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
          side: BorderSide(
            color: theme.colorScheme.error.withValues(
              alpha: 0.40,
            ),
          ),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  String _valueOrFallback(
      String value,
      String fallback,
      ) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return fallback;
    }

    return trimmed;
  }

  String _themeLabel(
      ThemeMode mode,
      bool isArabic,
      ) {
    switch (mode) {
      case ThemeMode.light:
        return isArabic ? 'فاتح' : 'Light';
      case ThemeMode.dark:
        return isArabic ? 'داكن' : 'Dark';
      case ThemeMode.system:
        return isArabic ? 'حسب النظام' : 'System';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headingSmall.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 13,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(
                    alpha: 0.09,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                        theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
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
            color: theme.colorScheme.outlineVariant,
          ),
      ],
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(
            alpha: 0.09,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
      trailing: onTap == null
          ? null
          : const Icon(
        Icons.chevron_right_rounded,
      ),
      onTap: onTap,
    );
  }
}

class _PreferenceOption extends StatelessWidget {
  const _PreferenceOption({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(
              alpha: 0.09,
            )
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}