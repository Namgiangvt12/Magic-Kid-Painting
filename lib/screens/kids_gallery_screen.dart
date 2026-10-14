import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/app_settings_service.dart';
import '../services/audio_service.dart';
import '../localization/app_strings.dart';
import 'coloring_board_screen.dart';

class KidsGalleryScreen extends StatefulWidget {
  const KidsGalleryScreen({super.key});

  @override
  State<KidsGalleryScreen> createState() => _KidsGalleryScreenState();
}

class _KidsGalleryScreenState extends State<KidsGalleryScreen> {
  String _selectedFilter = 'all'; // all, done, wip

  final List<Map<String, dynamic>> _artworks = [
    {
      'id': '1',
      'title': 'Chú Mèo Nghệ Sĩ',
      'subtitle': '10 màu rực rỡ • Bé An',
      'status': 'done',
      'dateKey': 'today',
      'icon': Icons.pets,
      'color': AppColors.primary,
      'image': 'assets/images/finished_kitten.jpg',
    },
    {
      'id': '2',
      'title': 'Khủng Long Bay',
      'subtitle': 'Cầu vồng bảy sắc',
      'status': 'done',
      'dateKey': 'yesterday',
      'icon': Icons.flight,
      'color': AppColors.secondary,
    },
    {
      'id': '3',
      'title': 'Tàu Vũ Trụ Sao Hỏa',
      'subtitle': 'Đang hoàn thiện',
      'status': 'wip',
      'progress': 0.6,
      'dateKey': '3 ngày trước',
      'icon': Icons.rocket_launch,
      'color': AppColors.goldDark,
    },
    {
      'id': '4',
      'title': 'Kỳ Lân Cầu Vồng',
      'subtitle': 'Kiệt tác của bé',
      'status': 'done',
      'isMasterpiece': true,
      'dateKey': 'lastWeek',
      'icon': Icons.auto_awesome,
      'color': AppColors.purple,
    },
    {
      'id': '5',
      'title': 'Gấu Trúc Nhí',
      'subtitle': 'Đang vẽ dở',
      'status': 'wip',
      'progress': 0.35,
      'dateKey': 'yesterday',
      'icon': Icons.cruelty_free,
      'color': AppColors.primary,
      'image': 'assets/images/panda_outline.jpg',
    },
    {
      'id': '6',
      'title': 'Cá Heo Đại Dương',
      'subtitle': 'Bé vẽ sáng tạo',
      'status': 'done',
      'dateKey': '5 ngày trước',
      'icon': Icons.water,
      'color': AppColors.skyBlue,
    },
  ];

  void _confirmDelete(BuildContext context, Map<String, dynamic> art) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: AppColors.red, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.tr('deleteConfirmTitle'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          AppStrings.tr('deleteConfirmMsg'),
          style: const TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.tr('cancelBtn'), style: const TextStyle(color: Colors.black87)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _artworks.removeWhere((item) => item['id'] == art['id']);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.tr('deletedSuccess')),
                  backgroundColor: AppColors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppStrings.tr('deleteBtn')),
          ),
        ],
      ),
    );
  }

  String _getDateText(String key) {
    if (key == 'today') return AppStrings.tr('today');
    if (key == 'yesterday') return AppStrings.tr('yesterday');
    if (key == 'lastWeek') return AppStrings.tr('lastWeek');
    return key;
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsService();

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final filtered = _artworks.where((art) {
          if (_selectedFilter == 'all') return true;
          return art['status'] == _selectedFilter;
        }).toList();

        final totalCount = _artworks.length;
        final doneCount = _artworks.where((a) => a['status'] == 'done').length;
        final wipCount = _artworks.where((a) => a['status'] == 'wip').length;

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
                      AppStrings.tr('galleryTitle'),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                // Gallery Header Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EEE8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  AppStrings.tr('galleryRoomTitle'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(width: 4),
                                const Text('🖼️', style: TextStyle(fontSize: 16)),
                              ],
                            ),
                            Text(
                              '${AppStrings.tr('gallerySubtitlePrefix')} $totalCount ${AppStrings.tr('gallerySubtitleSuffix')}',
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.pastelYellow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.stars, color: AppColors.goldDark, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '$doneCount/12',
                                  style: const TextStyle(
                                    color: AppColors.goldDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              AppStrings.tr('framesCount'),
                              style: const TextStyle(color: AppColors.goldDark, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Filter Buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        id: 'all',
                        label: AppStrings.tr('filterAll'),
                        count: totalCount,
                        isSelected: _selectedFilter == 'all',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        id: 'done',
                        label: AppStrings.tr('filterDone'),
                        count: doneCount,
                        isSelected: _selectedFilter == 'done',
                        icon: '⭐',
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        id: 'wip',
                        label: AppStrings.tr('filterWip'),
                        count: wipCount,
                        isSelected: _selectedFilter == 'wip',
                        icon: '✏️',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Art Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final art = filtered[index];
                    final isDone = art['status'] == 'done';
                    final isMasterpiece = art['isMasterpiece'] == true;

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Artwork Thumbnail
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: (art['color'] as Color).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: art['image'] != null
                                        ? Image.asset(
                                            art['image'] as String,
                                            fit: BoxFit.cover,
                                          )
                                        : Center(
                                            child: Icon(
                                              art['icon'] as IconData,
                                              size: 54,
                                              color: art['color'] as Color,
                                            ),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isMasterpiece
                                          ? AppColors.goldDark
                                          : isDone
                                              ? AppColors.primary
                                              : AppColors.goldDark,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isMasterpiece
                                          ? AppStrings.tr('statusMasterpiece')
                                          : isDone
                                              ? AppStrings.tr('statusDone')
                                              : '${((art['progress'] as double) * 100).toInt()}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getDateText(art['dateKey'] as String),
                                      style: const TextStyle(color: Colors.white, fontSize: 9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Text Info
                          Text(
                            art['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            art['subtitle'] as String,
                            style: const TextStyle(color: Colors.black54, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      AudioService().playPop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ColoringBoardScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDone
                                          ? AppColors.primary.withValues(alpha: 0.15)
                                          : AppColors.pastelYellow,
                                      foregroundColor:
                                          isDone ? AppColors.primary : AppColors.goldDark,
                                      elevation: 0,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      isDone
                                          ? AppStrings.tr('continueColoring')
                                          : AppStrings.tr('finishColoring'),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  color: Colors.black45,
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _confirmDelete(context, art),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String id,
    required String label,
    required int count,
    required bool isSelected,
    String? icon,
  }) {
    return GestureDetector(
      onTap: () {
        AudioService().playPop();
        setState(() {
          _selectedFilter = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
            )
          ],
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Text(icon, style: const TextStyle(fontSize: 12)),
            ],
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
