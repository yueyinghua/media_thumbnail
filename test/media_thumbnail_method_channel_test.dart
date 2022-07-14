import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_thumbnail/media_thumbnail_method_channel.dart';

void main() {
  MethodChannelMediaThumbnail platform = MethodChannelMediaThumbnail();
  const MethodChannel channel = MethodChannel('media_thumbnail');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
