import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/app_settings_service.dart';
import '../localization/app_strings.dart';
import 'coloring_board_screen.dart';

class ChooseThemeScreen extends StatefulWidget {
  const ChooseThemeScreen({super.key});

  @override
  State<ChooseThemeScreen> createState() => _ChooseThemeScreenState();
}

class _ChooseThemeScreenState extends State<ChooseThemeScreen> {
  String _selectedCategory = 'animals';
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _scrollToCategory(int index) {
    if (_categoryScrollController.hasClients) {
      final target = (index * 130.0).clamp(
        0.0,
        _categoryScrollController.position.maxScrollExtent,
      );
      _categoryScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'emoji': '✨', 'key': 'themeAll'},
    {'id': 'animals', 'emoji': '🦁', 'key': 'themeAnimals', 'badgeKey': 'freeBadge'},
    {'id': 'dinosaurs', 'emoji': '🦖', 'key': 'themeDinosaurs', 'badgeKey': 'newBadge'},
    {'id': 'vehicles', 'emoji': '🚗', 'key': 'themeVehicles'},
    {'id': 'fairy', 'emoji': '🦄', 'key': 'themeFairy'},
    {'id': 'ocean', 'emoji': '🐬', 'key': 'themeOcean'},
  ];

  final List<Map<String, dynamic>> _allDrawings = [
    // Animals
    {
      'category': 'animals',
      'title': 'Mèo Con Đội Mũ',
      'difficultyKey': 'difficultyEasy',
      'isFree': true,
      'isNew': false,
      'isLocked': false,
      'color': AppColors.primary,
      'icon': Icons.pets,
      'image': 'assets/images/kitten_outline.jpg',
    },
    {
      'category': 'animals',
      'title': 'Gấu Trúc Nhí',
      'difficultyKey': 'difficultyEasy',
      'isFree': true,
      'isNew': false,
      'isLocked': false,
      'color': AppColors.primary,
      'icon': Icons.cruelty_free,
      'image': 'assets/images/panda_outline.jpg',
    },
    {
      'category': 'animals',
      'title': 'Chú Chó Cứu Hộ',
      'difficultyKey': 'difficultyMedium',
      'isFree': false,
      'isNew': true,
      'isLocked': false,
      'color': AppColors.secondary,
      'icon': Icons.pets,
      'image': 'assets/images/dog_outline.jpg',
    },
    {
      'category': 'animals',
      'title': 'Voi Con Tinh Nghịch',
      'difficultyKey': 'difficultyEasy',
      'isFree': true,
      'isNew': false,
      'isLocked': false,
      'color': AppColors.primary,
      'icon': Icons.pets,
    },

    // Dinosaurs
    {
      'category': 'dinosaurs',
      'title': 'T-Rex Nhí Tinh Nghịch',
      'difficultyKey': 'difficultyEasy',
      'isFree': false,
      'isNew': true,
      'isLocked': false,
      'color': AppColors.secondary,
      'icon': Icons.nature_people,
    },
    {
      'category': 'dinosaurs',
      'title': 'Khủng Long Bay Ptero',
      'difficultyKey': 'difficultyMedium',
      'isFree': true,
      'isNew': false,
      'isLocked': false,
      'color': AppColors.primary,
      'icon': Icons.flight,
    },

    // Vehicles
    {
      'category': 'vehicles',
      'title': 'Xe Cứu Hỏa Đỏ',
      'difficultyKey': 'difficultyEasy',
      'isFree': true,
      'isNew': false,
      'isLocked': false,
      'color': AppColors.primary,
      'icon': Icons.fire_truck,
    },
    {
      'category': 'vehicles',
      'title': 'Tàu Cứu Hộ Vũ Trụ',
      'difficultyKey': 'difficultyMedium',
      'isFree': false,
      'isNew': true,
      'isLocked': false,
      'color': AppColors.secondary,
      'icon': Icons.rocket_launch,
    },

    // Fairy
    {
      'category': 'fairy',
      'title': 'Kỳ Lân Cầu Vồng',
      'difficultyKey': 'difficultySpecial',
      'isFree': false,
      'isNew': false,
      'isLocked': true,
      'color': AppColors.goldDark,
      'icon': Icons.auto_awesome,
    },
    {
      'category': 'fairy',
      'title': 'Lâu Đài Cổ Tích',
      'difficultyKey': 'difficultyMedium',
      'isFree': true,
      'isNew': false,
      'isLocked': false,
      'color': AppColors.primary,
      'icon': Icons.castle,
    },

    // Ocean
    {
      'category': 'ocean',
      'title': 'Cá Heo Nhảy Múa',
      'difficultyKey': 'difficultyEasy',
      'isFree': true,
      'isNew': false,
      'isLocked': false,
      'color': AppColors.skyBlue,
      'icon': Icons.water,
    },
    {
      'category': 'ocean',
      'title': 'Rùa Biển Phiêu Lưu',
      'difficultyKey': 'difficultyMedium',
      'isFree': false,
      'isNew': true,
      'isLocked': false,
      'color': AppColors.secondary,
      'icon': Icons.surfing,
    },
  ];

  void _showAllCategoriesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.category, color: AppColors.secondary, size: 26),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.tr('allThemesModalTitle'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.tr('allThemesModalSubtitle'),
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['id'];
                  final count = cat['id'] == 'all'
                      ? _allDrawings.length
                      : _allDrawings.where((d) => d['category'] == cat['id']).length;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat['id'] as String;
                      });
                      Navigator.pop(ctx);
                      _scrollToCategory(index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.black12,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white24 : const Color(0xFFF0EEE8),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(cat['emoji'] as String, style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppStrings.tr(cat['key'] as String),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  '$count ${AppStrings.tr('picturesCount')}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.white, size: 20)
                          else if (cat['badgeKey'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.pastelYellow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                AppStrings.tr(cat['badgeKey'] as String),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.goldDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsService();

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final displayedDrawings = _allDrawings.where((drawing) {
          if (_selectedCategory == 'all') return true;
          return drawing['category'] == _selectedCategory;
        }).toList();

        final currentCategory = _categories.firstWhere(
          (c) => c['id'] == _selectedCategory,
          orElse: () => {'key': 'themeAll'},
        );
        final currentCategoryName = AppStrings.tr(currentCategory['key'] as String);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background.withValues(alpha: 0.85),
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.palette, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.tr('appName'),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      AppStrings.tr('chooseThemeTitle'),
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.pastelYellow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.goldDark, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${settings.starsCount}',
                          style: const TextStyle(
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 16,
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 16),
                ],
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Banner
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.pastelYellow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome, size: 16, color: AppColors.goldDark),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppStrings.tr('themeGreeting'),
                                    style: const TextStyle(
                                      color: AppColors.goldDark,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${AppStrings.tr('themeHeroLine1')}\n${AppStrings.tr('themeHeroLine2')}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/dino_mascot.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Voice prompt line
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🔊 ${AppStrings.tr('voiceInstruction')}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3EE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.volume_up, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppStrings.tr('voiceInstruction'),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4E2DD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_allDrawings.length} ${AppStrings.tr('picturesCount')}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Category Filter Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.category, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.tr('magicalThemes'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showAllCategoriesBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              AppStrings.tr('viewAll'),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Category Filter Carousel
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _categoryScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _categories.asMap().entries.map((entry) {
                            final index = entry.key;
                            final cat = entry.value;
                            final isSelected = _selectedCategory == cat['id'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = cat['id'] as String;
                                  });
                                  _scrollToCategory(index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? AppColors.primary.withValues(alpha: 0.3)
                                            : Colors.black.withValues(alpha: 0.04),
                                        blurRadius: isSelected ? 8 : 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white24 : const Color(0xFFF0EEE8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(cat['emoji'] as String, style: const TextStyle(fontSize: 16)),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppStrings.tr(cat['key'] as String),
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (cat['badgeKey'] != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.pastelYellow : const Color(0xFFC4E7FF),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            AppStrings.tr(cat['badgeKey'] as String),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isSelected ? AppColors.goldDark : const Color(0xFF004C69),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6),
                        ],
                      ),
                      child: IconButton(
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_forward_ios, color: AppColors.primary),
                        onPressed: () {
                          _categoryScrollController.animateTo(
                            (_categoryScrollController.offset + 140.0).clamp(
                              0.0,
                              _categoryScrollController.position.maxScrollExtent,
                            ),
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Grid header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          color: AppColors.secondary,
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        Text(
                          '${AppStrings.tr('collectionAnimals')}: $currentCategoryName',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EEE8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${displayedDrawings.length} ${AppStrings.tr('picturesCount')}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Filtered Drawing Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedDrawings.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final item = displayedDrawings[index];
                    if (item['isLocked'] == true) {
                      return _buildLockedCard(context, item['title'] as String, item['icon'] as IconData);
                    }
                    return _buildDrawingCard(
                      context,
                      item['title'] as String,
                      AppStrings.tr(item['difficultyKey'] as String),
                      item['isFree'] as bool,
                      item['isNew'] as bool,
                      item['color'] as Color,
                      item['icon'] as IconData,
                      item['image'] as String?,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Sticker Gift Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFE8DDFF), Color(0xFFC4E7FF)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: const Center(child: Text('🎁', style: TextStyle(fontSize: 24))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.tr('stickerGame'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              AppStrings.tr('stickerGameDesc'),
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✨ ${AppStrings.tr('turnReceived')}'),
                              backgroundColor: AppColors.secondary,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.secondary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppStrings.tr('playNow')),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawingCard(
    BuildContext context,
    String title,
    String difficulty,
    bool isFree,
    bool isNew,
    Color btnColor,
    IconData icon,
    String? imagePath,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: btnColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(imagePath, fit: BoxFit.cover),
                          )
                        : Center(child: Icon(icon, size: 54, color: btnColor)),
                  ),
                  if (isFree)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC4E7FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 12, color: Color(0xFF004C69)),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.tr('freeBadge'),
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF004C69),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isNew)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8DDFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.stars, size: 12, color: Color(0xFF4F319C)),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.tr('newBadge'),
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF4F319C),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${AppStrings.tr('difficulty')}: $difficulty',
                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ColoringBoardScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.tr('colorNow'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.brush, size: 14),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLockedCard(BuildContext context, String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(icon, size: 54, color: Colors.grey)),
                  Container(
                    color: Colors.white60,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_circle_filled, size: 30, color: AppColors.goldDark),
                          Text(
                            AppStrings.tr('watchAd'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.pastelYellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock, size: 12, color: AppColors.goldDark),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.tr('difficultySpecial'),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppStrings.tr('watchAd'),
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      AppSettingsService().addAiTurn(1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.tr('turnReceived')),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    child: Text(
                      AppStrings.tr('watchAd'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
