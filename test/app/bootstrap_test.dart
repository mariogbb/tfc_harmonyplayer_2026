import 'package:flutter_test/flutter_test.dart';
import 'package:player/app/bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('shows welcome once and saves the existing preference key', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    expect(await initializeWelcomePreference(prefs), isTrue);
    expect(prefs.getInt('initScreen'), 1);
    expect(await initializeWelcomePreference(prefs), isFalse);
  });

  test('does not show welcome for existing installations', () async {
    SharedPreferences.setMockInitialValues({'initScreen': 1});
    final prefs = await SharedPreferences.getInstance();

    expect(await initializeWelcomePreference(prefs), isFalse);
  });
}
