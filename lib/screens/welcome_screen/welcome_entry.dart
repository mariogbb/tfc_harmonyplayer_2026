import 'package:flutter/material.dart';

class WelcomeEntry extends StatelessWidget {
  const WelcomeEntry(
      {Key? key,
      required this.title,
      required this.description,
      required this.imageAsset,
      this.optionalWidget})
      : super(key: key);

  final String title;
  final String description;
  final String imageAsset;
  final Widget? optionalWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Image.asset(
              imageAsset,
              fit: BoxFit.fitWidth,
              width: 220.0,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 40.0,
                      overflow: TextOverflow.clip,
                      fontWeight: FontWeight.w300,
                      color: Color(0XFF3F3D56),
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                        color: Colors.grey,
                        letterSpacing: 1.2,
                        fontSize: 16.0,
                        height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                  if (optionalWidget != null) ...[
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: optionalWidget!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
