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
          "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
          "$thumbnailPath/xx.jpg");
    } catch (ex) {
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
            InkWell(
                onTap: () {
                  initPlatformState();
                },
                child: const Text("Image"))
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
