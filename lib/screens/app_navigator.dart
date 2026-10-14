import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../services/app_settings_service.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';
import 'choose_theme_screen.dart';
import 'ai_magic_screen.dart';
import 'kids_gallery_screen.dart';
import 'settings_screen.dart';

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChooseThemeScreen(),
    const AiMagicScreen(),
    const KidsGalleryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettingsService(),
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (_currentIndex != index) {
                AudioService().playPop();
              }
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF00668A),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: AppStrings.tr('navHome'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.palette),
                label: AppStrings.tr('navColoring'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.auto_fix_high),
                label: AppStrings.tr('navAiMagic'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.photo_library),
                label: AppStrings.tr('navGallery'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: AppStrings.tr('navSettings'),
              ),
            ],
          ),
        );
      },
    );
  }
}

