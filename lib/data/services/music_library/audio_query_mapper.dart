import 'package:on_audio_query/on_audio_query.dart';
import 'package:player/model/library_metadata.dart';

SongMetadata mapSongMetadata(SongModel song) => SongMetadata(
  id: song.id,
  data: song.data,
  title: song.title,
  uri: song.uri,
  artist: song.artist,
  artistId: song.artistId,
  album: song.album,
  albumId: song.albumId,
  duration: song.duration,
  track: song.track,
);

AlbumMetadata mapAlbumMetadata(AlbumModel album) => AlbumMetadata(
  id: album.id,
  album: album.album,
  artist: album.artist,
  artistId: album.artistId,
);

ArtistMetadata mapArtistMetadata(ArtistModel artist) =>
    ArtistMetadata(id: artist.id, artist: artist.artist);
