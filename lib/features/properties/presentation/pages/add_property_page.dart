import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/token_storage.dart';
import 'location_picker_page.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({
    super.key,
  });

  @override
  State<AddPropertyPage> createState() =>
      _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  final ScrollController _scrollController =
  ScrollController();

  final TextEditingController _titleController =
  TextEditingController();

  final TextEditingController _descriptionController =
  TextEditingController();

  final TextEditingController _priceController =
  TextEditingController();

  final TextEditingController _areaController =
  TextEditingController();

  final TextEditingController _bedroomsController =
  TextEditingController();

  final TextEditingController _bathroomsController =
  TextEditingController();

  final TextEditingController _addressController =
  TextEditingController();

  final TextEditingController _additionalAddressController =
  TextEditingController();

  final TextEditingController _buildingController =
  TextEditingController();

  final TextEditingController _latitudeController =
  TextEditingController();

  final TextEditingController _longitudeController =
  TextEditingController();

  final TextEditingController _phoneController =
  TextEditingController();

  final TextEditingController _whatsappController =
  TextEditingController();

  final ImagePicker _imagePicker =
  ImagePicker();

  final Map<String, GlobalKey> _fieldKeys =
  <String, GlobalKey>{};

  final Map<String, String> _serverErrors =
  <String, String>{};

  final Map<String, String> _detailImages =
  <String, String>{};

  final Set<String> _selectedFeatures =
  <String>{};

  final Set<String> _selectedContactMethods =
  <String>{
    'phone',
    'whatsapp',
  };

  List<_NeighborhoodOption> _neighborhoods =
  <_NeighborhoodOption>[];

  Timer? _currencyTimer;

  int _currentStep = 0;
  int _conversionRequestId = 0;

  int? _selectedNeighborhoodId;

  bool _loadingNeighborhoods = true;
  bool _isConvertingPrice = false;
  bool _isSubmitting = false;

  String? _neighborhoodLoadError;

  String? _coverImagePath;

  double? _aedPrice;
  double? _exchangeRate;

  int _typeId = 1;

  String _listingType = 'sale';
  String _propertyCondition = 'ready';
  String _selectedCurrency = 'AED';

  final Map<int, Map<String, String>> _propertyTypes =
  const <int, Map<String, String>>{
    1: {
      'en': 'Apartment',
      'ar': 'شقة',
    },
    2: {
      'en': 'Villa',
      'ar': 'فيلا',
    },
    3: {
      'en': 'Penthouse',
      'ar': 'بنتهاوس',
    },
    4: {
      'en': 'Townhouse',
      'ar': 'تاون هاوس',
    },
    5: {
      'en': 'House',
      'ar': 'منزل',
    },
    6: {
      'en': 'Office',
      'ar': 'مكتب',
    },
    7: {
      'en': 'Warehouse',
      'ar': 'مستودع',
    },
    8: {
      'en': 'Land',
      'ar': 'أرض',
    },
    9: {
      'en': 'Restaurant',
      'ar': 'مطعم',
    },
    10: {
      'en': 'Hotel',
      'ar': 'فندق',
    },
    11: {
      'en': 'Building',
      'ar': 'مبنى',
    },
    12: {
      'en': 'Commercial Shop',
      'ar': 'محل تجاري',
    },
    13: {
      'en': 'Clinic',
      'ar': 'عيادة',
    },
    14: {
      'en': 'School',
      'ar': 'مدرسة',
    },
    15: {
      'en': 'Showroom',
      'ar': 'صالة عرض',
    },
    16: {
      'en': 'Cafe',
      'ar': 'مقهى',
    },
  };

  final List<_FeatureOption> _features =
  const <_FeatureOption>[
    _FeatureOption(
      key: 'covered_parking',
      id: 7,
      en: 'Covered Parking',
      ar: 'موقف سيارات مغطى',
      icon: Icons.directions_car_filled_rounded,
    ),
    _FeatureOption(
      key: 'swimming_pool',
      id: 5,
      en: 'Swimming Pool',
      ar: 'مسبح',
      icon: Icons.pool_rounded,
    ),
    _FeatureOption(
      key: 'fitness_gym',
      id: 6,
      en: 'Fitness Gym',
      ar: 'صالة رياضية',
      icon: Icons.fitness_center_rounded,
    ),
    _FeatureOption(
      key: 'security',
      id: 8,
      en: '24/7 Security',
      ar: 'أمان 24/7',
      icon: Icons.security_rounded,
    ),
    _FeatureOption(
      key: 'balcony',
      id: 9,
      en: 'Balcony / Terrace',
      ar: 'شرفة / تراس',
      icon: Icons.balcony_rounded,
    ),
    _FeatureOption(
      key: 'pet_friendly',
      id: null,
      en: 'Pet-Friendly',
      ar: 'مناسب للحيوانات',
      icon: Icons.pets_rounded,
    ),
    _FeatureOption(
      key: 'central_ac',
      id: 10,
      en: 'Central AC',
      ar: 'تكييف مركزي',
      icon: Icons.ac_unit_rounded,
    ),
    _FeatureOption(
      key: 'sea_view',
      id: 15,
      en: 'Sea / Marina View',
      ar: 'إطلالة بحرية / مارينا',
      icon: Icons.waves_rounded,
    ),
    _FeatureOption(
      key: 'smart_home',
      id: null,
      en: 'Smart Home',
      ar: 'منزل ذكي',
      icon: Icons.home_rounded,
    ),
    _FeatureOption(
      key: 'concierge',
      id: null,
      en: 'Concierge',
      ar: 'كونسيرج',
      icon: Icons.room_service_outlined,
    ),
    _FeatureOption(
      key: 'maid_room',
      id: null,
      en: 'Maid Room',
      ar: 'غرفة خادمة',
      icon: Icons.cleaning_services_rounded,
    ),
    _FeatureOption(
      key: 'jacuzzi',
      id: 17,
      en: 'Jacuzzi & Spa',
      ar: 'جاكوزي وسبا',
      icon: Icons.hot_tub_rounded,
    ),
  ];

  final List<_CurrencyOption> _currencies =
  const <_CurrencyOption>[
    _CurrencyOption(
      code: 'AED',
      en: 'AED',
      ar: 'درهم إماراتي',
    ),
    _CurrencyOption(
      code: 'USD',
      en: 'USD',
      ar: 'دولار أمريكي',
    ),
    _CurrencyOption(
      code: 'EUR',
      en: 'EUR',
      ar: 'يورو',
    ),
    _CurrencyOption(
      code: 'GBP',
      en: 'GBP',
      ar: 'جنيه إسترليني',
    ),
  ];

  bool get _isArabic {
    return Localizations.localeOf(context).languageCode ==
        'ar';
  }

  bool get _hasCoordinates {
    final latitude = double.tryParse(
      _latitudeController.text.trim(),
    );

    final longitude = double.tryParse(
      _longitudeController.text.trim(),
    );

    return latitude != null &&
        longitude != null &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  bool get _hasContact {
    return _phoneController.text.trim().isNotEmpty ||
        _whatsappController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _loadNeighborhoods();
  }

  @override
  void dispose() {
    _currencyTimer?.cancel();
    _scrollController.dispose();

    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _addressController.dispose();
    _additionalAddressController.dispose();
    _buildingController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isArabic ? 'إضافة عقار' : 'Add Property',
        ),
        leading: IconButton(
          onPressed: _handleBack,
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                8,
              ),
              child: _buildStepHeader(theme),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    120,
                  ),
                  children: [
                    _buildStepTitle(theme),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildCurrentStep(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
      _buildBottomBar(theme),
    );
  }

  void _handleBack() {
    if (_currentStep > 0) {
      _previousStep();
      return;
    }

    Navigator.of(context).pop();
  }

  Widget _buildStepHeader(
      ThemeData theme,
      ) {
    const count = 4;

    final titles = _isArabic
        ? const [
      'أساسي',
      'المواصفات',
      'الصور',
      'النشر',
    ]
        : const [
      'Basic',
      'Specs',
      'Media',
      'Publish',
    ];

    final subtitles = _isArabic
        ? const [
      'الخطوة 1',
      'الخطوة 2',
      'الخطوة 3',
      'الخطوة 4',
    ]
        : const [
      'Step 1',
      'Step 2',
      'Step 3',
      'Step 4',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        10,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: List.generate(
          count,
              (index) {
            final completed =
                index < _currentStep;

            final active =
                index == _currentStep;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                      onTap:
                      index <= _currentStep
                          ? () {
                        setState(() {
                          _currentStep =
                              index;
                        });

                        _scrollToTop();
                      }
                          : null,
                      child: Column(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration:
                            const Duration(
                              milliseconds:
                              220,
                            ),
                            width:
                            active
                                ? 40
                                : 34,
                            height:
                            active
                                ? 40
                                : 34,
                            decoration:
                            BoxDecoration(
                              color:
                              active ||
                                  completed
                                  ? theme
                                  .colorScheme
                                  .primary
                                  : theme
                                  .colorScheme
                                  .surfaceContainerHighest,
                              shape:
                              BoxShape.circle,
                            ),
                            child: Icon(
                              completed
                                  ? Icons.check_rounded
                                  : _stepIcon(
                                index,
                              ),
                              size:
                              19,
                              color:
                              active ||
                                  completed
                                  ? theme
                                  .colorScheme
                                  .onPrimary
                                  : theme
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(
                            height:
                            5,
                          ),
                          Text(
                            titles[index],
                            maxLines:
                            1,
                            overflow:
                            TextOverflow.ellipsis,
                            textAlign:
                            TextAlign.center,
                            style:
                            theme.textTheme.labelMedium?.copyWith(
                              fontSize:
                              10,
                              fontWeight:
                              FontWeight.w800,
                              color:
                              active
                                  ? theme
                                  .colorScheme
                                  .primary
                                  : theme
                                  .colorScheme
                                  .onSurface,
                            ),
                          ),
                          const SizedBox(
                            height:
                            2,
                          ),
                          Text(
                            subtitles[index],
                            maxLines:
                            1,
                            overflow:
                            TextOverflow.ellipsis,
                            style:
                            theme.textTheme.labelSmall?.copyWith(
                              fontSize:
                              8,
                              color:
                              active
                                  ? theme
                                  .colorScheme
                                  .primary
                                  : theme
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (index < 3)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin:
                        const EdgeInsets.symmetric(
                          horizontal:
                          3,
                        ),
                        color:
                        index < _currentStep
                            ? theme
                            .colorScheme
                            .primary
                            : theme
                            .colorScheme
                            .outlineVariant,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _stepIcon(
      int index,
      ) {
    switch (index) {
      case 0:
        return Icons.home_work_outlined;
      case 1:
        return Icons.tune_rounded;
      case 2:
        return Icons.photo_library_outlined;
      case 3:
        return Icons.publish_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _buildStepTitle(
      ThemeData theme,
      ) {
    String title;
    String subtitle;

    switch (_currentStep) {
      case 0:
        title = _isArabic
            ? 'بيانات العقار الأساسية'
            : 'Basic Property Information';
        subtitle = _isArabic
            ? 'أدخلي المعلومات الأساسية للعقار.'
            : 'Enter the basic property information.';
        break;

      case 1:
        title = _isArabic
            ? 'المواصفات والموقع'
            : 'Specifications & Location';
        subtitle = _isArabic
            ? 'حددي السعر والمواصفات وموقع العقار.'
            : 'Add pricing, specifications, and location.';
        break;

      case 2:
        title = _isArabic
            ? 'صور العقار'
            : 'Property Photos';
        subtitle = _isArabic
            ? 'صورة غلاف وخمس صور إضافية.'
            : 'One cover photo and five additional photos.';
        break;

      default:
        title = _isArabic
            ? 'النشر والتواصل'
            : 'Publish & Contact';
        subtitle = _isArabic
            ? 'أدخلي بيانات التواصل وراجعي العقار.'
            : 'Add contact information and review the listing.';
    }

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
          theme.textTheme.headlineSmall?.copyWith(
            fontSize:
            24,
            fontWeight:
            FontWeight.w800,
          ),
        ),
        const SizedBox(
          height:
          4,
        ),
        Text(
          subtitle,
          style:
          theme.textTheme.bodyMedium?.copyWith(
            color:
            theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep(
      ThemeData theme,
      ) {
    switch (_currentStep) {
      case 0:
        return _buildBasicStep(theme);
      case 1:
        return _buildSpecsStep(theme);
      case 2:
        return _buildMediaStep(theme);
      default:
        return _buildPublishStep(theme);
    }
  }

  Widget _buildBasicStep(
      ThemeData theme,
      ) {
    return Column(
      children: [
        _buildSection(
          title:
          _isArabic
              ? 'نوع العرض'
              : 'Listing Type',
          icon:
          Icons.sell_outlined,
          child:
          _buildListingTypes(theme),
        ),
        const SizedBox(
          height:
          16,
        ),
        _buildSection(
          title:
          _isArabic
              ? 'معلومات العقار'
              : 'Property Information',
          icon:
          Icons.home_work_outlined,
          child:
          Column(
            children: [
              _buildTextField(
                controller:
                _titleController,
                label:
                _isArabic
                    ? 'عنوان العقار'
                    : 'Property Title',
                hint:
                _isArabic
                    ? 'مثال: شقة فاخرة في دبي مارينا'
                    : 'Example: Luxury apartment in Dubai Marina',
                field:
                'title',
                icon:
                Icons.title_rounded,
                required:
                true,
                minLength:
                3,
              ),
              const SizedBox(
                height:
                14,
              ),
              _buildPropertyTypeDropdown(),
              const SizedBox(
                height:
                14,
              ),
              _buildConditionDropdown(),
              const SizedBox(
                height:
                14,
              ),
              _buildTextField(
                controller:
                _descriptionController,
                label:
                _isArabic
                    ? 'الوصف'
                    : 'Description',
                hint:
                _isArabic
                    ? 'اكتبي وصفًا تفصيليًا للعقار'
                    : 'Write a detailed property description',
                field:
                'description',
                icon:
                Icons.description_outlined,
                required:
                true,
                minLength:
                20,
                maxLines:
                6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListingTypes(
      ThemeData theme,
      ) {
    return LayoutBuilder(
      builder:
          (
          context,
          constraints,
          ) {
        if (constraints.maxWidth < 390) {
          return Column(
            children: [
              _buildListingTypeCard(
                theme:
                theme,
                value:
                'sale',
                title:
                _isArabic
                    ? 'للبيع'
                    : 'For Sale',
                subtitle:
                _isArabic
                    ? 'شراء العقار'
                    : 'Buy Property',
                icon:
                Icons.sell_outlined,
                selected:
                _listingType == 'sale',
              ),
              const SizedBox(
                height:
                10,
              ),
              _buildListingTypeCard(
                theme:
                theme,
                value:
                'rent',
                title:
                _isArabic
                    ? 'للإيجار'
                    : 'For Rent',
                subtitle:
                _isArabic
                    ? 'استئجار العقار'
                    : 'Lease Property',
                icon:
                Icons.key_outlined,
                selected:
                _listingType == 'rent',
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child:
              _buildListingTypeCard(
                theme:
                theme,
                value:
                'sale',
                title:
                _isArabic
                    ? 'للبيع'
                    : 'For Sale',
                subtitle:
                _isArabic
                    ? 'شراء العقار'
                    : 'Buy Property',
                icon:
                Icons.sell_outlined,
                selected:
                _listingType == 'sale',
              ),
            ),
            const SizedBox(
              width:
              12,
            ),
            Expanded(
              child:
              _buildListingTypeCard(
                theme:
                theme,
                value:
                'rent',
                title:
                _isArabic
                    ? 'للإيجار'
                    : 'For Rent',
                subtitle:
                _isArabic
                    ? 'استئجار العقار'
                    : 'Lease Property',
                icon:
                Icons.key_outlined,
                selected:
                _listingType == 'rent',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListingTypeCard({
    required ThemeData theme,
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
  }) {
    return InkWell(
      onTap:
      _isSubmitting
          ? null
          : () {
        setState(() {
          _listingType =
              value;
        });
      },
      borderRadius:
      BorderRadius.circular(
        18,
      ),
      child:
      AnimatedContainer(
        duration:
        const Duration(
          milliseconds:
          180,
        ),
        padding:
        const EdgeInsets.all(
          14,
        ),
        decoration:
        BoxDecoration(
          color:
          selected
              ? theme
              .colorScheme
              .primary
              .withValues(
            alpha:
            0.07,
          )
              : theme.colorScheme.surface,
          borderRadius:
          BorderRadius.circular(
            18,
          ),
          border:
          Border.all(
            color:
            selected
                ? theme
                .colorScheme
                .primary
                : theme
                .colorScheme
                .outlineVariant,
            width:
            selected
                ? 2
                : 1,
          ),
        ),
        child:
        Row(
          children: [
            Container(
              width:
              44,
              height:
              44,
              decoration:
              BoxDecoration(
                color:
                selected
                    ? theme
                    .colorScheme
                    .primary
                    : theme
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius:
                BorderRadius.circular(
                  13,
                ),
              ),
              child:
              Icon(
                icon,
                color:
                selected
                    ? theme
                    .colorScheme
                    .onPrimary
                    : theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
            const SizedBox(
              width:
              10,
            ),
            Expanded(
              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                    theme.textTheme.titleMedium?.copyWith(
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines:
                    1,
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons
                    .check_circle_rounded,
                color:
                theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyTypeDropdown() {
    return DropdownButtonFormField<int>(
      initialValue:
      _typeId,
      isExpanded:
      true,
      validator:
          (_) => _serverError(
        'type_id',
      ),
      decoration:
      InputDecoration(
        labelText:
        _isArabic
            ? 'نوع العقار'
            : 'Property Type',
        prefixIcon:
        const Icon(
          Icons.home_work_outlined,
        ),
      ),
      items:
      _propertyTypes.entries
          .map(
            (
            entry,
            ) =>
            DropdownMenuItem<int>(
              value:
              entry.key,
              child:
              Text(
                entry.value[
                _isArabic
                    ? 'ar'
                    : 'en']!,
                maxLines:
                1,
                overflow:
                TextOverflow.ellipsis,
              ),
            ),
      ).toList(),
      onChanged:
          (value) {
        if (value ==
            null) {
          return;
        }

        setState(() {
          _typeId =
              value;
        });
      },
    );
  }

  Widget _buildConditionDropdown() {
    return DropdownButtonFormField<String>(
      initialValue:
      _propertyCondition,
      isExpanded:
      true,
      decoration:
      InputDecoration(
        labelText:
        _isArabic
            ? 'حالة العقار'
            : 'Property Condition',
        prefixIcon:
        const Icon(
          Icons.verified_outlined,
        ),
      ),
      items: [
        DropdownMenuItem<String>(
          value:
          'ready',
          child:
          Text(
            _isArabic
                ? 'جاهز'
                : 'Ready',
          ),
        ),
        DropdownMenuItem<String>(
          value:
          'under_construction',
          child:
          Text(
            _isArabic
                ? 'قيد الإنشاء'
                : 'Under Construction',
          ),
        ),
        DropdownMenuItem<String>(
          value:
          'off_plan',
          child:
          Text(
            _isArabic
                ? 'على المخطط'
                : 'Off Plan',
          ),
        ),
      ],
      onChanged:
          (value) {
        if (value ==
            null) {
          return;
        }

        setState(() {
          _propertyCondition =
              value;
        });
      },
    );
  }

  Widget _buildSpecsStep(
      ThemeData theme,
      ) {
    return Column(
      children: [
        _buildSection(
          title:
          _isArabic
              ? 'السعر'
              : 'Price',
          icon:
          Icons.payments_outlined,
          child:
          Column(
            children: [
              LayoutBuilder(
                builder:
                    (
                    context,
                    constraints,
                    ) {
                  if (constraints.maxWidth <
                      390) {
                    return Column(
                      children: [
                        _buildPriceField(),
                        const SizedBox(
                          height:
                          12,
                        ),
                        _buildCurrencyDropdown(),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex:
                        6,
                        child:
                        _buildPriceField(),
                      ),
                      const SizedBox(
                        width:
                        12,
                      ),
                      Expanded(
                        flex:
                        4,
                        child:
                        _buildCurrencyDropdown(),
                      ),
                    ],
                  );
                },
              ),
              if (_selectedCurrency !=
                  'AED' &&
                  _priceController.text
                      .trim()
                      .isNotEmpty)
                Padding(
                  padding:
                  const EdgeInsets.only(
                    top:
                    10,
                  ),
                  child:
                  _buildAedPreview(
                    theme,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(
          height:
          16,
        ),
        _buildSection(
          title:
          _isArabic
              ? 'المواصفات'
              : 'Specifications',
          icon:
          Icons.straighten_rounded,
          child:
          Column(
            children: [
              _buildNumberField(
                controller:
                _areaController,
                label:
                _isArabic
                    ? 'المساحة (قدم²)'
                    : 'Area (sqft)',
                icon:
                Icons.square_foot_rounded,
                field:
                'area_sqft',
                required:
                true,
                decimal:
                true,
              ),
              const SizedBox(
                height:
                12,
              ),
              Row(
                children: [
                  Expanded(
                    child:
                    _buildNumberField(
                      controller:
                      _bedroomsController,
                      label:
                      _isArabic
                          ? 'غرف النوم'
                          : 'Bedrooms',
                      icon:
                      Icons.bed_outlined,
                      field:
                      'bedrooms',
                      required:
                      true,
                    ),
                  ),
                  const SizedBox(
                    width:
                    12,
                  ),
                  Expanded(
                    child:
                    _buildNumberField(
                      controller:
                      _bathroomsController,
                      label:
                      _isArabic
                          ? 'الحمامات'
                          : 'Bathrooms',
                      icon:
                      Icons.bathtub_outlined,
                      field:
                      'bathrooms',
                      required:
                      true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height:
          16,
        ),
        _buildSection(
          title:
          _isArabic
              ? 'المميزات والخدمات'
              : 'Amenities & Features',
          icon:
          Icons.auto_awesome_rounded,
          child:
          _buildFeatureSection(
            theme,
          ),
        ),
        const SizedBox(
          height:
          16,
        ),
        _buildSection(
          title:
          _isArabic
              ? 'الموقع'
              : 'Location',
          icon:
          Icons.location_on_outlined,
          child:
          _buildLocationSection(
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return _buildNumberField(
      controller:
      _priceController,
      label:
      _isArabic
          ? 'السعر'
          : 'Price',
      icon:
      Icons.payments_outlined,
      field:
      'price',
      required:
      true,
      decimal:
      true,
      onChanged:
          (_) {
        _currencyTimer?.cancel();

        _currencyTimer =
            Timer(
              const Duration(
                milliseconds:
                500,
              ),
              _updateAedPrice,
            );

        setState(() {});
      },
    );
  }

  Widget _buildCurrencyDropdown() {
    return DropdownButtonFormField<String>(
      initialValue:
      _selectedCurrency,
      isExpanded:
      true,
      decoration:
      InputDecoration(
        labelText:
        _isArabic
            ? 'العملة'
            : 'Currency',
        prefixIcon:
        const Icon(
          Icons.currency_exchange_rounded,
        ),
      ),
      items:
      _currencies
          .map(
            (
            currency,
            ) =>
            DropdownMenuItem<String>(
              value:
              currency.code,
              child:
              Text(
                _isArabic
                    ? currency.ar
                    : currency.en,
                maxLines:
                1,
                overflow:
                TextOverflow.ellipsis,
              ),
            ),
      ).toList(),
      onChanged:
          (value) {
        if (value ==
            null) {
          return;
        }

        setState(() {
          _selectedCurrency =
              value;
          _aedPrice =
          null;
          _exchangeRate =
          null;
        });

        _updateAedPrice();
      },
    );
  }

  Widget _buildAedPreview(
      ThemeData theme,
      ) {
    if (_isConvertingPrice) {
      return Container(
        width:
        double.infinity,
        padding:
        const EdgeInsets.all(
          12,
        ),
        decoration:
        BoxDecoration(
          color:
          theme
              .colorScheme
              .primary
              .withValues(
            alpha:
            0.07,
          ),
          borderRadius:
          BorderRadius.circular(
            14,
          ),
        ),
        child:
        Row(
          children: [
            const SizedBox(
              width:
              17,
              height:
              17,
              child:
              CircularProgressIndicator(
                strokeWidth:
                2,
              ),
            ),
            const SizedBox(
              width:
              10,
            ),
            Expanded(
              child:
              Text(
                _isArabic
                    ? 'جاري تحويل السعر إلى الدرهم...'
                    : 'Converting price to AED...',
              ),
            ),
          ],
        ),
      );
    }

    if (_aedPrice ==
        null) {
      return const SizedBox.shrink();
    }

    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        12,
      ),
      decoration:
      BoxDecoration(
        color:
        theme
            .colorScheme
            .primary
            .withValues(
          alpha:
          0.07,
        ),
        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),
      child:
      Row(
        children: [
          Icon(
            Icons.currency_exchange_rounded,
            color:
            theme.colorScheme.primary,
          ),
          const SizedBox(
            width:
            8,
          ),
          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  _isArabic
                      ? 'السعر بالدرهم'
                      : 'Price in AED',
                  style:
                  theme.textTheme.bodySmall,
                ),
                Text(
                  'AED ${_formatNumber(_aedPrice!)}',
                  style:
                  theme.textTheme.titleMedium?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                    color:
                    theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          if (_exchangeRate !=
              null)
            Text(
              '1 $_selectedCurrency = '
                  '${_exchangeRate!.toStringAsFixed(4)} AED',
              style:
              theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Future<void> _updateAedPrice() async {
    final amount =
    double.tryParse(
      _priceController.text.trim(),
    );

    if (amount == null ||
        amount <= 0) {
      if (!mounted) {
        return;
      }

      setState(() {
        _aedPrice = null;
        _exchangeRate = null;
        _isConvertingPrice =
        false;
      });

      return;
    }

    if (_selectedCurrency ==
        'AED') {
      if (!mounted) {
        return;
      }

      setState(() {
        _aedPrice =
            amount;
        _exchangeRate =
        1;
        _isConvertingPrice =
        false;
      });

      return;
    }

    final requestId =
    ++_conversionRequestId;

    setState(() {
      _isConvertingPrice =
      true;
    });

    try {
      final response =
      await http.get(
        Uri.parse(
          'https://open.er-api.com/v6/latest/$_selectedCurrency',
        ),
      ).timeout(
        const Duration(
          seconds:
          15,
        ),
      );

      if (response.statusCode !=
          200) {
        throw Exception(
          'Conversion failed',
        );
      }

      final decoded =
      jsonDecode(
        response.body,
      );

      if (decoded is! Map) {
        throw Exception(
          'Invalid response',
        );
      }

      final rates =
      decoded['rates'];

      if (rates is! Map) {
        throw Exception(
          'Rates missing',
        );
      }

      final rawRate =
      rates['AED'];

      final rate =
      rawRate is num
          ? rawRate.toDouble()
          : double.tryParse(
        rawRate.toString(),
      );

      if (rate == null ||
          rate <= 0) {
        throw Exception(
          'AED rate missing',
        );
      }

      if (!mounted ||
          requestId !=
              _conversionRequestId) {
        return;
      }

      setState(() {
        _aedPrice =
            amount * rate;
        _exchangeRate =
            rate;
        _isConvertingPrice =
        false;
      });
    } catch (_) {
      if (!mounted ||
          requestId !=
              _conversionRequestId) {
        return;
      }

      setState(() {
        _aedPrice =
        null;
        _exchangeRate =
        null;
        _isConvertingPrice =
        false;
      });
    }
  }

  Widget _buildFeatureSection(
      ThemeData theme,
      ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child:
              Text(
                _isArabic
                    ? 'اختاري المميزات الموجودة في العقار.'
                    : 'Select the available property features.',
                style:
                theme.textTheme.bodySmall,
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal:
                10,
                vertical:
                5,
              ),
              decoration:
              BoxDecoration(
                color:
                theme.colorScheme.primary
                    .withValues(
                  alpha:
                  0.07,
                ),
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),
              child:
              Text(
                _isArabic
                    ? '${_selectedFeatures.length} محددة'
                    : '${_selectedFeatures.length} selected',
                style:
                theme.textTheme.labelSmall?.copyWith(
                  color:
                  theme.colorScheme.primary,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height:
          14,
        ),
        LayoutBuilder(
          builder:
              (
              context,
              constraints,
              ) {
            final columns =
            constraints.maxWidth <
                390
                ? 1
                : 2;

            return GridView.builder(
              shrinkWrap:
              true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemCount:
              _features.length,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                columns,
                crossAxisSpacing:
                10,
                mainAxisSpacing:
                10,
                childAspectRatio:
                columns == 1
                    ? 4.4
                    : 2.7,
              ),
              itemBuilder:
                  (
                  context,
                  index,
                  ) {
                final feature =
                _features[index];

                final selected =
                _selectedFeatures
                    .contains(
                  feature.key,
                );

                return InkWell(
                  onTap:
                      () {
                    setState(() {
                      if (selected) {
                        _selectedFeatures
                            .remove(
                          feature.key,
                        );
                      } else {
                        _selectedFeatures
                            .add(
                          feature.key,
                        );
                      }
                    });
                  },
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                  child:
                  AnimatedContainer(
                    duration:
                    const Duration(
                      milliseconds:
                      180,
                    ),
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal:
                      12,
                      vertical:
                      10,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      selected
                          ? theme
                          .colorScheme
                          .primary
                          .withValues(
                        alpha:
                        0.06,
                      )
                          : theme
                          .colorScheme
                          .surface,
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                      border:
                      Border.all(
                        color:
                        selected
                            ? theme
                            .colorScheme
                            .primary
                            : theme
                            .colorScheme
                            .outlineVariant,
                        width:
                        selected
                            ? 2
                            : 1,
                      ),
                    ),
                    child:
                    Row(
                      children: [
                        Icon(
                          feature.icon,
                          size:
                          19,
                          color:
                          selected
                              ? theme
                              .colorScheme
                              .primary
                              : theme
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                        const SizedBox(
                          width:
                          8,
                        ),
                        Expanded(
                          child:
                          Text(
                            _isArabic
                                ? feature.ar
                                : feature.en,
                            maxLines:
                            1,
                            overflow:
                            TextOverflow.ellipsis,
                            style:
                            theme.textTheme.bodyMedium?.copyWith(
                              fontWeight:
                              selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons
                              .check_rounded
                              : Icons
                              .radio_button_unchecked_rounded,
                          size:
                          18,
                          color:
                          selected
                              ? theme
                              .colorScheme
                              .primary
                              : theme
                              .colorScheme
                              .outline,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection(
      ThemeData theme,
      ) {
    return Column(
      children: [
        _buildNeighborhoodDropdown(),
        const SizedBox(
          height:
          14,
        ),
        _buildTextField(
          controller:
          _addressController,
          label:
          _isArabic
              ? 'العنوان'
              : 'Address',
          hint:
          _isArabic
              ? 'أدخلي العنوان'
              : 'Enter property address',
          field:
          'address_line_1',
          icon:
          Icons.location_city_outlined,
          required:
          true,
        ),
        const SizedBox(
          height:
          14,
        ),
        _buildTextField(
          controller:
          _additionalAddressController,
          label:
          _isArabic
              ? 'عنوان إضافي'
              : 'Additional Address',
          hint:
          _isArabic
              ? 'تفاصيل إضافية'
              : 'Additional details',
          field:
          'address_line_2',
          icon:
          Icons.signpost_outlined,
        ),
        const SizedBox(
          height:
          14,
        ),
        _buildTextField(
          controller:
          _buildingController,
          label:
          _isArabic
              ? 'اسم المبنى'
              : 'Building Name',
          hint:
          _isArabic
              ? 'اسم المبنى'
              : 'Building name',
          field:
          'building_name',
          icon:
          Icons.apartment_rounded,
        ),
        const SizedBox(
          height:
          18,
        ),
        SizedBox(
          width:
          double.infinity,
          child:
          OutlinedButton.icon(
            onPressed:
            _isSubmitting
                ? null
                : _openMap,
            icon:
            const Icon(
              Icons.map_rounded,
            ),
            label:
            Text(
              _isArabic
                  ? 'تحديد الموقع على الخريطة'
                  : 'Select Location on Map',
            ),
            style:
            OutlinedButton.styleFrom(
              minimumSize:
              const Size.fromHeight(
                52,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  16,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height:
          12,
        ),
        Row(
          children: [
            Expanded(
              child:
              _buildCoordinateField(
                controller:
                _latitudeController,
                label:
                'Latitude',
                field:
                'latitude',
                icon:
                Icons.my_location_rounded,
              ),
            ),
            const SizedBox(
              width:
              12,
            ),
            Expanded(
              child:
              _buildCoordinateField(
                controller:
                _longitudeController,
                label:
                'Longitude',
                field:
                'longitude',
                icon:
                Icons.explore_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(
          height:
          8,
        ),
        Align(
          alignment:
          AlignmentDirectional
              .centerStart,
          child:
          Text(
            _isArabic
                ? 'الإحداثيات يتم تحديدها من الخريطة فقط.'
                : 'Coordinates are selected from the map.',
            style:
            theme.textTheme.bodySmall?.copyWith(
              color:
              theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNeighborhoodDropdown() {
    final theme =
    Theme.of(context);

    if (_loadingNeighborhoods) {
      return InputDecorator(
        key:
        _getFieldKey(
          'neighborhood_id',
        ),
        decoration:
        InputDecoration(
          labelText:
          _isArabic
              ? 'المنطقة'
              : 'Neighborhood / Area',
          prefixIcon:
          const Icon(
            Icons.map_outlined,
          ),
        ),
        child:
        const SizedBox(
          height:
          24,
          child:
          Center(
            child:
            CircularProgressIndicator(
              strokeWidth:
              2,
            ),
          ),
        ),
      );
    }

    if (_neighborhoods.isEmpty) {
      return Container(
        key:
        _getFieldKey(
          'neighborhood_id',
        ),
        padding:
        const EdgeInsets.all(
          14,
        ),
        decoration:
        BoxDecoration(
          border:
          Border.all(
            color:
            theme.colorScheme.outlineVariant,
          ),
          borderRadius:
          BorderRadius.circular(
            14,
          ),
        ),
        child:
        Row(
          children: [
            Icon(
              Icons.location_off_outlined,
              color:
              theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(
              width:
              10,
            ),
            Expanded(
              child:
              Text(
                _neighborhoodLoadError ??
                    (_isArabic
                        ? 'لا توجد مناطق متاحة.'
                        : 'No neighborhoods available.'),
              ),
            ),
            IconButton(
              onPressed:
              _loadNeighborhoods,
              icon:
              const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int>(
      initialValue:
      _selectedNeighborhoodId,
      isExpanded:
      true,
      menuMaxHeight:
      340,
      validator:
          (_) {
        if (_selectedNeighborhoodId ==
            null) {
          return _isArabic
              ? 'اختاري المنطقة'
              : 'Select a neighborhood';
        }

        return _serverError(
          'neighborhood_id',
        );
      },
      decoration:
      InputDecoration(
        labelText:
        _isArabic
            ? 'المنطقة'
            : 'Neighborhood / Area',
        prefixIcon:
        const Icon(
          Icons.map_outlined,
        ),
        helperText:
        _isArabic
            ? 'اختاري المنطقة من البيانات المتاحة'
            : 'Choose a location from the available data',
      ),
      items:
      _neighborhoods
          .map(
            (
            item,
            ) =>
            DropdownMenuItem<int>(
              value:
              item.id,
              child:
              Text(
                item.name,
                maxLines:
                1,
                overflow:
                TextOverflow.ellipsis,
              ),
            ),
      ).toList(),
      onChanged:
          (value) {
        setState(() {
          _selectedNeighborhoodId =
              value;
        });
      },
    );
  }

  Widget _buildCoordinateField({
    required TextEditingController controller,
    required String label,
    required String field,
    required IconData icon,
  }) {
    return KeyedSubtree(
      key:
      _getFieldKey(
        field,
      ),
      child:
      TextFormField(
        controller:
        controller,
        enabled:
        false,
        readOnly:
        true,
        validator:
            (_) {
          if (!_hasCoordinates) {
            return _isArabic
                ? 'اختاري الموقع من الخريطة'
                : 'Select the location from the map';
          }

          return _serverError(
            field,
          );
        },
        decoration:
        InputDecoration(
          labelText:
          label,
          prefixIcon:
          Icon(
            icon,
          ),
          suffixIcon:
          const Icon(
            Icons.lock_outline_rounded,
            size:
            18,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String field,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    int? minLength,
    TextInputType? keyboardType,
  }) {
    return KeyedSubtree(
      key:
      _getFieldKey(
        field,
      ),
      child:
      TextFormField(
        controller:
        controller,
        maxLines:
        maxLines,
        keyboardType:
        keyboardType,
        onChanged:
            (_) {
          _clearServerError(
            field,
          );
        },
        validator:
            (value) {
          final text =
              value?.trim() ??
                  '';

          if (required &&
              text.isEmpty) {
            return _isArabic
                ? 'هذا الحقل مطلوب'
                : 'This field is required';
          }

          if (minLength !=
              null &&
              text.isNotEmpty &&
              text.length <
                  minLength) {
            return _isArabic
                ? 'أدخلي تفاصيل أكثر'
                : 'Please enter more details';
          }

          return _serverError(
            field,
          );
        },
        decoration:
        InputDecoration(
          labelText:
          label,
          hintText:
          hint,
          prefixIcon:
          Icon(
            icon,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String field,
    bool decimal = false,
    bool required = false,
    ValueChanged<String>? onChanged,
  }) {
    return KeyedSubtree(
      key:
      _getFieldKey(
        field,
      ),
      child:
      TextFormField(
        controller:
        controller,
        keyboardType:
        TextInputType.numberWithOptions(
          decimal:
          decimal,
        ),
        inputFormatters:
        decimal
            ? <TextInputFormatter>[
          FilteringTextInputFormatter
              .allow(
            RegExp(
              r'^\d*\.?\d*',
            ),
          ),
        ]
            : <TextInputFormatter>[
          FilteringTextInputFormatter
              .digitsOnly,
        ],
        onChanged:
        onChanged ??
                (_) {
              _clearServerError(
                field,
              );
            },
        validator:
            (value) {
          final text =
              value?.trim() ??
                  '';

          if (required &&
              text.isEmpty) {
            return _isArabic
                ? 'هذا الحقل مطلوب'
                : 'This field is required';
          }

          if (text.isEmpty) {
            return _serverError(
              field,
            );
          }

          final number =
          decimal
              ? double.tryParse(
            text,
          )
              : int.tryParse(
            text,
          );

          if (number ==
              null) {
            return _isArabic
                ? 'أدخلي رقمًا صحيحًا'
                : 'Enter a valid number';
          }

          if (number <=
              0) {
            return _isArabic
                ? 'يجب أن تكون القيمة أكبر من صفر'
                : 'Value must be greater than zero';
          }

          return _serverError(
            field,
          );
        },
        decoration:
        InputDecoration(
          labelText:
          label,
          prefixIcon:
          Icon(
            icon,
          ),
        ),
      ),
    );
  }

  Widget _buildMediaStep(
      ThemeData theme,
      ) {
    return _buildSection(
      title:
      _isArabic
          ? 'صور العقار'
          : 'Property Photos',
      icon:
      Icons.photo_library_outlined,
      child:
      _buildPhotosSection(
        theme,
      ),
    );
  }

  Widget _buildPhotosSection(
      ThemeData theme,
      ) {
    final totalPhotos =
        (_coverImagePath !=
            null
            ? 1
            : 0) +
            _detailImages.length;

    return KeyedSubtree(
      key:
      _getFieldKey(
        'gallery_images',
      ),
      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isArabic
                          ? 'صورة الغلاف + 5 صور'
                          : '1 Cover + 5 Photos',
                      style:
                      theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height:
                      4,
                    ),
                    Text(
                      _isArabic
                          ? 'الصور الإضافية غير مرتبطة بنوع معين.'
                          : 'Additional photos are not tied to a specific type.',
                      style:
                      theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal:
                  10,
                  vertical:
                  5,
                ),
                decoration:
                BoxDecoration(
                  color:
                  theme.colorScheme.primary.withValues(
                    alpha:
                    0.07,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),
                child:
                Text(
                  '$totalPhotos / 6',
                  style:
                  theme.textTheme.labelMedium?.copyWith(
                    color:
                    theme.colorScheme.primary,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height:
            16,
          ),
          _buildCoverPhoto(
            theme,
          ),
          const SizedBox(
            height:
            18,
          ),
          Text(
            _isArabic
                ? 'الصور الإضافية'
                : 'Additional Photos',
            style:
            theme.textTheme.titleSmall?.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),
          const SizedBox(
            height:
            10,
          ),
          GridView.builder(
            shrinkWrap:
            true,
            physics:
            const NeverScrollableScrollPhysics(),
            itemCount:
            5,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
              2,
              crossAxisSpacing:
              10,
              mainAxisSpacing:
              10,
              childAspectRatio:
              1.3,
            ),
            itemBuilder:
                (
                context,
                index,
                ) {
              return _buildPhotoSlot(
                theme,
                index + 1,
              );
            },
          ),
          const SizedBox(
            height:
            10,
          ),
          Text(
            _isArabic
                ? 'أضيفي أي 5 صور مناسبة للعقار.'
                : 'Add any 5 photos suitable for the property.',
            style:
            theme.textTheme.bodySmall?.copyWith(
              color:
              theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverPhoto(
      ThemeData theme,
      ) {
    if (_coverImagePath ==
        null) {
      return InkWell(
        onTap:
        _pickCoverImage,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        child:
        Container(
          width:
          double.infinity,
          height:
          185,
          decoration:
          BoxDecoration(
            color:
            theme.colorScheme.surfaceContainerHighest
                .withValues(
              alpha:
              0.25,
            ),
            borderRadius:
            BorderRadius.circular(
              18,
            ),
            border:
            Border.all(
              color:
              theme.colorScheme.primary
                  .withValues(
                alpha:
                0.4,
              ),
              width:
              1.5,
            ),
          ),
          child:
          Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_rounded,
                size:
                42,
                color:
                theme.colorScheme.primary,
              ),
              const SizedBox(
                height:
                10,
              ),
              Text(
                _isArabic
                    ? 'إضافة صورة الغلاف'
                    : 'Upload Cover Photo',
                style:
                theme.textTheme.titleSmall?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              const SizedBox(
                height:
                4,
              ),
              Text(
                _isArabic
                    ? 'الصورة الرئيسية للعقار'
                    : 'Main property photo',
                style:
                theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius:
          BorderRadius.circular(
            18,
          ),
          child:
          Image.file(
            File(
              _coverImagePath!,
            ),
            width:
            double.infinity,
            height:
            210,
            fit:
            BoxFit.cover,
          ),
        ),
        Positioned(
          left:
          10,
          top:
          10,
          child:
          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal:
              9,
              vertical:
              5,
            ),
            decoration:
            BoxDecoration(
              color:
              theme.colorScheme.primary,
              borderRadius:
              BorderRadius.circular(
                9,
              ),
            ),
            child:
            Text(
              _isArabic
                  ? 'الغلاف'
                  : 'Cover',
              style:
              TextStyle(
                color:
                theme.colorScheme.onPrimary,
                fontSize:
                11,
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),
        ),
        Positioned(
          top:
          10,
          right:
          10,
          child:
          Material(
            color:
            Colors.black54,
            shape:
            const CircleBorder(),
            child:
            InkWell(
              customBorder:
              const CircleBorder(),
              onTap:
              _pickCoverImage,
              child:
              const Padding(
                padding:
                EdgeInsets.all(
                  9,
                ),
                child:
                Icon(
                  Icons.edit_rounded,
                  color:
                  Colors.white,
                  size:
                  18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSlot(
      ThemeData theme,
      int index,
      ) {
    final path =
    _detailImages[
    'photo_$index'];

    if (path == null) {
      return InkWell(
        onTap:
            () =>
            _pickDetailImage(
              index,
            ),
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        child:
        Container(
          padding:
          const EdgeInsets.all(
            12,
          ),
          decoration:
          BoxDecoration(
            color:
            theme.colorScheme.surfaceContainerHighest
                .withValues(
              alpha:
              0.22,
            ),
            borderRadius:
            BorderRadius.circular(
              16,
            ),
            border:
            Border.all(
              color:
              theme.colorScheme.outlineVariant,
            ),
          ),
          child:
          Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons
                    .add_photo_alternate_outlined,
                color:
                theme.colorScheme.primary,
                size:
                30,
              ),
              const SizedBox(
                height:
                8,
              ),
              Text(
                _isArabic
                    ? 'صورة $index'
                    : 'Photo $index',
                style:
                theme.textTheme.titleSmall?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              Text(
                _isArabic
                    ? 'إضافة'
                    : 'Add',
                style:
                theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          child:
          Image.file(
            File(path),
            width:
            double.infinity,
            height:
            double.infinity,
            fit:
            BoxFit.cover,
          ),
        ),
        Positioned(
          left:
          8,
          bottom:
          8,
          child:
          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal:
              8,
              vertical:
              4,
            ),
            decoration:
            BoxDecoration(
              color:
              Colors.black.withValues(
                alpha:
                0.65,
              ),
              borderRadius:
              BorderRadius.circular(
                8,
              ),
            ),
            child:
            Text(
              _isArabic
                  ? 'صورة $index'
                  : 'Photo $index',
              style:
              const TextStyle(
                color:
                Colors.white,
                fontSize:
                11,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ),
        Positioned(
          top:
          6,
          right:
          6,
          child:
          Material(
            color:
            Colors.black54,
            shape:
            const CircleBorder(),
            child:
            InkWell(
              customBorder:
              const CircleBorder(),
              onTap:
                  () =>
                  _removeDetailImage(
                    index,
                  ),
              child:
              const Padding(
                padding:
                EdgeInsets.all(
                  6,
                ),
                child:
                Icon(
                  Icons.close_rounded,
                  color:
                  Colors.white,
                  size:
                  16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickCoverImage() async {
    final image =
    await _imagePicker.pickImage(
      source:
      ImageSource.gallery,
      imageQuality:
      88,
      maxWidth:
      1800,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _coverImagePath =
          image.path;
    });
  }

  Future<void> _pickDetailImage(
      int index,
      ) async {
    final image =
    await _imagePicker.pickImage(
      source:
      ImageSource.gallery,
      imageQuality:
      88,
      maxWidth:
      1800,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _detailImages[
      'photo_$index'] =
          image.path;
    });
  }

  void _removeDetailImage(
      int index,
      ) {
    setState(() {
      _detailImages.remove(
        'photo_$index',
      );
    });
  }

  Widget _buildPublishStep(
      ThemeData theme,
      ) {
    return Column(
      children: [
        _buildSection(
          title:
          _isArabic
              ? 'معلومات التواصل'
              : 'Contact Information',
          icon:
          Icons.contact_phone_outlined,
          child:
          _buildContactSection(
            theme,
          ),
        ),
        const SizedBox(
          height:
          16,
        ),
        _buildSection(
          title:
          _isArabic
              ? 'مراجعة العقار'
              : 'Property Review',
          icon:
          Icons.fact_check_outlined,
          child:
          _buildPropertySummary(
            theme,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(
      ThemeData theme,
      ) {
    return Column(
      children: [
        Text(
          _isArabic
              ? 'أضيفي رقم الجوال أو WhatsApp للتواصل مع المهتمين بالعقار.'
              : 'Add a phone number or WhatsApp for property inquiries.',
          style:
          theme.textTheme.bodyMedium,
        ),
        const SizedBox(
          height:
          14,
        ),
        _buildTextField(
          controller:
          _phoneController,
          label:
          _isArabic
              ? 'رقم الجوال'
              : 'Phone Number',
          hint:
          '+971 50 123 4567',
          field:
          'phone',
          icon:
          Icons.phone_rounded,
          keyboardType:
          TextInputType.phone,
        ),
        const SizedBox(
          height:
          12,
        ),
        _buildTextField(
          controller:
          _whatsappController,
          label:
          _isArabic
              ? 'رقم WhatsApp'
              : 'WhatsApp Number',
          hint:
          '+971 50 123 4567',
          field:
          'whatsapp',
          icon:
          Icons.phone_in_talk_rounded,
          keyboardType:
          TextInputType.phone,
        ),
        const SizedBox(
          height:
          18,
        ),
        Align(
          alignment:
          AlignmentDirectional
              .centerStart,
          child:
          Text(
            _isArabic
                ? 'طرق التواصل'
                : 'Contact Methods',
            style:
            theme.textTheme.titleSmall?.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(
          height:
          10,
        ),
        _buildContactMethod(
          theme,
          method:
          'phone',
          title:
          _isArabic
              ? 'اتصال هاتفي'
              : 'Phone Call',
          icon:
          Icons.phone_rounded,
        ),
        const SizedBox(
          height:
          10,
        ),
        _buildContactMethod(
          theme,
          method:
          'whatsapp',
          title:
          'WhatsApp',
          icon:
          Icons.phone_in_talk_rounded,
        ),
        const SizedBox(
          height:
          10,
        ),
        Container(
          padding:
          const EdgeInsets.all(
            14,
          ),
          decoration:
          BoxDecoration(
            color:
            theme.colorScheme.surfaceContainerHighest
                .withValues(
              alpha:
              0.4,
            ),
            borderRadius:
            BorderRadius.circular(
              16,
            ),
            border:
            Border.all(
              color:
              theme.colorScheme.outlineVariant,
            ),
          ),
          child:
          Row(
            children: [
              Icon(
                Icons
                    .chat_bubble_outline_rounded,
                color:
                theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(
                width:
                10,
              ),
              Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isArabic
                          ? 'محادثة داخل التطبيق'
                          : 'In-app Chat',
                      style:
                      theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    Text(
                      _isArabic
                          ? 'قريبًا'
                          : 'Coming Soon',
                      style:
                      theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactMethod(
      ThemeData theme, {
        required String method,
        required String title,
        required IconData icon,
      }) {
    final selected =
    _selectedContactMethods
        .contains(
      method,
    );

    return InkWell(
      onTap:
          () {
        setState(() {
          if (selected) {
            _selectedContactMethods
                .remove(
              method,
            );
          } else {
            _selectedContactMethods
                .add(
              method,
            );
          }
        });
      },
      borderRadius:
      BorderRadius.circular(
        16,
      ),
      child:
      AnimatedContainer(
        duration:
        const Duration(
          milliseconds:
          180,
        ),
        padding:
        const EdgeInsets.all(
          14,
        ),
        decoration:
        BoxDecoration(
          color:
          selected
              ? theme.colorScheme.primary
              .withValues(
            alpha:
            0.07,
          )
              : theme.colorScheme.surface,
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          border:
          Border.all(
            color:
            selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width:
            selected
                ? 1.8
                : 1,
          ),
        ),
        child:
        Row(
          children: [
            Icon(
              icon,
              color:
              selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(
              width:
              10,
            ),
            Expanded(
              child:
              Text(
                title,
                style:
                theme.textTheme.bodyMedium?.copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color:
              selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertySummary(
      ThemeData theme,
      ) {
    final propertyType =
    _propertyTypes[_typeId]?[
    _isArabic
        ? 'ar'
        : 'en'];

    final price =
    _aedPrice != null
        ? 'AED ${_formatNumber(_aedPrice!)}'
        : _priceController.text.trim();

    return Column(
      children: [
        _summaryRow(
          theme,
          _isArabic
              ? 'العنوان'
              : 'Title',
          _titleController.text
              .trim()
              .isEmpty
              ? '-'
              : _titleController.text
              .trim(),
        ),
        _summaryRow(
          theme,
          _isArabic
              ? 'نوع العرض'
              : 'Listing Type',
          _listingType ==
              'sale'
              ? (_isArabic
              ? 'للبيع'
              : 'For Sale')
              : (_isArabic
              ? 'للإيجار'
              : 'For Rent'),
        ),
        _summaryRow(
          theme,
          _isArabic
              ? 'نوع العقار'
              : 'Property Type',
          propertyType ??
              '-',
        ),
        _summaryRow(
          theme,
          _isArabic
              ? 'السعر'
              : 'Price',
          price.isEmpty
              ? '-'
              : price,
        ),
        _summaryRow(
          theme,
          _isArabic
              ? 'المساحة'
              : 'Area',
          _areaController.text
              .trim()
              .isEmpty
              ? '-'
              : '${_areaController.text.trim()} sqft',
        ),
        _summaryRow(
          theme,
          _isArabic
              ? 'غرف النوم'
              : 'Bedrooms',
          _bedroomsController
              .text
              .trim()
              .isEmpty
              ? '-'
              : _bedroomsController
              .text
              .trim(),
        ),
        _summaryRow(
          theme,
          _isArabic
              ? 'الحمامات'
              : 'Bathrooms',
          _bathroomsController
              .text
              .trim()
              .isEmpty
              ? '-'
              : _bathroomsController
              .text
              .trim(),
        ),
        _summaryRow(
          theme,
          _isArabic
              ? 'الصور'
              : 'Photos',
          '${(_coverImagePath != null ? 1 : 0) + _detailImages.length}',
        ),
        _summaryRow(
          theme,
          _isArabic
              ? 'التواصل'
              : 'Contact',
          _hasContact
              ? _selectedContactMethods
              .map(
                (method) =>
            method ==
                'phone'
                ? 'Phone'
                : 'WhatsApp',
          )
              .join(
            ' + ',
          )
              : '-',
        ),
      ],
    );
  }

  Widget _summaryRow(
      ThemeData theme,
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom:
        12,
      ),
      child:
      Row(
        children: [
          Expanded(
            child:
            Text(
              title,
              style:
              theme.textTheme.bodyMedium?.copyWith(
                color:
                theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(
            width:
            12,
          ),
          Flexible(
            child:
            Text(
              value,
              maxLines:
              2,
              overflow:
              TextOverflow.ellipsis,
              textAlign:
              TextAlign.end,
              style:
              theme.textTheme.bodyMedium?.copyWith(
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme =
    Theme.of(context);

    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        16,
      ),
      decoration:
      BoxDecoration(
        color:
        theme.colorScheme.surface,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        border:
        Border.all(
          color:
          theme.colorScheme.outlineVariant,
        ),
      ),
      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width:
                40,
                height:
                40,
                decoration:
                BoxDecoration(
                  color:
                  theme.colorScheme.primary.withValues(
                    alpha:
                    0.09,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child:
                Icon(
                  icon,
                  color:
                  theme.colorScheme.primary,
                  size:
                  20,
                ),
              ),
              const SizedBox(
                width:
                10,
              ),
              Expanded(
                child:
                Text(
                  title,
                  maxLines:
                  1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  theme.textTheme.titleMedium?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height:
            16,
          ),
          child,
        ],
      ),
    );
  }

  GlobalKey _getFieldKey(
      String field,
      ) {
    final existing =
    _fieldKeys[field];

    if (existing !=
        null) {
      return existing;
    }

    final key =
    GlobalKey();

    _fieldKeys[field] =
        key;

    return key;
  }

  String? _serverError(
      String field,
      ) {
    return _serverErrors[field];
  }

  void _clearServerError(
      String field,
      ) {
    if (!_serverErrors.containsKey(
      field,
    )) {
      return;
    }

    setState(() {
      _serverErrors.remove(
        field,
      );
    });
  }

  Future<void> _loadNeighborhoods() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loadingNeighborhoods = true;
      _neighborhoodLoadError = null;
    });

    try {
      final token = await TokenStorage.getAccessToken();

      final response = await http.get(
        Uri.parse(
          '${ApiEndpoints.baseUrl}${ApiEndpoints.properties}',
        ),
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(
          seconds: 30,
        ),
      );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Unable to load locations',
        );
      }

      final decoded = jsonDecode(
        response.body,
      );

      final properties = _extractProperties(
        decoded,
      );

      final unique = <int, String>{};

      for (final property in properties) {
        if (property is! Map) {
          continue;
        }

        final directId = _readInt(
          property['neighborhood_id'],
        );

        final location = property['location'];

        final nestedId = location is Map
            ? _readInt(
          location['neighborhood_id'],
        )
            : null;

        final id = directId ?? nestedId;

        if (id == null) {
          continue;
        }

        final name = _readNeighborhoodName(
          property,
        );

        if (name.isNotEmpty) {
          unique.putIfAbsent(
            id,
                () => name,
          );
        }
      }

      final list = unique.entries
          .map(
            (entry) => _NeighborhoodOption(
          id: entry.key,
          name: entry.value,
        ),
      )
          .toList();

      list.sort(
            (a, b) => a.name
            .toLowerCase()
            .compareTo(
          b.name.toLowerCase(),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _neighborhoods = list;
        _neighborhoodLoadError = null;
        _loadingNeighborhoods = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _neighborhoodLoadError = error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        );
        _neighborhoods = [];
        _loadingNeighborhoods = false;
      });
    } finally {
      if (mounted && _loadingNeighborhoods) {
        setState(() {
          _loadingNeighborhoods = false;
        });
      }
    }
  }

  List<dynamic> _extractProperties(
      dynamic decoded,
      ) {
    if (decoded is List) {
      return decoded;
    }

    if (decoded is! Map) {
      return const [];
    }

    final data =
    decoded['data'];

    if (data is List) {
      return data;
    }

    if (data is Map) {
      final properties =
      data['properties'];

      if (properties is List) {
        return properties;
      }

      final nestedData =
      data['data'];

      if (nestedData is List) {
        return nestedData;
      }
    }

    final properties =
    decoded['properties'];

    if (properties is List) {
      return properties;
    }

    return const [];
  }

  String _readNeighborhoodName(
      Map property,
      ) {
    final neighborhood =
    property['neighborhood'];

    if (neighborhood is Map) {
      final name =
      neighborhood['name'];

      if (name !=
          null &&
          name
              .toString()
              .trim()
              .isNotEmpty) {
        return name
            .toString()
            .trim();
      }
    }

    final location =
    property['location'];

    if (location is Map) {
      final nested =
      location['neighborhood'];

      if (nested is Map) {
        final name =
        nested['name'];

        if (name !=
            null &&
            name
                .toString()
                .trim()
                .isNotEmpty) {
          return name
              .toString()
              .trim();
        }
      }

      final name =
      location['name'];

      if (name !=
          null &&
          name
              .toString()
              .trim()
              .isNotEmpty) {
        return name
            .toString()
            .trim();
      }

      final address =
      location[
      'address_line_1'];

      if (address !=
          null &&
          address
              .toString()
              .trim()
              .isNotEmpty) {
        return address
            .toString()
            .trim();
      }
    }

    final address =
    property[
    'address_line_1'];

    if (address !=
        null &&
        address
            .toString()
            .trim()
            .isNotEmpty) {
      return address
          .toString()
          .trim();
    }

    return '';
  }

  int? _readInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(
        value,
      );
    }

    return null;
  }

  Future<void> _openMap()
  async {
    final latitude =
    double.tryParse(
      _latitudeController.text.trim(),
    );

    final longitude =
    double.tryParse(
      _longitudeController.text.trim(),
    );

    final result =
    await Navigator.of(context)
        .push<LatLng>(
      MaterialPageRoute(
        builder:
            (_) =>
            LocationPickerPage(
              initialLatitude:
              latitude,
              initialLongitude:
              longitude,
            ),
      ),
    );

    if (result ==
        null ||
        !mounted) {
      return;
    }

    setState(() {
      _latitudeController.text =
          result.latitude
              .toStringAsFixed(
            6,
          );

      _longitudeController.text =
          result.longitude
              .toStringAsFixed(
            6,
          );

      _serverErrors.remove(
        'latitude',
      );

      _serverErrors.remove(
        'longitude',
      );
    });

    _formKey.currentState
        ?.validate();
  }

  bool _validateBasicStep() {
    return _formKey.currentState
        ?.validate() ??
        false;
  }

  bool _validateSpecsStep() {
    final price =
    double.tryParse(
      _priceController.text.trim(),
    );

    final area =
    double.tryParse(
      _areaController.text.trim(),
    );

    final bedrooms =
    int.tryParse(
      _bedroomsController.text.trim(),
    );

    final bathrooms =
    int.tryParse(
      _bathroomsController.text.trim(),
    );

    if (price == null ||
        price <=
            0) {
      _showError(
        _isArabic
            ? 'أدخلي سعرًا صحيحًا.'
            : 'Enter a valid price.',
      );

      _scrollToField(
        'price',
      );

      return false;
    }

    if (area == null ||
        area <=
            0) {
      _showError(
        _isArabic
            ? 'أدخلي مساحة صحيحة.'
            : 'Enter a valid area.',
      );

      _scrollToField(
        'area_sqft',
      );

      return false;
    }

    if (bedrooms == null ||
        bedrooms <
            0) {
      _showError(
        _isArabic
            ? 'أدخلي عدد غرف صحيح.'
            : 'Enter a valid bedrooms value.',
      );

      _scrollToField(
        'bedrooms',
      );

      return false;
    }

    if (bathrooms == null ||
        bathrooms <
            0) {
      _showError(
        _isArabic
            ? 'أدخلي عدد حمامات صحيح.'
            : 'Enter a valid bathrooms value.',
      );

      _scrollToField(
        'bathrooms',
      );

      return false;
    }

    if (_selectedNeighborhoodId ==
        null) {
      _showError(
        _isArabic
            ? 'اختاري المنطقة.'
            : 'Select a neighborhood.',
      );

      _scrollToField(
        'neighborhood_id',
      );

      return false;
    }

    if (_addressController.text
        .trim()
        .isEmpty) {
      _showError(
        _isArabic
            ? 'أدخلي العنوان.'
            : 'Enter the address.',
      );

      _scrollToField(
        'address_line_1',
      );

      return false;
    }

    if (!_hasCoordinates) {
      _showError(
        _isArabic
            ? 'حددي الموقع من الخريطة.'
            : 'Select the location from the map.',
      );

      _scrollToField(
        'latitude',
      );

      return false;
    }

    return true;
  }

  bool _validateMediaStep() {
    if (_coverImagePath ==
        null) {
      _showError(
        _isArabic
            ? 'أضيفي صورة الغلاف.'
            : 'Add the cover photo.',
      );

      _scrollToField(
        'gallery_images',
      );

      return false;
    }

    if (_detailImages.length <
        5) {
      _showError(
        _isArabic
            ? 'أضيفي 5 صور إضافية.'
            : 'Add 5 additional photos.',
      );

      _scrollToField(
        'gallery_images',
      );

      return false;
    }

    return true;
  }

  bool _validatePublishStep() {
    if (!_hasContact) {
      _showError(
        _isArabic
            ? 'أضيفي رقم الجوال أو WhatsApp.'
            : 'Add a phone number or WhatsApp.',
      );

      _scrollToField(
        'phone',
      );

      return false;
    }

    if (_phoneController.text
        .trim()
        .isNotEmpty &&
        _digitsOnly(
          _phoneController.text,
        ).length <
            7) {
      _showError(
        _isArabic
            ? 'رقم الجوال غير صحيح.'
            : 'Phone number is invalid.',
      );

      _scrollToField(
        'phone',
      );

      return false;
    }

    if (_whatsappController.text
        .trim()
        .isNotEmpty &&
        _digitsOnly(
          _whatsappController.text,
        ).length <
            7) {
      _showError(
        _isArabic
            ? 'رقم WhatsApp غير صحيح.'
            : 'WhatsApp number is invalid.',
      );

      _scrollToField(
        'whatsapp',
      );

      return false;
    }

    return true;
  }

  String _digitsOnly(
      String value,
      ) {
    return value.replaceAll(
      RegExp(
        r'[^0-9]',
      ),
      '',
    );
  }

  void _nextStep() {
    bool valid;

    switch (_currentStep) {
      case 0:
        valid =
            _validateBasicStep();
        break;

      case 1:
        valid =
            _validateSpecsStep();
        break;

      case 2:
        valid =
            _validateMediaStep();
        break;

      default:
        valid =
            _validatePublishStep();
    }

    if (!valid) {
      return;
    }

    if (_currentStep <
        3) {
      setState(() {
        _currentStep++;
      });

      _scrollToTop();

      return;
    }

    _submit();
  }

  void _previousStep() {
    if (_currentStep ==
        0) {
      return;
    }

    setState(() {
      _currentStep--;
    });

    _scrollToTop();
  }

  void _scrollToTop() {
    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {
        if (!mounted) {
          return;
        }

        _scrollController.animateTo(
          0,
          duration:
          const Duration(
            milliseconds:
            300,
          ),
          curve:
          Curves.easeOutCubic,
        );
      },
    );
  }

  void _scrollToField(
      String field,
      ) {
    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {
        if (!mounted) {
          return;
        }

        final key =
        _fieldKeys[field];

        if (key == null ||
            key.currentContext ==
                null) {
          return;
        }

        Scrollable.ensureVisible(
          key.currentContext!,
          duration:
          const Duration(
            milliseconds:
            400,
          ),
          curve:
          Curves.easeOutCubic,
          alignment:
          0.15,
        );
      },
    );
  }

  void _showError(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
        Text(
          message,
        ),
        behavior:
        SnackBarBehavior.floating,
        backgroundColor:
        Theme.of(context)
            .colorScheme
            .error,
        margin:
        const EdgeInsets.all(
          16,
        ),
      ),
    );
  }

  Future<void> _submit()
  async {
    if (!_validatePublishStep()) {
      return;
    }

    final price =
    double.tryParse(
      _priceController.text
          .trim(),
    );

    final area =
    double.tryParse(
      _areaController.text
          .trim(),
    );

    final bedrooms =
    int.tryParse(
      _bedroomsController.text
          .trim(),
    );

    final bathrooms =
    int.tryParse(
      _bathroomsController.text
          .trim(),
    );

    final latitude =
    double.tryParse(
      _latitudeController.text
          .trim(),
    );

    final longitude =
    double.tryParse(
      _longitudeController.text
          .trim(),
    );

    if (price == null ||
        area == null ||
        bedrooms == null ||
        bathrooms == null ||
        latitude == null ||
        longitude == null ||
        _selectedNeighborhoodId ==
            null ||
        _coverImagePath ==
            null ||
        _detailImages.length <
            5) {
      _showError(
        _isArabic
            ? 'تحققي من بيانات العقار.'
            : 'Please check the property data.',
      );

      return;
    }

    if (_selectedCurrency !=
        'AED' &&
        _aedPrice == null) {
      await _updateAedPrice();

      if (!mounted ||
          _aedPrice == null) {
        _showError(
          _isArabic
              ? 'تعذر تحويل السعر إلى الدرهم.'
              : 'Unable to convert price to AED.',
        );

        return;
      }
    }

    setState(() {
      _isSubmitting =
      true;
    });

    try {
      final token =
      await TokenStorage
          .getAccessToken();

      if (token ==
          null ||
          token.isEmpty) {
        throw Exception(
          _isArabic
              ? 'يجب تسجيل الدخول أولًا.'
              : 'Please login first.',
        );
      }

      final request =
      http.MultipartRequest(
        'POST',
        Uri.parse(
          '${ApiEndpoints.baseUrl}${ApiEndpoints.properties}',
        ),
      );

      request.headers[
      'Accept'] =
      'application/json';

      request.headers[
      'Authorization'] =
      'Bearer $token';

      request.fields[
      'title'] =
          _titleController.text
              .trim();

      request.fields[
      'type_id'] =
          _typeId.toString();

      request.fields[
      'listing_type'] =
          _listingType;

      request.fields[
      'price'] =
          (_aedPrice ??
              price)
              .toString();

      request.fields[
      'description'] =
          _descriptionController
              .text
              .trim();

      request.fields[
      'neighborhood_id'] =
          _selectedNeighborhoodId
              .toString();

      request.fields[
      'address_line_1'] =
          _addressController
              .text
              .trim();

      if (_additionalAddressController
          .text
          .trim()
          .isNotEmpty) {
        request.fields[
        'address_line_2'] =
            _additionalAddressController
                .text
                .trim();
      }

      if (_buildingController
          .text
          .trim()
          .isNotEmpty) {
        request.fields[
        'building_name'] =
            _buildingController
                .text
                .trim();
      }

      request.fields[
      'latitude'] =
          latitude.toString();

      request.fields[
      'longitude'] =
          longitude.toString();

      request.fields[
      'area_sqft'] =
          area.toString();

      request.fields[
      'bedrooms'] =
          bedrooms.toString();

      request.fields[
      'bathrooms'] =
          bathrooms.toString();

      request.fields[
      'property_condition'] =
          _propertyCondition;

      if (_phoneController
          .text
          .trim()
          .isNotEmpty) {
        request.fields[
        'phone'] =
            _phoneController
                .text
                .trim();
      }

      if (_whatsappController
          .text
          .trim()
          .isNotEmpty) {
        request.fields[
        'whatsapp'] =
            _whatsappController
                .text
                .trim();
      }

      for (final feature
      in _features) {
        if (!_selectedFeatures
            .contains(
          feature.key,
        )) {
          continue;
        }

        if (feature.id ==
            null) {
          continue;
        }

        request.fields[
        'features[]'] =
            feature.id
                .toString();
      }

      request.files.add(
        await http.MultipartFile
            .fromPath(
          'cover_image',
          _coverImagePath!,
        ),
      );

      for (var i = 1;
      i <= 5;
      i++) {
        final path =
        _detailImages[
        'photo_$i'];

        if (path ==
            null ||
            path.isEmpty) {
          continue;
        }

        request.files.add(
          await http.MultipartFile
              .fromPath(
            'gallery_images[]',
            path,
          ),
        );
      }

      final streamed =
      await request.send();

      final response =
      await http.Response
          .fromStream(
        streamed,
      );

      final data =
      _decodeResponse(
        response.body,
      );

      if (response.statusCode >=
          200 &&
          response.statusCode <
              300) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isSubmitting =
          false;
        });

        await _showSuccessDialog();

        if (!mounted) {
          return;
        }

        Navigator.of(
          context,
        ).pop(true);

        return;
      }

      if (response.statusCode ==
          422) {
        _applyServerErrors(
          data['errors'],
        );

        if (mounted) {
          setState(() {
            _isSubmitting =
            false;
          });
        }

        _showError(
          _isArabic
              ? 'تحققي من الحقول المحددة.'
              : 'Please check the highlighted fields.',
        );

        return;
      }

      if (response.statusCode ==
          401) {
        throw Exception(
          _isArabic
              ? 'انتهت جلسة تسجيل الدخول.'
              : 'Your login session has expired.',
        );
      }

      throw Exception(
        data['message']
            ?.toString() ??
            data['error']
                ?.toString() ??
            (_isArabic
                ? 'حدث خطأ أثناء إضافة العقار.'
                : 'Failed to add property.'),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting =
        false;
      });

      _showError(
        error
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  Map<String, dynamic> _decodeResponse(
      String body,
      ) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded =
      jsonDecode(
        body,
      );

      if (decoded
      is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded,
        );
      }
    } catch (_) {}

    return <String, dynamic>{};
  }

  void _applyServerErrors(
      dynamic errors,
      ) {
    _serverErrors.clear();

    if (errors is Map) {
      errors.forEach(
            (
            key,
            value,
            ) {
          if (value is List &&
              value.isNotEmpty) {
            _serverErrors[
            key.toString()] =
                value.first
                    .toString();
          } else {
            _serverErrors[
            key.toString()] =
                value.toString();
          }
        },
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {});

    _scrollToFirstServerError();
  }

  void _scrollToFirstServerError() {
    const fields =
    <String>[
      'title',
      'type_id',
      'listing_type',
      'price',
      'description',
      'neighborhood_id',
      'address_line_1',
      'address_line_2',
      'building_name',
      'latitude',
      'longitude',
      'area_sqft',
      'bedrooms',
      'bathrooms',
      'property_condition',
      'phone',
      'whatsapp',
      'cover_image',
      'gallery_images',
    ];

    for (final field
    in fields) {
      if (_serverErrors
          .containsKey(
        field,
      )) {
        _scrollToField(
          field,
        );

        return;
      }
    }
  }

  Future<void>
  _showSuccessDialog() async {
    final theme =
    Theme.of(context);

    await showDialog<void>(
      context:
      context,
      barrierDismissible:
      false,
      builder:
          (dialogContext) {
        return AlertDialog(
          icon:
          Icon(
            Icons
                .check_circle_rounded,
            color:
            theme
                .colorScheme
                .primary,
            size:
            55,
          ),
          title:
          Text(
            _isArabic
                ? 'تمت إضافة العقار'
                : 'Property Added',
            textAlign:
            TextAlign.center,
          ),
          content:
          Text(
            _isArabic
                ? 'تم حفظ بيانات العقار بنجاح.'
                : 'The property was added successfully.',
            textAlign:
            TextAlign.center,
          ),
          actions: [
            SizedBox(
              width:
              double.infinity,
              child:
              FilledButton(
                onPressed:
                    () {
                  Navigator.of(
                    dialogContext,
                  ).pop();
                },
                child:
                Text(
                  _isArabic
                      ? 'تم'
                      : 'Done',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar(
      ThemeData theme,
      ) {
    final isLast =
        _currentStep ==
            3;

    return SafeArea(
      top:
      false,
      child:
      Container(
        padding:
        const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          10,
        ),
        decoration:
        BoxDecoration(
          color:
          theme.colorScheme.surface,
          border:
          Border(
            top:
            BorderSide(
              color:
              theme.colorScheme.outlineVariant,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withValues(
                alpha:
                theme.brightness ==
                    Brightness.dark
                    ? 0.22
                    : 0.06,
              ),
              blurRadius:
              18,
              offset:
              const Offset(
                0,
                -4,
              ),
            ),
          ],
        ),
        child:
        Row(
          children: [
            if (_currentStep >
                0)
              Expanded(
                child:
                OutlinedButton.icon(
                  onPressed:
                  _isSubmitting
                      ? null
                      : _previousStep,
                  icon:
                  const Icon(
                    Icons
                        .arrow_back_rounded,
                  ),
                  label:
                  Text(
                    _isArabic
                        ? 'السابق'
                        : 'Back',
                  ),
                  style:
                  OutlinedButton.styleFrom(
                    minimumSize:
                    const Size.fromHeight(
                      54,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentStep >
                0)
              const SizedBox(
                width:
                12,
              ),
            Expanded(
              flex:
              2,
              child:
              FilledButton.icon(
                onPressed:
                _isSubmitting
                    ? null
                    : _nextStep,
                icon:
                _isSubmitting
                    ? const SizedBox(
                  width:
                  20,
                  height:
                  20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                  ),
                )
                    : Icon(
                  isLast
                      ? Icons
                      .publish_rounded
                      : Icons
                      .arrow_forward_rounded,
                ),
                label:
                Text(
                  isLast
                      ? (_isArabic
                      ? 'نشر العقار'
                      : 'Publish Property')
                      : (_isArabic
                      ? 'التالي'
                      : 'Continue'),
                ),
                style:
                FilledButton.styleFrom(
                  minimumSize:
                  const Size
                      .fromHeight(
                    54,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(
      double value,
      ) {
    final fixed =
    value.toStringAsFixed(
      2,
    );

    final parts =
    fixed.split('.');

    final integer =
    parts[0];

    final decimal =
    parts[1];

    final buffer =
    StringBuffer();

    for (
    var i = 0;
    i < integer.length;
    i++
    ) {
      if (i > 0 &&
          (integer.length -
              i) %
              3 ==
              0) {
        buffer.write(',');
      }

      buffer.write(
        integer[i],
      );
    }

    return '${buffer.toString()}.$decimal';
  }
}

class _NeighborhoodOption {
  const _NeighborhoodOption({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}

class _FeatureOption {
  const _FeatureOption({
    required this.key,
    required this.id,
    required this.en,
    required this.ar,
    required this.icon,
  });

  final String key;
  final int? id;
  final String en;
  final String ar;
  final IconData icon;
}

class _CurrencyOption {
  const _CurrencyOption({
    required this.code,
    required this.en,
    required this.ar,
  });

  final String code;
  final String en;
  final String ar;
}