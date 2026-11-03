import 'package:flutter/widgets.dart';
import 'package:player/app/app.dart';
import 'package:player/app/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final showWelcome = await bootstrap();
  runApp(HarmonyApp(showWelcome: showWelcome));
}
