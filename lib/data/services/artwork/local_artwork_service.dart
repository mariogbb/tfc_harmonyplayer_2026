import 'dart:io';

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
      } catch (_) {
        // Use the bundled placeholder if the platform cannot provide artwork.
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
