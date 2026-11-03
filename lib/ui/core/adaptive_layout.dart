import 'package:flutter/widgets.dart';

abstract class StatelessAdaptiveLayout extends StatelessWidget {
  const StatelessAdaptiveLayout({Key? key}) : super(key: key);

  Widget buildLarge(BuildContext context);
  Widget buildNormal(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return buildNormal(context);
        }
        return buildLarge(context);
      },
    );
  }
}

mixin AdaptiveElement<T extends StatefulWidget> on State<T> {
  late Orientation _orientation;

  Orientation get getOrientation => _orientation;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          _orientation = orientation;
          return buildNormal(context);
        }
        _orientation = orientation;
        return buildLarge(context);
      },
    );
  }

  Widget buildNormal(BuildContext context);
  Widget buildLarge(BuildContext context);
}
