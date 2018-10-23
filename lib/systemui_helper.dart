import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';

class SystemUIHelper {

  static const platform = const MethodChannel(
      'com.mateusrodcosta.flutter.hedgehoglauncher/systemui_helper');

  Future<Uint8List> getUserWallpaper() async {
    try {
      String wallpaperString = await platform.invokeMethod('getUserWallpaper');
      return base64.decode(wallpaperString);
    } on PlatformException catch (e) {
      print(e.toString());
      return null;
    }
  }

}
