import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'dart:io' show Platform;
import 'constants.dart';

class UserSettings {
  static final UserSettings _instancia = UserSettings._internal();
  late String _platform;

  factory UserSettings() {
    return _instancia;
  }

  UserSettings._internal();

  late SharedPreferences _prefs;

  initPrefs(String platform) async {
    String deviceId;
    try {
      deviceId = await PlatformDeviceId.getDeviceId ?? 'deviceId ERROR await';
      deviceId = deviceId.replaceAll('/[^0-9A-zÀ-ú]/', '').trim();
    } on PlatformException {
      deviceId = 'deviceId ERROR';
    }
    _prefs = await SharedPreferences.getInstance();
    _prefs.setString('deviceid', deviceId);
    _platform = platform;
  }

  // Servidores
  String get signalingHost {
    return _prefs.getString('signalig') ?? wsserver;
  }

  set signalingHost(String value) {
    _prefs.setString('signalig', value.trim());
  }

  String get uploadUrl {
    return _prefs.getString('upload') ?? uploadurl;
  }

  set uploadUrl(String value) {
    _prefs.setString('upload', value.trim());
  }

  // peerId
  String get peerId => deviceId;

  // deviceId
  String get deviceId {
    return _prefs.getString('deviceid') ?? 'deviceId';
  }

  // Platform
  String get platform => _platform; //Platform.operatingSystemVersion;

  // ALIAS
  String get alias {
    return _prefs.getString('alias') ?? deviceId;
  }

  set alias(String value) {
    _prefs.setString('alias', value.trim());
  }

  // DESCRIPCION
  String get description {
    return _prefs.getString('description') ?? _platform;
    //'${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
  }

  set description(String value) {
    _prefs.setString('description', value.trim());
  }
}
