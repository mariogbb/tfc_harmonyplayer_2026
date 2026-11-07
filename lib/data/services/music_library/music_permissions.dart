import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Android 13 replaced legacy external-storage access with media permissions.
Permission permissionForAndroidSdk(int sdk) =>
    sdk >= 33 ? Permission.audio : Permission.storage;

class MusicPermissions {
  MusicPermissions({
    Future<int> Function()? androidSdk,
    bool? isAndroid,
    Future<PermissionStatus> Function(Permission)? status,
    Future<PermissionStatus> Function(Permission)? requestPermission,
  }) : _androidSdk = androidSdk ?? _readAndroidSdk,
       _isAndroid = isAndroid ?? Platform.isAndroid,
       _status = status ?? _readStatus,
       _requestPermission = requestPermission ?? _request;

  final Future<int> Function() _androidSdk;
  final bool _isAndroid;
  final Future<PermissionStatus> Function(Permission) _status;
  final Future<PermissionStatus> Function(Permission) _requestPermission;
  static Future<PermissionStatus> _readStatus(Permission permission) =>
      permission.status;
  static Future<PermissionStatus> _request(Permission permission) =>
      permission.request();
  static Future<int> _readAndroidSdk() async =>
      (await DeviceInfoPlugin().androidInfo).version.sdkInt;

  Future<bool> isGranted() async {
    if (!_isAndroid) return true;
    final permission = permissionForAndroidSdk(await _androidSdk());
    return (await _status(permission)).isGranted;
  }

  Future<bool> request() async {
    if (!_isAndroid) return true;
    final permission = permissionForAndroidSdk(await _androidSdk());
    final status = await _status(permission);
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied || status.isRestricted) return false;
    return (await _requestPermission(permission)).isGranted;
  }
}
