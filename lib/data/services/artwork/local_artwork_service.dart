import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:on_audio_query/on_audio_query.dart';

class LocalArtworkService {
  Future<Uint8List> loadAlbumArtwork(int id) async {
    Uint8List? artwork;
    if (!Platform.isLinux && !Platform.isWindows) {
      try {
        artwork = await OnAudioQuery().queryArtwork(
          id,
          ArtworkType.ALBUM,
          format: ArtworkFormat.PNG,
        );
      } catch (error, stack) {
        developer.log(
          'Local artwork unavailable; using placeholder.',
          name: 'artwork',
          error: error,
          stackTrace: stack,
        );
      }
    }
    if (artwork != null) return artwork;
    final placeholder = await rootBundle.load('assets/no_artwork_icon.png');
    return placeholder.buffer.asUint8List(
      placeholder.offsetInBytes,
      placeholder.lengthInBytes,
    );
  }
}
