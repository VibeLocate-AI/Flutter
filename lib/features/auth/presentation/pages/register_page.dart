import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/legal_agreement_text.dart';
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
      return localization.translate('email_required');
    }

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return localization.translate('email_invalid');
    }

    return null;
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

    if (value.length < 6) {
      return localization.translate(
        'password_min',
      );
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

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    final localization = AppLocalization.of(context);

    if (!_formKey.currentState!.validate()) {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localization.translate(
            'register_success_demo',
          ),
        ),
      ),
    );

    // سيتم ربط Register UseCase + API لاحقًا.
  }

  void _continueWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalization.of(context).translate(
            'google_signup_demo',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final horizontalPadding =
    width < 360 ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: height < 700 ? 18 : 28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 26),

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AuthTextField(
                            controller:
                            _firstNameController,
                            label: localization.translate(
                              'first_name',
                            ),
                            hint: localization.translate(
                              'first_name_hint',
                            ),
                            prefixIcon:
                            Icons.person_outline,
                            keyboardType:
                            TextInputType.name,
                            textInputAction:
                            TextInputAction.next,
                            validator: (value) =>
                                _required(
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
                            label: localization.translate(
                              'last_name',
                            ),
                            hint: localization.translate(
                              'last_name_hint',
                            ),
                            prefixIcon:
                            Icons.person_outline,
                            keyboardType:
                            TextInputType.name,
                            textInputAction:
                            TextInputAction.next,
                            validator: (value) =>
                                _required(
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
                            controller: _cityController,
                            label: localization.translate(
                              'city',
                            ),
                            hint: localization.translate(
                              'city_hint',
                            ),
                            prefixIcon:
                            Icons.location_city_outlined,
                            keyboardType:
                            TextInputType.text,
                            textInputAction:
                            TextInputAction.next,
                            validator: (value) =>
                                _required(
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
                            label: localization.translate(
                              'country',
                            ),
                            hint: localization.translate(
                              'country_hint',
                            ),
                            prefixIcon:
                            Icons.public_outlined,
                            keyboardType:
                            TextInputType.text,
                            textInputAction:
                            TextInputAction.next,
                            validator: (value) =>
                                _required(
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
                      controller: _phoneController,
                      country: _selectedCountry,
                      onCountryChanged: (country) {
                        setState(() {
                          _selectedCountry = country;
                        });
                      },
                      label: localization.translate(
                        'phone_number',
                      ),
                      hint: localization.translate(
                        'phone_hint',
                      ),
                      errorText: localization.translate(
                        'phone_required',
                      ),
                    ),

                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _emailController,
                      label: localization.translate(
                        'email',
                      ),
                      hint: localization.translate(
                        'email_hint',
                      ),
                      prefixIcon:
                      Icons.email_outlined,
                      keyboardType:
                      TextInputType.emailAddress,
                      textInputAction:
                      TextInputAction.next,
                      validator: (value) =>
                          _emailValidator(
                            value,
                            localization,
                          ),
                    ),

                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _passwordController,
                      label: localization.translate(
                        'password',
                      ),
                      hint: localization.translate(
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
                      textInputAction:
                      TextInputAction.next,
                      validator: (value) =>
                          _passwordValidator(
                            value,
                            localization,
                          ),
                    ),

                    const SizedBox(height: 16),

                    AuthTextField(
                      controller:
                      _confirmPasswordController,
                      label: localization.translate(
                        'confirm_password',
                      ),
                      hint: localization.translate(
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
                      textInputAction:
                      TextInputAction.done,
                      validator: (value) =>
                          _confirmPasswordValidator(
                            value,
                            localization,
                          ),
                      onSubmitted: (_) => _register(),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Checkbox(
                            value: _acceptedTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptedTerms =
                                    value ?? false;
                              });
                            },
                            activeColor:
                            AppColors.navyPrimary,
                            materialTapTargetSize:
                            MaterialTapTargetSize
                                .shrinkWrap,
                          ),
                        ),

                        const SizedBox(width: 8),

                        const Expanded(
                          child: LegalAgreementText(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _register,
                        child: Text(
                          localization.translate(
                            'sign_up',
                          ),
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color:
                            AppColors.grayBorderLight,
                          ),
                        ),

                        Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: Text(
                            localization.translate(
                              'or',
                            ),
                            style: AppTextStyles.labelSmall
                                .copyWith(
                              color:
                              AppColors.grayTextMuted,
                            ),
                          ),
                        ),

                        const Expanded(
                          child: Divider(
                            color:
                            AppColors.grayBorderLight,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    SocialLoginButton(
                      label: localization.translate(
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
                            AppTextStyles.bodySmall
                                .copyWith(
                              color:
                              AppColors.grayTextSub,
                            ),
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRouter.login,
                            );
                          },
                          child: Text(
                            localization.translate(
                              'login',
                            ),
                            style:
                            AppTextStyles.labelMedium
                                .copyWith(
                              color:
                              AppColors.navyPrimary,
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