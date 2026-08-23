import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.country,
    required this.onCountryChanged,
    required this.label,
    required this.hint,
    required this.errorText,
  });

  final TextEditingController controller;
  final Country country;
  final ValueChanged<Country> onCountryChanged;
  final String label;
  final String hint;
  final String errorText;

  void _openCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      useSafeArea: true,
      onSelect: onCountryChanged,
      countryListTheme: CountryListThemeData(
        backgroundColor: AppColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        bottomSheetHeight:
        MediaQuery.sizeOf(context).height * 0.75,
        searchTextStyle:
        AppTextStyles.bodyMedium.copyWith(
          color: AppColors.navyDark,
        ),
        textStyle:
        AppTextStyles.bodyMedium.copyWith(
          color: AppColors.navyDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (_) {
        if (controller.text.trim().isEmpty) {
          return errorText;
        }

        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style:
              AppTextStyles.labelLarge.copyWith(
                color: AppColors.navyDark,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                BorderRadius.circular(10),
                border: Border.all(
                  color: field.hasError
                      ? AppColors.errorRed
                      : AppColors.grayBorder,
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () =>
                        _openCountryPicker(context),
                    borderRadius:
                    BorderRadius.circular(10),
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [
                          Text(
                            country.flagEmoji,
                            style:
                            const TextStyle(
                              fontSize: 21,
                            ),
                          ),

                          const SizedBox(width: 7),

                          Text(
                            '+${country.phoneCode}',
                            style: AppTextStyles
                                .bodyMedium
                                .copyWith(
                              color:
                              AppColors.navyDark,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),

                          const SizedBox(width: 3),

                          const Icon(
                            Icons
                                .keyboard_arrow_down_rounded,
                            size: 18,
                            color:
                            AppColors.grayTextSub,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 28,
                    color:
                    AppColors.grayBorderLight,
                  ),

                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      keyboardType:
                      TextInputType.phone,
                      textInputAction:
                      TextInputAction.next,
                      style: AppTextStyles
                          .bodyMedium
                          .copyWith(
                        color:
                        AppColors.navyDark,
                      ),
                      decoration:
                      InputDecoration(
                        hintText: hint,
                        hintStyle:
                        AppTextStyles
                            .bodyMedium
                            .copyWith(
                          color:
                          AppColors
                              .grayTextMuted,
                        ),
                        border:
                        InputBorder.none,
                        enabledBorder:
                        InputBorder.none,
                        focusedBorder:
                        InputBorder.none,
                        errorBorder:
                        InputBorder.none,
                        focusedErrorBorder:
                        InputBorder.none,
                        contentPadding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (field.hasError) ...[
              const SizedBox(height: 5),
              Padding(
                padding:
                const EdgeInsetsDirectional.only(
                  start: 4,
                ),
                child: Text(
                  field.errorText!,
                  style: AppTextStyles
                      .bodySmall
                      .copyWith(
                    color:
                    AppColors.errorRed,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}