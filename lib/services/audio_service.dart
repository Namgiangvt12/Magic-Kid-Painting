import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'app_settings_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();
  final List<AudioPlayer> _sfxPool = [];
  static const int _poolSize = 4;
  int _poolIndex = 0;

  static bool testMode = false;

  bool _isInitialized = false;
  bool _isBgmPlaying = false;
  bool _isDucked = false;
  bool _pendingBgmOnFirstGesture = false;

  double _bgmVolume = 0.28;
  double _sfxVolume = 0.75;
  double _voiceVolume = 0.90;

  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  double get voiceVolume => _voiceVolume;

  void setBgmVolume(double vol) {
    _bgmVolume = vol.clamp(0.0, 1.0);
    try {
      _bgmPlayer.setVolume(_isDucked ? 0.08 : _bgmVolume).catchError((_) {});
    } catch (_) {}
  }

  void setSfxVolume(double vol) {
    _sfxVolume = vol.clamp(0.0, 1.0);
  }

  void setVoiceVolume(double vol) {
    _voiceVolume = vol.clamp(0.0, 1.0);
  }

  DateTime _lastBrushSoundTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastTapSoundTime = DateTime.fromMillisecondsSinceEpoch(0);

  bool get isBgmPlaying => _isBgmPlaying;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    if (testMode) {
      AppSettingsService().addListener(_onSettingsChanged);
      if (AppSettingsService().musicEnabled) {
        _isBgmPlaying = true;
      }
      return;
    }

    try {
      // 1. Setup BGM Player
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop).catchError((e) {
        debugPrint('AudioService BGM loop mode error: $e');
      });
      await _bgmPlayer.setVolume(_bgmVolume).catchError((e) {
        debugPrint('AudioService BGM volume error: $e');
      });

      // 2. Setup SFX Player Pool
      for (int i = 0; i < _poolSize; i++) {
        try {
          final player = AudioPlayer();
          await player.setReleaseMode(ReleaseMode.stop).catchError((_) {});
          await player.setVolume(_sfxVolume).catchError((_) {});
          _sfxPool.add(player);
        } catch (e) {
          debugPrint('AudioService SFX pool init error: $e');
        }
      }

      // 3. Setup Voice Player
      try {
        await _voicePlayer.setReleaseMode(ReleaseMode.stop).catchError((_) {});
        await _voicePlayer.setVolume(_voiceVolume).catchError((_) {});
      } catch (e) {
        debugPrint('AudioService voice init error: $e');
      }

      // 4. Hook settings listener
      AppSettingsService().addListener(_onSettingsChanged);

      // 5. Handle initial BGM
      if (AppSettingsService().musicEnabled) {
        if (kIsWeb) {
          // On Web, browsers block audio autoplay before user interaction.
          // Defer BGM until first user tap/click.
          _pendingBgmOnFirstGesture = true;
        } else {
          await playBgm();
        }
      }
    } catch (e) {
      debugPrint('AudioService init exception: $e');
    }
  }

  /// Called upon user interactions (e.g. tap, click, gesture) to start BGM if pending.
  void unlockAudio() {
    if (_pendingBgmOnFirstGesture && AppSettingsService().musicEnabled && !_isBgmPlaying) {
      _pendingBgmOnFirstGesture = false;
      playBgm();
    }
  }

  void _onSettingsChanged() {
    final settings = AppSettingsService();
    if (!settings.musicEnabled && _isBgmPlaying) {
      pauseBgm();
    } else if (settings.musicEnabled && !_isBgmPlaying) {
      if (kIsWeb && !_isInitialized) {
        _pendingBgmOnFirstGesture = true;
      } else {
        resumeBgm();
      }
    }
  }

  // --- Background Music (BGM) Controls ---

  Future<void> playBgm({String assetPath = 'audio/bgm_cheerful.wav'}) async {
    if (!AppSettingsService().musicEnabled) return;
    if (testMode) {
      _isBgmPlaying = true;
      return;
    }
    try {
      await _bgmPlayer.stop().catchError((_) {});
      await _bgmPlayer.setVolume(_isDucked ? 0.08 : _bgmVolume).catchError((_) {});
      await _bgmPlayer.play(AssetSource(assetPath)).timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          debugPrint('AudioService playBgm timed out');
        },
      );
      _isBgmPlaying = true;
      _pendingBgmOnFirstGesture = false;
    } catch (e) {
      debugPrint('AudioService playBgm error: $e');
      if (kIsWeb) {
        // Autoplay may have been blocked; retry on next gesture
        _pendingBgmOnFirstGesture = true;
      }
    }
  }

  Future<void> pauseBgm() async {
    if (testMode) {
      _isBgmPlaying = false;
      return;
    }
    try {
      await _bgmPlayer.pause().catchError((_) {});
      _isBgmPlaying = false;
    } catch (e) {
      debugPrint('AudioService pauseBgm error: $e');
    }
  }

  Future<void> resumeBgm() async {
    if (!AppSettingsService().musicEnabled) return;
    if (testMode) {
      _isBgmPlaying = true;
      return;
    }
    try {
      await _bgmPlayer.resume().catchError((_) {});
      _isBgmPlaying = true;
    } catch (e) {
      // If resume fails, attempt playing afresh
      await playBgm();
    }
  }

  Future<void> stopBgm() async {
    if (testMode) {
      _isBgmPlaying = false;
      return;
    }
    try {
      await _bgmPlayer.stop().catchError((_) {});
      _isBgmPlaying = false;
    } catch (e) {
      debugPrint('AudioService stopBgm error: $e');
    }
  }

  // --- Sound Effects (SFX) Pool ---

  AudioPlayer? _getNextSfxPlayer() {
    if (_sfxPool.isEmpty) return null;
    final player = _sfxPool[_poolIndex];
    _poolIndex = (_poolIndex + 1) % _sfxPool.length;
    return player;
  }

  Future<void> _playSfx(String assetPath, {double volumeMultiplier = 1.0}) async {
    unlockAudio();
    if (testMode) return;
    if (!AppSettingsService().sfxEnabled) return;
    try {
      final player = _getNextSfxPlayer();
      if (player != null) {
        await player.stop().catchError((_) {});
        await player.setVolume((_sfxVolume * volumeMultiplier).clamp(0.0, 1.0)).catchError((_) {});
        await player.play(AssetSource(assetPath)).timeout(
          const Duration(seconds: 3),
          onTimeout: () {},
        );
      }
    } catch (e) {
      debugPrint('AudioService SFX error ($assetPath): $e');
    }
  }

  /// Bubble pop for button clicks, cards, category selection
  void playPop() {
    final now = DateTime.now();
    if (now.difference(_lastTapSoundTime).inMilliseconds < 50) return;
    _lastTapSoundTime = now;
    _playSfx('audio/pop.wav');
  }

  /// Subtle tactile click for small switches & quick toggles
  void playTap() {
    final now = DateTime.now();
    if (now.difference(_lastTapSoundTime).inMilliseconds < 50) return;
    _lastTapSoundTime = now;
    _playSfx('audio/tap.wav', volumeMultiplier: 0.85);
  }

  /// Melodic marimba chime when picking a crayon or palette color
  void playColorSelect() {
    _playSfx('audio/color_select.wav', volumeMultiplier: 0.95);
  }

  /// Continuous drawing stroke sound with built-in throttle (every 140ms)
  void playBrushStroke() {
    final now = DateTime.now();
    if (now.difference(_lastBrushSoundTime).inMilliseconds < 140) return;
    _lastBrushSoundTime = now;
    _playSfx('audio/brush.wav', volumeMultiplier: 0.65);
  }

  /// Flood fill liquid paint bloop/splash
  void playBucketFill() {
    _playSfx('audio/bucket.wav');
  }

  /// Undo bouncy chirp
  void playUndo() {
    _playSfx('audio/undo.wav');
  }

  /// Redo upward chirp
  void playRedo() {
    _playSfx('audio/redo.wav');
  }

  /// Soft eraser sweep
  void playEraser() {
    _playSfx('audio/eraser.wav');
  }

  /// Fairy tale sparkle / magic dust for AI Magic wand & rewards
  void playSparkle() {
    _playSfx('audio/sparkle.wav');
  }

  /// Camera shutter & success chime when artwork is saved
  void playSave() {
    _playSfx('audio/save.wav');
  }

  /// Celebratory fanfare with ducking on BGM
  Future<void> playFanfare() async {
    unlockAudio();
    if (testMode) return;
    if (!AppSettingsService().sfxEnabled) return;
    try {
      _duckBgm(true);
      final player = _getNextSfxPlayer();
      if (player != null) {
        await player.stop().catchError((_) {});
        await player.setVolume(1.0).catchError((_) {});
        await player.play(AssetSource('audio/fanfare.wav')).timeout(
          const Duration(seconds: 4),
          onTimeout: () {},
        );
      }
      // Restore BGM after fanfare finishes
      Timer(const Duration(milliseconds: 2900), () {
        _duckBgm(false);
      });
    } catch (e) {
      debugPrint('AudioService playFanfare error: $e');
      _duckBgm(false);
    }
  }

  /// Encouraging praise voice / cheer with ducking on BGM
  Future<void> playVoicePraise() async {
    unlockAudio();
    if (testMode) return;
    if (!AppSettingsService().voiceEnabled) return;
    try {
      _duckBgm(true);
      await _voicePlayer.stop().catchError((_) {});
      await _voicePlayer.setVolume(_voiceVolume).catchError((_) {});
      await _voicePlayer.play(AssetSource('audio/praise_yay.wav')).timeout(
        const Duration(seconds: 4),
        onTimeout: () {},
      );

      Timer(const Duration(milliseconds: 1300), () {
        _duckBgm(false);
      });
    } catch (e) {
      debugPrint('AudioService playVoicePraise error: $e');
      _duckBgm(false);
    }
  }

  void _duckBgm(bool duck) {
    if (!_isBgmPlaying || _isDucked == duck) return;
    _isDucked = duck;
    try {
      _bgmPlayer.setVolume(duck ? 0.08 : _bgmVolume).catchError((_) {});
    } catch (e) {
      debugPrint('AudioService duck error: $e');
    }
  }

  void dispose() {
    AppSettingsService().removeListener(_onSettingsChanged);
    _bgmPlayer.dispose().catchError((_) {});
    _voicePlayer.dispose().catchError((_) {});
    for (final p in _sfxPool) {
      p.dispose().catchError((_) {});
    }
    _sfxPool.clear();
  }
}
