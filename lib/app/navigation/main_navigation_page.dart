import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../../core/controllers/favorites_controller.dart';
import '../../core/controllers/my_properties_controller.dart';
import '../../core/controllers/home_controller.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/properties/presentation/pages/properties_page.dart';
import 'app_bottom_navigation.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Get.find<HomeController>().initialize();
    Get.find<FavoritesController>().initialize();
    Get.find<MyPropertiesController>().initialize();
  }

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    // Do not refetch when switching tabs. The tab widgets/controllers stay
    // alive in IndexedStack; pull-to-refresh is the explicit refresh action.
    if (index == 0) {
      // Home location state is managed independently.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomePage(),
          const MapPage(),
          const PropertiesPage(),
          const FavoritesPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onItemSelected: _selectTab,
      ),
    );
  }
}
