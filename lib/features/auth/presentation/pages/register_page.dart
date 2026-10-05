import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_locate_ai/features/auth/presentation/pages/verification_page.dart';

import '../../../../app/app_router.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/state/location_manager.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../auth_dependencies.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/legal_agreement_text.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/phone_number_field.dart';
import '../widgets/social_login_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final TextEditingController _firstNameController =
  TextEditingController();

  final TextEditingController _lastNameController =
  TextEditingController();

  final TextEditingController _cityController =
  TextEditingController();

  final TextEditingController _countryController =
  TextEditingController();

  final TextEditingController _phoneController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  Country _selectedCountry = Country(
    phoneCode: '970',
    countryCode: 'PS',
    e164Sc: 970,
    geographic: true,
    level: 1,
    name: 'Palestine',
    example: '',
    displayName: 'Palestine (+970)',
    displayNameNoCountryCode: 'Palestine',
    e164Key: '970',
  );

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;
  bool _isAgent = false;
  String? _identityImagePath;

  final TextEditingController _agencyController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final location = LocationManager.instance;
    if (location.city.isNotEmpty) _cityController.text = location.city;
    if (location.country.isNotEmpty) _countryController.text = location.country;
    if (location.city.isEmpty && location.country.isEmpty) {
      location.updateCurrentLocation().then((_) {
        if (!mounted) return;
        setState(() {
          if (_cityController.text.isEmpty) {
            _cityController.text = location.city;
          }
          if (_countryController.text.isEmpty) {
            _countryController.text = location.country;
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _agencyController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  String? _required(
      String? value,
      String message,
      ) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  String? _emailValidator(
      String? value,
      AppLocalization localization,
      ) {
    if (value == null || value.trim().isEmpty) {
      return localization.translate(
        'email_required',
      );
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return localization.translate(
        'email_invalid',
      );
    }

    return null;
  }

  bool _isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(
          r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]+=;]',
        ).hasMatch(password);
  }

  String? _passwordValidator(
      String? value,
      AppLocalization localization,
      ) {
    if (value == null || value.isEmpty) {
      return localization.translate(
        'password_required',
      );
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }

    if (!RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]+=;]',
    ).hasMatch(value)) {
      return 'Password must contain a special character';
    }

    return null;
  }

  String? _confirmPasswordValidator(
      String? value,
      AppLocalization localization,
      ) {
    if (value == null || value.isEmpty) {
      return localization.translate(
        'confirm_password_required',
      );
    }

    if (value != _passwordController.text) {
      return localization.translate(
        'passwords_not_match',
      );
    }

    return null;
  }

  Future<void> _pickIdentityImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (image == null || !mounted) return;
    setState(() => _identityImagePath = image.path);
  }

  Future<void> _saveIdentityImageLocally(String email) async {
    final path = _identityImagePath;
    if (path == null || path.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('agent_identity_document_$email', path);
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    final localization =
    AppLocalization.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final firstName =
    _firstNameController.text.trim();

    final lastName =
    _lastNameController.text.trim();

    final city =
    _cityController.text.trim();

    final country =
    _countryController.text.trim();

    final email =
    _emailController.text.trim();

    final phone =
        '+${_selectedCountry.phoneCode}'
        '${_phoneController.text.replaceAll(' ', '')}';

    final password =
        _passwordController.text;

    final passwordConfirmation =
        _confirmPasswordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        city.isEmpty ||
        country.isEmpty ||
        email.isEmpty ||
        _phoneController.text.trim().isEmpty ||
        password.isEmpty ||
        passwordConfirmation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localization.translate(
              'complete_required_fields',
            ),
          ),
        ),
      );
      return;
    }

    if (!_isStrongPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.translate('strong_password_required')),
        ),
      );
      return;
    }

    if (password != passwordConfirmation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.translate('passwords_not_match')),
        ),
      );
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localization.translate(
              'accept_terms_required',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isAgent) {
        if (_agencyController.text.trim().isEmpty ||
            _licenseController.text.trim().isEmpty ||
            _identityImagePath == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localization.translate('agent_registration_complete_fields'),
              ),
            ),
          );
          return;
        }

        await AuthDependencies.registerAgent(
          firstName: firstName,
          lastName: lastName,
          city: city,
          country: country,
          email: email,
          phone: phone,
          password: password,
          passwordConfirmation: passwordConfirmation,
          agencyName: _agencyController.text.trim(),
          licenseNumber: _licenseController.text.trim(),
        );
        // The supplied backend collection does not expose an identity-document
        // field or upload endpoint for /api/agent/register. Keep the selected
        // document staged locally instead of silently sending it as another field.
        await _saveIdentityImageLocally(email);
      } else {
        await AuthDependencies.register(
          firstName: firstName,
          lastName: lastName,
          city: city,
          country: country,
          email: email,
          phone: phone,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.pushNamed(
        context,
        AppRouter.verification,
        arguments: VerificationPageArgs(
          email: email,
          purpose:
          VerificationPurpose.emailVerification,
        ),
      );
    } on ValidationException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localization.translate(
              'generic_api_error',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _continueWithGoogle() async {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint(
        'GOOGLE REGISTER: Starting Google Sign-In...',
      );

      await AuthDependencies.loginWithGoogle();

      debugPrint(
        'GOOGLE REGISTER: Laravel authentication successful.',
      );

      if (!mounted) {
        return;
      }

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.home,
            (route) => false,
      );
    } on ApiException catch (e) {
      debugPrint(
        'GOOGLE REGISTER API ERROR: ${e.message}',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google API Error: ${e.message}',
          ),
          duration:
          const Duration(seconds: 8),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'GOOGLE REGISTER ERROR: $e',
      );

      debugPrint(
        'GOOGLE REGISTER STACK TRACE: $stackTrace',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Register Error: $e',
          ),
          duration:
          const Duration(seconds: 8),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization =
    AppLocalization.of(context);

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final horizontalPadding =
    width < 360 ? 20.0 : 24.0;

    final colorScheme =
        Theme.of(context).colorScheme;

    final passwordsMatch =
        _confirmPasswordController.text.isNotEmpty &&
            _confirmPasswordController.text ==
                _passwordController.text;

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics:
          const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: height < 700 ? 18 : 28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 430,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 52,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _AccountTypeOption(
                              label: localization.translate('regular_user'),
                              selected: !_isAgent,
                              onTap: _isLoading
                                  ? null
                                  : () => setState(() => _isAgent = false),
                            ),
                          ),
                          Expanded(
                            child: _AccountTypeOption(
                              label: localization.translate('real_estate_agent'),
                              selected: _isAgent,
                              onTap: _isLoading
                                  ? null
                                  : () => setState(() => _isAgent = true),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isAgent) ...[
                      const SizedBox(height: 14),
                      AuthTextField(
                        controller: _agencyController,
                        label: localization.translate('agency_name'),
                        hint: localization.translate('agency_name'),
                        prefixIcon: Icons.business_outlined,
                        validator: (value) => _isAgent
                            ? _required(
                                value,
                                localization.translate('agency_name_required'),
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),
                      AuthTextField(
                        controller: _licenseController,
                        label: localization.translate('license_number'),
                        hint: localization.translate('license_number'),
                        prefixIcon: Icons.badge_outlined,
                        validator: (value) => _isAgent
                            ? _required(
                                value,
                                localization.translate('license_required'),
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _pickIdentityImage,
                        icon: Icon(
                          _identityImagePath == null
                              ? Icons.badge_outlined
                              : Icons.check_circle_outline_rounded,
                        ),
                        label: Text(
                          _identityImagePath == null
                              ? localization.translate('upload_identity')
                              : localization.translate('identity_selected'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 26),
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AuthTextField(
                            controller:
                            _firstNameController,
                            label:
                            localization.translate(
                              'first_name',
                            ),
                            hint:
                            localization.translate(
                              'first_name_hint',
                            ),
                            prefixIcon:
                            Icons.person_outline,
                            keyboardType:
                            TextInputType.name,
                            textInputAction:
                            TextInputAction.next,
                            validator:
                                (value) => _required(
                              value,
                              localization.translate(
                                'first_name_required',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AuthTextField(
                            controller:
                            _lastNameController,
                            label:
                            localization.translate(
                              'last_name',
                            ),
                            hint:
                            localization.translate(
                              'last_name_hint',
                            ),
                            prefixIcon:
                            Icons.person_outline,
                            keyboardType:
                            TextInputType.name,
                            textInputAction:
                            TextInputAction.next,
                            validator:
                                (value) => _required(
                              value,
                              localization.translate(
                                'last_name_required',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AuthTextField(
                            controller:
                            _cityController,
                            label:
                            localization.translate(
                              'city',
                            ),
                            hint:
                            localization.translate(
                              'city_hint',
                            ),
                            prefixIcon:
                            Icons
                                .location_city_outlined,
                            keyboardType:
                            TextInputType.text,
                            textInputAction:
                            TextInputAction.next,
                            validator:
                                (value) => _required(
                              value,
                              localization.translate(
                                'city_required',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AuthTextField(
                            controller:
                            _countryController,
                            label:
                            localization.translate(
                              'country',
                            ),
                            hint:
                            localization.translate(
                              'country_hint',
                            ),
                            prefixIcon:
                            Icons.public_outlined,
                            keyboardType:
                            TextInputType.text,
                            textInputAction:
                            TextInputAction.next,
                            validator:
                                (value) => _required(
                              value,
                              localization.translate(
                                'country_required',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PhoneNumberField(
                      controller:
                      _phoneController,
                      country:
                      _selectedCountry,
                      onCountryChanged:
                          (country) {
                        setState(() {
                          _selectedCountry =
                              country;
                        });
                      },
                      label:
                      localization.translate(
                        'phone_number',
                      ),
                      hint:
                      localization.translate(
                        'phone_hint',
                      ),
                      errorText:
                      localization.translate(
                        'phone_required',
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller:
                      _emailController,
                      label:
                      localization.translate(
                        'email',
                      ),
                      hint:
                      localization.translate(
                        'email_hint',
                      ),
                      prefixIcon:
                      Icons.email_outlined,
                      keyboardType:
                      TextInputType.emailAddress,
                      textInputAction:
                      TextInputAction.next,
                      validator:
                          (value) =>
                          _emailValidator(
                            value,
                            localization,
                          ),
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller:
                      _passwordController,
                      label:
                      localization.translate(
                        'password',
                      ),
                      hint:
                      localization.translate(
                        'password_hint',
                      ),
                      prefixIcon:
                      Icons.lock_outline,
                      obscureText:
                      _obscurePassword,
                      showPasswordToggle: true,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePassword =
                          !_obscurePassword;
                        });
                      },
                      onChanged: (_) {
                        setState(() {});
                      },
                      textInputAction:
                      TextInputAction.next,
                      validator:
                          (value) =>
                          _passwordValidator(
                            value,
                            localization,
                          ),
                    ),
                    PasswordStrengthIndicator(
                      password:
                      _passwordController.text,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller:
                      _confirmPasswordController,
                      label:
                      localization.translate(
                        'confirm_password',
                      ),
                      hint:
                      localization.translate(
                        'confirm_password_hint',
                      ),
                      prefixIcon:
                      Icons.lock_outline,
                      obscureText:
                      _obscureConfirmPassword,
                      showPasswordToggle: true,
                      onTogglePassword: () {
                        setState(() {
                          _obscureConfirmPassword =
                          !_obscureConfirmPassword;
                        });
                      },
                      onChanged: (_) {
                        setState(() {});
                      },
                      textInputAction:
                      TextInputAction.done,
                      validator:
                          (value) =>
                          _confirmPasswordValidator(
                            value,
                            localization,
                          ),
                      onSubmitted: (_) =>
                          _register(),
                    ),
                    if (passwordsMatch) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration:
                            const BoxDecoration(
                              color:
                              Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Passwords match',
                            style: TextStyle(
                              color:
                              Color(0xFF16A34A),
                              fontSize: 13,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Checkbox(
                            value:
                            _acceptedTerms,
                            onChanged:
                                (value) {
                              setState(() {
                                _acceptedTerms =
                                    value ??
                                        false;
                              });
                            },
                            activeColor:
                            colorScheme.primary,
                            materialTapTargetSize:
                            MaterialTapTargetSize
                                .shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child:
                          LegalAgreementText(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child:
                      ElevatedButton(
                        onPressed:
                        _isLoading
                            ? null
                            : _register,
                        child: _isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          localization
                              .translate(
                            'sign_up',
                          ),
                          style:
                          AppTextStyles
                              .button,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: colorScheme
                                .outlineVariant,
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 12,
                          ),
                          child: Text(
                            localization
                                .translate(
                              'or',
                            ),
                            style:
                            AppTextStyles
                                .labelSmall
                                .copyWith(
                              color: colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: colorScheme
                                .outlineVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SocialLoginButton(
                      label:
                      localization.translate(
                        'continue_with_google',
                      ),
                      onPressed:
                      _continueWithGoogle,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            localization.translate(
                              'already_have_account',
                            ),
                            style:
                            AppTextStyles
                                .bodySmall
                                .copyWith(
                              color: colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator
                                .pushReplacementNamed(
                              context,
                              AppRouter.login,
                            );
                          },
                          child: Text(
                            localization.translate(
                              'login',
                            ),
                            style:
                            AppTextStyles
                                .labelMedium
                                .copyWith(
                              color:
                              colorScheme.primary,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class _AccountTypeOption extends StatelessWidget {
  const _AccountTypeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: .18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
