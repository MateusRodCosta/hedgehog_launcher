import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:battery/battery.dart';

import 'launcher_helper.dart';
import 'systemui_helper.dart';
import 'app_widget.dart';

class WallpaperWidget extends StatelessWidget {
  final Uint8List wallpaper;

  WallpaperWidget({this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.9,
      child: Image.memory(
        wallpaper,
        fit: BoxFit.cover,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  LauncherHelper _launcherHelper = new LauncherHelper();
  SystemUIHelper _systemUIHelper = new SystemUIHelper();
  Battery _battery = new Battery();

  List<AppInfo> _apps;
  Uint8List _userWallpaper;
  int _batteryLevel;

  Color _color;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  VoidCallback _showBottomSheetCallback;

  @override
  void initState() {
    super.initState();

    _getAppList();
    _getUserWallpaper();
    _getUserBattery();

    _showBottomSheetCallback = _showBottomSheet;
  }

  _getUserBattery() {
    _battery.batteryLevel.then((result) {
      setState(() {
        _batteryLevel = result;
      });
    });
  }

  _getUserWallpaper() async {
    _systemUIHelper.getUserWallpaper().then((image) {
      setState(() {
        _userWallpaper = image;
      });
    });
  }

  _getAppList() async {
    _launcherHelper.getAppsFromAndroid().then((list) {
      setState(() {
        _apps = list;
      });
    });
  }

  void _showBottomSheet() {
    setState(() {
      // disable the button
      _showBottomSheetCallback = null;
    });
    _scaffoldKey.currentState
        .showBottomSheet<Null>((BuildContext context) {
          //final ThemeData themeData = Theme.of(context);
          return ListView.builder(
            itemCount: _apps == null ? 0 : _apps.length,
            itemBuilder: (context, item) {
              return AppWidget(
                appInfo: _apps[item],
                launcherHelper: _launcherHelper,
              );
            },
          );
        })
        .closed
        .whenComplete(() {
          if (mounted) {
            setState(() {
              // re-enable the button
              _showBottomSheetCallback = _showBottomSheet;
            });
          }
        });
  }

  Widget _buildWallpaperWidget() {
    if (_userWallpaper == null) {
      return Container();
    } else {
      return WallpaperWidget(
        wallpaper: _userWallpaper,
      );
    }
  }

  Widget _buildAppLauncherWidget() {
    return Material(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: InkWell(
          onTap: _showBottomSheetCallback,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.apps,
                size: 48.0,
              ),
              Text("Show App Launcher"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemUI() {
    DateTime time = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: _color,
        child: InkWell(
          onTap: () {
            setState(() {
              if(_color != Colors.red) {
                _color = Colors.red;
              } else {
                _color = Colors.blue;
              }

            });
            print("a");
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text(
                  "${time.hour.toString()}:${time.minute.toString()}",
                  style: TextStyle(color: Colors.black),
                ),
                Expanded(
                  child: SizedBox(),
                ),
                CircleAvatar(
                  child: Icon(Icons.person),
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Text(
                  "$_batteryLevel%",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                _buildWallpaperWidget(),
                Container(
                  alignment: Alignment.center,
                  child: _buildSystemUI(),
                )
              ],
            ),
          ),
          _buildAppLauncherWidget(),
        ],
      ),
    );
  }
}
