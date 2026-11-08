import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:player/data/services/artwork/fallback_artwork.dart';
import 'package:player/data/services/artwork/local_artwork_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'missing local artwork uses a valid image without loading an asset',
    () async {
      final bytes = await LocalArtworkService().loadAlbumArtwork(1);
      expect(bytes, same(fallbackArtwork));
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 48);
      expect(frame.image.height, 48);
      frame.image.dispose();
      codec.dispose();
    },
  );
}
