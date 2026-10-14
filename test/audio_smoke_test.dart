import 'package:flutter_test/flutter_test.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('audioplayers basic instantiation', () {
    final player = AudioPlayer();
    expect(player, isNotNull);
    expect(player.audioCache.prefix, equals('assets/'));
    final source = AssetSource('audio/pop.wav');
    expect(source.path, equals('audio/pop.wav'));
  });
}
