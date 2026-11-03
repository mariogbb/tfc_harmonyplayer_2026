import 'package:flutter/material.dart';
import 'package:player/app/app.dart';
import 'package:player/app/bootstrap.dart';
import 'package:player/l10n/app_localizations.dart';

/// Displays initialization progress and a safe failure state before the app exists.
class StartupApp extends StatefulWidget {
  const StartupApp({
    super.key,
    this.initialize = bootstrap,
    this.appBuilder = _buildApp,
  });

  final Future<bool> Function() initialize;
  final Widget Function(bool showWelcome) appBuilder;

  static Widget _buildApp(bool showWelcome) =>
      HarmonyApp(showWelcome: showWelcome);

  @override
  State<StartupApp> createState() => _StartupAppState();
}

class _StartupAppState extends State<StartupApp> {
  late final Future<bool> _initialization = _initialize();

  Future<bool> _initialize() async {
    try {
      return await widget.initialize();
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'application startup',
        ),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasData) return widget.appBuilder(snapshot.requireData);
        return MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                if (!snapshot.hasError) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      AppLocalizations.of(context)!.startup_error,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
