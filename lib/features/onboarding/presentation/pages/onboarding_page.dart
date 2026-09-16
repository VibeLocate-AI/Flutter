import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/localization/localization.dart';
import '../../../../core/storage/onboarding_storage.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/onboarding_content.dart';
import '../widgets/onboarding_image.dart';
import '../widgets/onboarding_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  void _nextPage(int pageCount) {
    if (_currentPage < pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      return;
    }

    _getStarted();
  }

  void _previousPage() {
    if (_currentPage == 0) {
      return;
    }

    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _skip() {
    _getStarted();
  }

  Future<void> _getStarted() async {
    await OnboardingStorage.markAsSeen();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      AppRouter.login,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    final pages = [
      _OnboardingData(
        image: 'assets/images/onboarding/onboarding_1.png',
        title: localization.translate(
          'onboarding_title_1',
        ),
        description: localization.translate(
          'onboarding_description_1',
        ),
      ),
      _OnboardingData(
        image: 'assets/images/onboarding/onboarding_2.png',
        title: localization.translate(
          'onboarding_title_2',
        ),
        description: localization.translate(
          'onboarding_description_2',
        ),
      ),
      _OnboardingData(
        image: 'assets/images/onboarding/onboarding_3.png',
        title: localization.translate(
          'onboarding_title_3',
        ),
        description: localization.translate(
          'onboarding_description_3',
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: pages.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return _OnboardingView(
              data: pages[index],
              currentPage: _currentPage,
              pageCount: pages.length,
              isFirstPage: index == 0,
              isLastPage: index == pages.length - 1,
              onNext: () => _nextPage(pages.length),
              onPrevious: _previousPage,
              onSkip: _skip,
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView({
    required this.data,
    required this.currentPage,
    required this.pageCount,
    required this.isFirstPage,
    required this.isLastPage,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
  });

  final _OnboardingData data;
  final int currentPage;
  final int pageCount;
  final bool isFirstPage;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    final screenSize = MediaQuery.sizeOf(context);
    final width = screenSize.width;
    final horizontalPadding = width < 360 ? 20.0 : 24.0;

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: OnboardingImage(
            imagePath: data.image,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          ),
          child: OnboardingContent(
            title: data.title,
            description: data.description,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          ),
          child: OnboardingButton(
            label: isLastPage
                ? localization.translate('get_started')
                : localization.translate('next'),
            onPressed: onNext,
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            20,
          ),
          child: Row(
            children: [
              if (!isFirstPage)
                IconButton(
                  onPressed: onPrevious,
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 18,
                  ),
                  tooltip: localization.translate('back'),
                )
              else
                const SizedBox(
                  width: 48,
                  height: 48,
                ),
              const Spacer(),
              OnboardingIndicator(
                currentPage: currentPage,
                itemCount: pageCount,
              ),
              const Spacer(),
              if (!isLastPage)
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    localization.translate('skip'),
                  ),
                )
              else
                const SizedBox(
                  width: 64,
                  height: 48,
                ),
            ],
          ),
        ),
      ],
    );
  }
}