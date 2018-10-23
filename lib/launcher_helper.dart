import 'package:flutter/services.dart';

class AppInfo {

  final String packageName;
  final String appIcon;
  final String appLabel;

  AppInfo({this.packageName, this.appIcon, this.appLabel});

}

class LauncherHelper {

  static const platform = const MethodChannel(
      'com.mateusrodcosta.flutter.hedgehoglauncher/launcher_helper');


  Future<List<AppInfo>> getAppsFromAndroid() async {

    List<AppInfo> _listApps = <AppInfo>[];

    try {
      List<dynamic> apps = await platform.invokeMethod('getListApps');
      for (var item in apps) {
        _listApps.add(new AppInfo(
          packageName: item["packageName"],
          appIcon: item["appIcon"],
          appLabel: item["appLabel"],
        ));
      }

      _listApps.sort((a, b) {
        return a.appLabel.toUpperCase().compareTo(b.appLabel.toUpperCase());
      });
    } on PlatformException catch (e) {
      _listApps = null;
      print(e.toString());
    }

    return _listApps;
  }

  void launchAppSettings(String app) async {
    await platform.invokeMethod('openAppSettings-$app');
  }

  void launchApp(String app) async {
    await platform.invokeMethod('openApp-$app');
  }
}
