import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitch_color_app/services/app_settings_service.dart';
import 'package:stitch_color_app/services/audio_service.dart';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '.',
    );
    AudioService.testMode = true;
    SharedPreferences.setMockInitialValues({});
    await AppSettingsService().init();
  });

  test('AudioService singleton initialization', () async {
    final audioService = AudioService();
    expect(audioService, isNotNull);
    await audioService.init();
    expect(audioService.isBgmPlaying, isTrue);
  });

  test('AudioService reacts to musicEnabled toggle', () async {
    final audioService = AudioService();
    await audioService.init();
    final settings = AppSettingsService();

    // Disable music
    await settings.setMusicEnabled(false);
    expect(audioService.isBgmPlaying, isFalse);

    // Re-enable music
    await settings.setMusicEnabled(true);
    expect(audioService.isBgmPlaying, isTrue);
  });

  test('AudioService SFX methods trigger safely without exceptions', () async {
    final audioService = AudioService();
    await audioService.init();

    expect(() => audioService.playPop(), returnsNormally);
    expect(() => audioService.playTap(), returnsNormally);
    expect(() => audioService.playColorSelect(), returnsNormally);
    expect(() => audioService.playBrushStroke(), returnsNormally);
    expect(() => audioService.playBrushStroke(), returnsNormally); // Throttle branch
    expect(() => audioService.playBucketFill(), returnsNormally);
    expect(() => audioService.playUndo(), returnsNormally);
    expect(() => audioService.playRedo(), returnsNormally);
    expect(() => audioService.playEraser(), returnsNormally);
    expect(() => audioService.playSparkle(), returnsNormally);
    expect(() => audioService.playSave(), returnsNormally);
    expect(() => audioService.playFanfare(), returnsNormally);
    expect(() => audioService.playVoicePraise(), returnsNormally);
  });
}
