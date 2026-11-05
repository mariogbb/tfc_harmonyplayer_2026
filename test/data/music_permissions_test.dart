import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:player/data/services/music_library/music_permissions.dart';

void main() {
  test('selects media audio starting with Android 13', () {
    expect(permissionForAndroidSdk(32), Permission.storage);
    expect(permissionForAndroidSdk(33), Permission.audio);
  });
  test(
    'denial is returned and permanent denial does not prompt again',
    () async {
      var requests = 0;
      var current = PermissionStatus.denied;
      final permissions = MusicPermissions(
        isAndroid: true,
        androidSdk: () async => 33,
        status: (permission) async {
          expect(permission, Permission.audio);
          return current;
        },
        requestPermission: (permission) async {
          requests++;
          return PermissionStatus.denied;
        },
      );
      expect(await permissions.isGranted(), isFalse);
      expect(await permissions.request(), isFalse);
      expect(requests, 1);
      current = PermissionStatus.permanentlyDenied;
      expect(await permissions.request(), isFalse);
      expect(requests, 1);
    },
  );
}
