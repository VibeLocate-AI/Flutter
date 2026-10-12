import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/storage/token_storage.dart';
import '../../core/auth/auth_role.dart';
import '../../core/controllers/favorites_controller.dart';
import '../../core/controllers/my_properties_controller.dart';
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
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Lazy-create tabs. IndexedStack keeps already opened screens alive, but
    // it must not start five API requests during the first frame.
    _pages = List<Widget>.generate(5, (_) => const SizedBox.shrink());
    _pages[0] = const HomePage();
    _loadAccountRole();
  }

  Future<void> _loadAccountRole() async {
    final role = (await TokenStorage.getRole() ?? '').trim().toLowerCase();
    if (!mounted) return;
    setState(() {
      _isAgent = AuthRole.isAgent(role);
    });
  }

  Widget _pageFor(int index) {
    switch (index) {
      case 0: return const HomePage();
      case 1: return const MapPage();
      case 2: return const PropertiesPage();
      case 3: return const FavoritesPage();
      case 4: return const ProfilePage();
      default: return const SizedBox.shrink();
    }
  }

  void _selectTab(int index) {
    if (index < 0 || index > 4 || index == _currentIndex) return;
    final alreadyCreated = _pages[index] is! SizedBox;
    if (!alreadyCreated) {
      _pages[index] = _pageFor(index);
    }
    setState(() => _currentIndex = index);
    if (alreadyCreated && index == 2 && Get.isRegistered<MyPropertiesController>()) {
      Get.find<MyPropertiesController>().reload();
    }
    if (alreadyCreated && index == 3 && Get.isRegistered<FavoritesController>()) {
      Get.find<FavoritesController>().reload(showLoader: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onItemSelected: _selectTab,
        isAgent: _isAgent,
      ),
    );
  }
}
