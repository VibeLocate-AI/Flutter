import 'package:flutter/material.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/properties/presentation/pages/add_property_page.dart';
import 'app_bottom_navigation.dart';

class MainNavigationPage
    extends StatefulWidget {
  const MainNavigationPage({
    super.key,
  });

  @override
  State<MainNavigationPage>
  createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState
    extends State<MainNavigationPage> {
  int _currentIndex = 0;

  void _selectTab(
      int index,
      ) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _openAddProperty()
  async {
    final result =
    await Navigator.of(
      context,
    ).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
        const AddPropertyPage(),
      ),
    );

    if (!mounted ||
        result != true) {
      return;
    }

    final isArabic =
        Localizations.localeOf(
          context,
        ).languageCode ==
            'ar';

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? 'تمت إضافة العقار بنجاح'
              : 'Property added successfully',
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      body: IndexedStack(
        index: _pageIndex,
        children: const [
          HomePage(),
          MapPage(),
          SizedBox.shrink(),
          _FavoritesPlaceholder(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar:
      AppBottomNavigation(
        currentIndex:
        _currentIndex,
        onItemSelected:
        _selectTab,
        onAddProperty:
        _openAddProperty,
      ),
    );
  }

  int get _pageIndex {
    switch (_currentIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 3:
        return 3;
      case 4:
        return 4;
      default:
        return 0;
    }
  }
}

class _FavoritesPlaceholder
    extends StatelessWidget {
  const _FavoritesPlaceholder();

  @override
  Widget build(
      BuildContext context,
      ) {
    final isArabic =
        Localizations.localeOf(
          context,
        ).languageCode ==
            'ar';

    return Scaffold(
      body: Center(
        child: Text(
          isArabic
              ? 'المفضلة'
              : 'Favorites',
        ),
      ),
    );
  }
}