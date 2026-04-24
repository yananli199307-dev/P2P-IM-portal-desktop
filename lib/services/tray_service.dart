import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class TrayService {
  static final TrayService _instance = TrayService._internal();
  factory TrayService() => _instance;
  TrayService._internal();

  final SystemTray _systemTray = SystemTray();

  Future<void> initialize() async {
    await _systemTray.initSystemTray(
      title: "P2P IM Portal",
      iconPath: 'assets/icon.png', // 需要准备图标文件
      toolTip: "P2P IM Portal",
    );

    _systemTray.setContextMenu([
      MenuItem(
        label: '显示',
        onClicked: () async {
          await windowManager.show();
          await windowManager.focus();
        },
      ),
      MenuItem(
        label: '隐藏',
        onClicked: () async {
          await windowManager.hide();
        },
      ),
      MenuSeparator(),
      MenuItem(
        label: '退出',
        onClicked: () async {
          await windowManager.close();
        },
      ),
    ]);

    _systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        windowManager.show();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }
}
