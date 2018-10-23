import 'package:flutter/material.dart';
import 'launcher_helper.dart';

import 'dart:convert';

class AppWidget extends StatelessWidget {
  final AppInfo appInfo;
  final LauncherHelper launcherHelper;

  AppWidget({this.appInfo, this.launcherHelper});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          launcherHelper.launchApp(appInfo.packageName);
        },
        onLongPress: () {
          launcherHelper.launchAppSettings(appInfo.packageName);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.memory(
                base64.decode(appInfo.appIcon),
                width: 48.0,
                height: 48.0,
              ),
              SizedBox(
                width: 8.0,
              ),
              Text(appInfo.appLabel),
            ],
          ),
        ),
      ),
    );
  }
}
