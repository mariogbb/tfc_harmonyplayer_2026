import 'package:flutter/material.dart';

extension ColorExtension on String {
  Color toColor() {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension DurationExtension on Duration {
  String toStringRepresentation() {
    String out = "";
    var num = 0;
    Duration duration = this;

    if (duration.inHours > 0) {
      out += duration.inHours.toString();
      out += ":";
    }

    num = duration.inMinutes.remainder(60);

    out += (num >= 10) ? "$num:" : "0$num:";

    num = duration.inSeconds.remainder(60);

    out += (num >= 10) ? "$num" : "0$num";

    return out;
  }
}
