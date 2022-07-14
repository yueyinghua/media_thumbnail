import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:media_thumbnail/media_thumbnail.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _platformVersion;

  @override
  void initState() {
    super.initState();

  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      final thumbnailPath = await getCacheDir();
      platformVersion = await MediaThumbnail.videoThumbnail(
          "https://jabil-jpn3-dev.s3.ap-southeast-1.amazonaws.com/event/7e7e93a0-f905-11ec-b8f2-6ff232c1a3fc/byiy5odu.sen.mp4?X-Amz-Expires=3600&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAU2QVTTS2U6WVZUJQ/20220713/ap-southeast-1/s3/aws4_request&X-Amz-Date=20220713T103112Z&X-Amz-SignedHeaders=host&X-Amz-Signature=ea02fd292c9fba2518b0ef0338de3e3969e9c567bcdcc0f0c927359170f74aca",
          "$thumbnailPath/xx.jpg");
    } catch (ex){
      debugPrint(ex.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            InkWell(onTap: (){
              initPlatformState();
            }, child: const Text("Image"))
          ],
        ),
        body: Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: _platformVersion == null
                ? const Text("Unknown")
                : Image(
                    image: FileImage(File(_platformVersion!)),
                  ),
          ),
        ),
      ),
    );
  }

  Future<String> getCacheDir([String? subDir]) async {
    var parentPath = (await getTemporaryDirectory()).path;
    return createSubDirIfNotExist(parentPath, subDir);
  }

  Future<String> createSubDirIfNotExist(String currentPath,
      [String? subDir]) async {
    if (subDir == null || subDir.isEmpty) {
      return currentPath;
    }
    var parentPath = currentPath;
    final dirs = subDir.split('/');
    for (final p in dirs) {
      final path = '$parentPath/$p';
      var dir = Directory(path);
      if (!dir.existsSync()) {
        await dir.create();
      }
      parentPath = path;
    }
    return parentPath;
  }
}
