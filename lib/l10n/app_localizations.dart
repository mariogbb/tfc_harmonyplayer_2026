import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_gl.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('gl'),
    Locale('it'),
  ];

  /// No description provided for @menu_tab.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu_tab;

  /// No description provided for @songs_tab.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs_tab;

  /// No description provided for @albums_tab.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums_tab;

  /// No description provided for @playlist_tab.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlist_tab;

  /// No description provided for @artist_tab.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get artist_tab;

  /// No description provided for @one_song.
  ///
  /// In en, this message translates to:
  /// **'song'**
  String get one_song;

  /// No description provided for @plural_songs.
  ///
  /// In en, this message translates to:
  /// **'songs'**
  String get plural_songs;

  /// No description provided for @liked_songs.
  ///
  /// In en, this message translates to:
  /// **'Liked songs'**
  String get liked_songs;

  /// No description provided for @most_played.
  ///
  /// In en, this message translates to:
  /// **'Most played'**
  String get most_played;

  /// No description provided for @on_repeat.
  ///
  /// In en, this message translates to:
  /// **'On repeat'**
  String get on_repeat;

  /// No description provided for @play_all.
  ///
  /// In en, this message translates to:
  /// **'Play all'**
  String get play_all;

  /// No description provided for @shuffle_play.
  ///
  /// In en, this message translates to:
  /// **'Shuffle play'**
  String get shuffle_play;

  /// No description provided for @now_playing.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get now_playing;

  /// No description provided for @create_playlist.
  ///
  /// In en, this message translates to:
  /// **'Create playlist'**
  String get create_playlist;

  /// No description provided for @add_to_playlist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get add_to_playlist;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @more_from.
  ///
  /// In en, this message translates to:
  /// **'More from'**
  String get more_from;

  /// No description provided for @top_albums.
  ///
  /// In en, this message translates to:
  /// **'Top albums'**
  String get top_albums;

  /// No description provided for @top_songs.
  ///
  /// In en, this message translates to:
  /// **'Top songs'**
  String get top_songs;

  /// No description provided for @track_number_sort.
  ///
  /// In en, this message translates to:
  /// **'Track number'**
  String get track_number_sort;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @albums_plural.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums_plural;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @add_to_queue.
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get add_to_queue;

  /// No description provided for @open_artist.
  ///
  /// In en, this message translates to:
  /// **'Open artist'**
  String get open_artist;

  /// No description provided for @open_album.
  ///
  /// In en, this message translates to:
  /// **'Open album'**
  String get open_album;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @look_and_feel.
  ///
  /// In en, this message translates to:
  /// **'Look and feel'**
  String get look_and_feel;

  /// No description provided for @look_and_feel_desc.
  ///
  /// In en, this message translates to:
  /// **'Look and feel of the app, color, ...'**
  String get look_and_feel_desc;

  /// No description provided for @color_mode.
  ///
  /// In en, this message translates to:
  /// **'Color mode'**
  String get color_mode;

  /// No description provided for @primary_color.
  ///
  /// In en, this message translates to:
  /// **'Primary color'**
  String get primary_color;

  /// No description provided for @song_settings.
  ///
  /// In en, this message translates to:
  /// **'Song settings'**
  String get song_settings;

  /// No description provided for @song_sett_desc.
  ///
  /// In en, this message translates to:
  /// **'Filters, artworks, ...'**
  String get song_sett_desc;

  /// No description provided for @audio_filters.
  ///
  /// In en, this message translates to:
  /// **'Audio filters'**
  String get audio_filters;

  /// No description provided for @audio_filters_desc.
  ///
  /// In en, this message translates to:
  /// **'Filters to avoid loading audios'**
  String get audio_filters_desc;

  /// No description provided for @minimum_song_len.
  ///
  /// In en, this message translates to:
  /// **'Minimum song length (sec)'**
  String get minimum_song_len;

  /// No description provided for @minimum_song_len_desc.
  ///
  /// In en, this message translates to:
  /// **'Filters to avoid loading short audios'**
  String get minimum_song_len_desc;

  /// No description provided for @download_artist_image.
  ///
  /// In en, this message translates to:
  /// **'Download artist image'**
  String get download_artist_image;

  /// No description provided for @download_artist_image_des.
  ///
  /// In en, this message translates to:
  /// **'Allow the download of artist images from internet to display'**
  String get download_artist_image_des;

  /// No description provided for @download_album_image.
  ///
  /// In en, this message translates to:
  /// **'Download album image'**
  String get download_album_image;

  /// No description provided for @download_album_image_des.
  ///
  /// In en, this message translates to:
  /// **'Allow the download of album images from internet to display'**
  String get download_album_image_des;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @about_desc.
  ///
  /// In en, this message translates to:
  /// **'Information about the application'**
  String get about_desc;

  /// No description provided for @social_sett.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social_sett;

  /// No description provided for @publish_on_twitter.
  ///
  /// In en, this message translates to:
  /// **'Publish on twitter'**
  String get publish_on_twitter;

  /// No description provided for @bugs_and_features.
  ///
  /// In en, this message translates to:
  /// **'Bugs and features'**
  String get bugs_and_features;

  /// No description provided for @report_a_bug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get report_a_bug;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @app_version.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get app_version;

  /// No description provided for @changelog.
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelog;

  /// No description provided for @color_scheme.
  ///
  /// In en, this message translates to:
  /// **'Color scheme'**
  String get color_scheme;

  /// No description provided for @accent_color.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accent_color;

  /// No description provided for @color_mode_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get color_mode_system;

  /// No description provided for @color_mode_ligth.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get color_mode_ligth;

  /// No description provided for @color_mode_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get color_mode_dark;

  /// No description provided for @songs_sett.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs_sett;

  /// No description provided for @song_artwork_shape.
  ///
  /// In en, this message translates to:
  /// **'Artwork shape'**
  String get song_artwork_shape;

  /// No description provided for @song_artwork_shape_circle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get song_artwork_shape_circle;

  /// No description provided for @song_artwork_shape_square.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get song_artwork_shape_square;

  /// No description provided for @album_tab_sett.
  ///
  /// In en, this message translates to:
  /// **'Album tab'**
  String get album_tab_sett;

  /// No description provided for @album_artwork_shape.
  ///
  /// In en, this message translates to:
  /// **'Artwork shape'**
  String get album_artwork_shape;

  /// No description provided for @album_artwork_shape_circle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get album_artwork_shape_circle;

  /// No description provided for @album_artwork_shape_square.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get album_artwork_shape_square;

  /// No description provided for @app_bar_sett.
  ///
  /// In en, this message translates to:
  /// **'App bar'**
  String get app_bar_sett;

  /// No description provided for @app_bar_theme.
  ///
  /// In en, this message translates to:
  /// **'App bar theme'**
  String get app_bar_theme;

  /// No description provided for @app_bar_theme_rounded.
  ///
  /// In en, this message translates to:
  /// **'Rounded'**
  String get app_bar_theme_rounded;

  /// No description provided for @app_bar_theme_square.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get app_bar_theme_square;

  /// No description provided for @app_bar_theme_seamless.
  ///
  /// In en, this message translates to:
  /// **'Seamless'**
  String get app_bar_theme_seamless;

  /// No description provided for @tabs.
  ///
  /// In en, this message translates to:
  /// **'Tabs'**
  String get tabs;

  /// No description provided for @show_tab_label.
  ///
  /// In en, this message translates to:
  /// **'Show tabs label'**
  String get show_tab_label;

  /// No description provided for @playing_screen_sett.
  ///
  /// In en, this message translates to:
  /// **'Playing screen'**
  String get playing_screen_sett;

  /// No description provided for @playing_screen_sett_desc.
  ///
  /// In en, this message translates to:
  /// **'Playing screen look and feel and behaviour'**
  String get playing_screen_sett_desc;

  /// No description provided for @playing_screen_artwork_shape.
  ///
  /// In en, this message translates to:
  /// **'Artwork shape'**
  String get playing_screen_artwork_shape;

  /// No description provided for @playing_screen_artwork_shape_circle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get playing_screen_artwork_shape_circle;

  /// No description provided for @playing_screen_artwork_shape_square.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get playing_screen_artwork_shape_square;

  /// No description provided for @backup_sett.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup_sett;

  /// No description provided for @backup_sett_desc.
  ///
  /// In en, this message translates to:
  /// **'Export or import playlist and settings'**
  String get backup_sett_desc;

  /// No description provided for @behaviour_sett.
  ///
  /// In en, this message translates to:
  /// **'Behaviour'**
  String get behaviour_sett;

  /// No description provided for @behaviour_sett_desc.
  ///
  /// In en, this message translates to:
  /// **'Settings about how the player works'**
  String get behaviour_sett_desc;

  /// No description provided for @app_sett.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get app_sett;

  /// No description provided for @app_sett_desc.
  ///
  /// In en, this message translates to:
  /// **'Language, screen size, data usage, ...'**
  String get app_sett_desc;

  /// No description provided for @general_settings.
  ///
  /// In en, this message translates to:
  /// **'General settings'**
  String get general_settings;

  /// No description provided for @language_sett.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get language_sett;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @smart_filter_sett.
  ///
  /// In en, this message translates to:
  /// **'Smart song filter'**
  String get smart_filter_sett;

  /// No description provided for @smart_filter_sett_desc.
  ///
  /// In en, this message translates to:
  /// **'Filter to avoid loading audios from other apps'**
  String get smart_filter_sett_desc;

  /// No description provided for @minimum_song_lenght_sett.
  ///
  /// In en, this message translates to:
  /// **'Song duration filter'**
  String get minimum_song_lenght_sett;

  /// No description provided for @minimum_song_lenght_sett_desc.
  ///
  /// In en, this message translates to:
  /// **'Minimum duration to load songs'**
  String get minimum_song_lenght_sett_desc;

  /// No description provided for @wellcome_user.
  ///
  /// In en, this message translates to:
  /// **'Wellcome'**
  String get wellcome_user;

  /// No description provided for @default_user_name.
  ///
  /// In en, this message translates to:
  /// **'user'**
  String get default_user_name;

  /// No description provided for @change_user_name.
  ///
  /// In en, this message translates to:
  /// **'Change user name'**
  String get change_user_name;

  /// No description provided for @new_user_name.
  ///
  /// In en, this message translates to:
  /// **'New user name'**
  String get new_user_name;

  /// No description provided for @field_cannot_empty.
  ///
  /// In en, this message translates to:
  /// **'Field can\'t be empty'**
  String get field_cannot_empty;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @playing_from_album.
  ///
  /// In en, this message translates to:
  /// **'Playing album'**
  String get playing_from_album;

  /// No description provided for @playing_from_song.
  ///
  /// In en, this message translates to:
  /// **'Playing song'**
  String get playing_from_song;

  /// No description provided for @playing_from_playlist.
  ///
  /// In en, this message translates to:
  /// **'Playing playlist'**
  String get playing_from_playlist;

  /// No description provided for @playing_from_artist.
  ///
  /// In en, this message translates to:
  /// **'Playing artist'**
  String get playing_from_artist;

  /// No description provided for @playing_from_all_songs.
  ///
  /// In en, this message translates to:
  /// **'Playng from'**
  String get playing_from_all_songs;

  /// No description provided for @playing_from_top_songs.
  ///
  /// In en, this message translates to:
  /// **'Playing from'**
  String get playing_from_top_songs;

  /// No description provided for @playing_from_top_albums.
  ///
  /// In en, this message translates to:
  /// **'Playing from'**
  String get playing_from_top_albums;

  /// No description provided for @all_songs.
  ///
  /// In en, this message translates to:
  /// **'All songs'**
  String get all_songs;

  /// No description provided for @top_played_songs.
  ///
  /// In en, this message translates to:
  /// **'Top played songs'**
  String get top_played_songs;

  /// No description provided for @no_album_found.
  ///
  /// In en, this message translates to:
  /// **'No album found'**
  String get no_album_found;

  /// No description provided for @no_song_found.
  ///
  /// In en, this message translates to:
  /// **'No song found'**
  String get no_song_found;

  /// No description provided for @no_artist_found.
  ///
  /// In en, this message translates to:
  /// **'No artist found'**
  String get no_artist_found;

  /// No description provided for @no_playlist_found.
  ///
  /// In en, this message translates to:
  /// **'No playlist found'**
  String get no_playlist_found;

  /// No description provided for @reload_songs.
  ///
  /// In en, this message translates to:
  /// **'Reload songs'**
  String get reload_songs;

  /// No description provided for @new_name.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get new_name;

  /// No description provided for @delete_playlist.
  ///
  /// In en, this message translates to:
  /// **'Delete playlist'**
  String get delete_playlist;

  /// No description provided for @rename_playlist.
  ///
  /// In en, this message translates to:
  /// **'Rename playlist'**
  String get rename_playlist;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @sort_by.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sort_by;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @nothing_found.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothing_found;

  /// No description provided for @pick_a_color.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get pick_a_color;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'gl', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'gl':
      return AppLocalizationsGl();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
