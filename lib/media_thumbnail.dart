import 'package:flutter/services.dart';

class MediaThumbnail {
  static const MethodChannel _channel =
      MethodChannel('com.medinno/media_thumbnail');

  static Future<String?> videoThumbnail(String url, String outPath,
      {int quality = 100, Map<String, String>? headers}) async {
    return await _channel.invokeMethod('videoThumbnail', {
      'url': url,
      'outPath': outPath,
      'quality': quality,
      'headers': headers
    });
  }
}
