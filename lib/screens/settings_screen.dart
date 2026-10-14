import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/app_settings_service.dart';
import '../services/audio_service.dart';
import '../localization/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _mathA;
  late int _mathB;
  late int _correctAnswer;
  late List<int> _mathOptions;

  @override
  void initState() {
    super.initState();
    _generateMathChallenge();
  }

  void _generateMathChallenge() {
    final rand = Random();
    // Generate two numbers suitable for adult verification (e.g., 14 + 17 or 7 * 8)
    if (rand.nextBool()) {
      _mathA = 12 + rand.nextInt(25);
      _mathB = 11 + rand.nextInt(25);
      _correctAnswer = _mathA + _mathB;
    } else {
      _mathA = 6 + rand.nextInt(6);
      _mathB = 6 + rand.nextInt(6);
      _correctAnswer = _mathA * _mathB;
    }

    final Set<int> options = {_correctAnswer};
    while (options.length < 3) {
      final delta = (rand.nextInt(7) + 1) * (rand.nextBool() ? 1 : -1);
      final fake = _correctAnswer + delta;
      if (fake > 0 && fake != _correctAnswer) {
        options.add(fake);
      }
    }
    _mathOptions = options.toList()..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsService();

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
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
                      AppStrings.tr('settingsTitle'),
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
                          style: const TextStyle(color: AppColors.goldDark, fontWeight: FontWeight.bold),
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
                // Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.skyBlue.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.tune, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.tr('settingsHeader'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              AppStrings.tr('settingsSubtitle'),
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBorder,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_user, color: AppColors.secondary, size: 16),
                            SizedBox(width: 4),
                            Text('COPPA Safe', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Child Settings Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.sentiment_satisfied, color: AppColors.starGold, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.tr('childSettings'),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.pastelYellow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AppStrings.tr('childBadge'),
                              style: const TextStyle(color: AppColors.goldDark, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.tr('childSettingsDesc'),
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 16),

                      // SFX Toggle
                      _buildToggleTile(
                        icon: Icons.volume_up,
                        iconBg: AppColors.primaryLight,
                        iconColor: AppColors.primary,
                        title: AppStrings.tr('sfxTitle'),
                        subtitle: AppStrings.tr('sfxDesc'),
                        value: settings.sfxEnabled,
                        onChanged: (v) {
                          settings.setSfxEnabled(v);
                          if (v) AudioService().playPop();
                        },
                      ),
                      const SizedBox(height: 10),

                      // Music Toggle
                      _buildToggleTile(
                        icon: Icons.music_note,
                        iconBg: AppColors.secondaryLight,
                        iconColor: AppColors.secondary,
                        title: AppStrings.tr('musicTitle'),
                        subtitle: AppStrings.tr('musicDesc'),
                        value: settings.musicEnabled,
                        onChanged: (v) {
                          settings.setMusicEnabled(v);
                          if (v) AudioService().playPop();
                        },
                      ),
                      const SizedBox(height: 10),

                      // Voice Toggle
                      _buildToggleTile(
                        icon: Icons.record_voice_over,
                        iconBg: AppColors.pastelYellow,
                        iconColor: AppColors.brown,
                        title: AppStrings.tr('voiceTitle'),
                        subtitle: AppStrings.tr('voiceDesc'),
                        value: settings.voiceEnabled,
                        onChanged: (v) {
                          settings.setVoiceEnabled(v);
                          if (v) AudioService().playVoicePraise();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Language section
                      Text(
                        AppStrings.tr('langTitle'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.8,
                        children: [
                          _buildLangCard('🇻🇳', 'Tiếng Việt', 'Mặc định', 'vi', settings.selectedLanguage),
                          _buildLangCard('🇬🇧', 'English', 'English', 'en', settings.selectedLanguage),
                          _buildLangCard('🇯🇵', '日本語', 'Japanese', 'ja', settings.selectedLanguage),
                          _buildLangCard('🇰🇷', '한국어', 'Korean', 'ko', settings.selectedLanguage),
                          _buildLangCard('🇫🇷', 'Français', 'French', 'fr', settings.selectedLanguage),
                          _buildLangCard('🇨🇳', '中文', 'Chinese', 'zh', settings.selectedLanguage),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Parents Gate Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.tr('parentGate'),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    AppStrings.tr('parentGateSubtitle'),
                                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(Icons.verified, color: AppColors.secondary),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppStrings.tr('coppaText'),
                                style: const TextStyle(fontSize: 11, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (!settings.isParentUnlocked) ...[
                        // Math challenge to unlock
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppColors.secondaryLight,
                                radius: 24,
                                child: Icon(Icons.lock_clock, color: AppColors.secondary, size: 28),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppStrings.tr('adultVerify'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                AppStrings.tr('mathPrompt'),
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$_mathA + $_mathB = ?',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: _mathOptions.map((opt) {
                                  return _buildMathBtn('$opt', opt == _correctAnswer);
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Unlocked Dashboard Content
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: AppColors.secondary),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppStrings.tr('parentUnlocked'),
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                                      ),
                                    ],
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        settings.setParentUnlocked(false);
                                        _generateMathChallenge();
                                      });
                                    },
                                    icon: const Icon(Icons.lock, size: 16),
                                    label: Text(AppStrings.tr('lockAgain')),
                                  )
                                ],
                              ),
                              const Divider(),
                              const SizedBox(height: 8),

                              Text(
                                AppStrings.tr('screenTime'),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.tr('screenTimeDesc'),
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildTimeLimitChip('15 ${AppStrings.tr('minutes')}', '15', settings),
                                  const SizedBox(width: 6),
                                  _buildTimeLimitChip('30 ${AppStrings.tr('minutes')}', '30', settings),
                                  const SizedBox(width: 6),
                                  _buildTimeLimitChip('45 ${AppStrings.tr('minutes')}', '45', settings),
                                  const SizedBox(width: 6),
                                  _buildTimeLimitChip(AppStrings.tr('unlimited'), 'unlimited', settings),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Premium Banner
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.pastelYellow, AppColors.secondaryLight],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppStrings.tr('premiumTitle'),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          Text(
                                            AppStrings.tr('premiumDesc'),
                                            style: const TextStyle(fontSize: 11, color: Colors.black87),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Chức năng thanh toán an toàn đang mở...')),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.starGold,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('89.000đ'),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Phiên bản 2.4.0 (Build 2026) • Bản quyền Color Kids Studio',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.primary,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLangCard(String flag, String name, String sub, String code, String currentLang) {
    final isSelected = currentLang == code;
    return GestureDetector(
      onTap: () {
        AudioService().playPop();
        AppSettingsService().setSelectedLanguage(code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  Text(sub, style: const TextStyle(color: Colors.black54, fontSize: 9)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildMathBtn(String text, bool isCorrect) {
    return ElevatedButton(
      onPressed: () {
        if (isCorrect) {
          AudioService().playFanfare();
          AppSettingsService().setParentUnlocked(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.tr('authSuccess')),
              backgroundColor: AppColors.secondary,
            ),
          );
        } else {
          AudioService().playUndo();
          setState(() {
            _generateMathChallenge();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.tr('authFailed')),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surfaceCard,
        foregroundColor: Colors.black87,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTimeLimitChip(String label, String value, AppSettingsService settings) {
    final isSelected = settings.timeLimit == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AudioService().playTap();
          settings.setTimeLimit(value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
