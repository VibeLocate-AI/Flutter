import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../core/storage/token_storage.dart';
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
  bool _isAgent = false;

  @override
  void initState() {
    super.initState();
    Get.find<HomeController>().load(force: true);
    Get.find<FavoritesController>().reload(showLoader: false);
    Get.find<MyPropertiesController>().initialize();
    _loadAccountRole();
  }

  Future<void> _loadAccountRole() async {
    final role = (await TokenStorage.getRole() ?? '').trim().toLowerCase();
    if (!mounted) return;
    final isAgent = role == 'agent' || role == 'real_estate_agent';
    setState(() {
      _isAgent = isAgent;
      if (!_isAgent && _currentIndex > 4) _currentIndex = 0;
    });
  }

  void _selectTab(int index) {
    if (index < 0 || index > 4) return;
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
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
        isAgent: _isAgent,
      ),
    );
  }
}
