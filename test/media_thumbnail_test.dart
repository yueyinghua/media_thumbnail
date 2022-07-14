import 'package:flutter_test/flutter_test.dart';
import 'package:media_thumbnail/media_thumbnail.dart';
import 'package:media_thumbnail/media_thumbnail_platform_interface.dart';
import 'package:media_thumbnail/media_thumbnail_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMediaThumbnailPlatform 
    with MockPlatformInterfaceMixin
    implements MediaThumbnailPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MediaThumbnailPlatform initialPlatform = MediaThumbnailPlatform.instance;

  test('$MethodChannelMediaThumbnail is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMediaThumbnail>());
  });

  test('getPlatformVersion', () async {
    MediaThumbnail mediaThumbnailPlugin = MediaThumbnail();
    MockMediaThumbnailPlatform fakePlatform = MockMediaThumbnailPlatform();
    MediaThumbnailPlatform.instance = fakePlatform;
  
    expect(await mediaThumbnailPlugin.getPlatformVersion(), '42');
  });
}
