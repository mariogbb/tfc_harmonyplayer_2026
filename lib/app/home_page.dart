import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:player/data/services/music_library/music_permissions.dart';
import 'package:player/data/settings.dart';
import 'package:player/ui/playback/google_cast_dialogs.dart';
import 'package:player/ui/playback/control_tab.dart';
import 'package:player/data/data.dart';
import 'package:player/ui/library/albums/albums_tab.dart';
import 'package:player/ui/library/artists/artists_tab.dart';
import 'package:player/ui/home/menu_tab.dart';
import 'package:player/ui/playlists/playlists_tab.dart';
import 'package:player/ui/library/songs/songs_tab.dart';
import 'package:player/ui/core/app_tab_bar.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/core/control_padding.dart';
import 'package:provider/provider.dart';
import 'package:player/ui/core/tab_content.dart';
import 'package:player/ui/core/desktop_navigation.dart';
import 'package:player/ui/core/harmony_mark.dart';
import 'package:player/ui/core/desktop_content_scope.dart';
import 'package:player/ui/playback/desktop_player_panel.dart';
import 'package:player/ui/library/albums/album_screen.dart';
import 'package:player/ui/library/artists/artist_screen.dart';
import 'package:player/ui/playlists/single_playlist_screen.dart';
import 'package:player/ui/rankings/top_played_albums.dart';
import 'package:player/ui/rankings/top_played_songs.dart';
import 'package:player/ui/search/search_overlay.dart';
import 'package:player/ui/settings/settings_screen.dart';
import 'package:player/model/album.dart';
import 'package:player/model/artist.dart';
import 'package:player/model/playlist.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  final PlayerData playerData = PlayerData.instance;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  int selectedIndex = 0;
  bool showTab = true;
  late TabController _tabController;
  final _desktopNavigatorKey = GlobalKey<NavigatorState>();
  final _desktopRouteSettings = ValueNotifier<RouteSettings?>(null);
  late final _desktopObserver = _DesktopRouteObserver(_desktopRouteSettings);

  List<String> appBarTitles = [];

  void changeContent(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabController =
        TabController(
          length: appTabs.length,
          vsync: this,
          initialIndex: 0,
          animationDuration: const Duration(milliseconds: 160),
        )..addListener(() {
          if (_tabController.index != selectedIndex) {
            setState(() {
              selectedIndex = _tabController.index;
            });
          }
        });

    requestPermissions();
  }

  void requestPermissions() async {
    try {
      final granted = await MusicPermissions().request();
      if (!mounted) return;
      if (granted) {
        widget.playerData.refreshCoordinator.refresh();
      } else {
        widget.playerData.libraryController.permissionDenied();
      }
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'music permissions',
        ),
      );
      if (mounted) widget.playerData.libraryController.reportFailure(error);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _desktopRouteSettings.dispose();
    super.dispose();
  }

  List<String> tabNames(BuildContext context) {
    return [
      "Harmony",
      AppLocalizations.of(context)!.songs_tab,
      AppLocalizations.of(context)!.albums_tab,
      AppLocalizations.of(context)!.artist_tab,
      AppLocalizations.of(context)!.playlists,
    ];
  }

  List<Tab> appTabsText(BuildContext context) {
    return [
      Tab(
        text: AppLocalizations.of(context)!.menu_tab,
        icon: const Icon(Icons.person),
      ),
      Tab(
        text: AppLocalizations.of(context)!.songs_tab,
        icon: const Icon(Icons.music_note),
      ),
      Tab(
        text: AppLocalizations.of(context)!.albums_tab,
        icon: const Icon(Icons.album),
      ),
      Tab(
        text: AppLocalizations.of(context)!.artist_tab,
        icon: const Icon(Icons.my_library_music),
      ),
      Tab(
        text: AppLocalizations.of(context)!.playlists,
        icon: const Icon(Icons.view_list),
      ),
    ];
  }

  final List<Tab> appTabs = const [
    Tab(icon: Icon(Icons.person)),
    Tab(icon: Icon(Icons.music_note)),
    Tab(icon: Icon(Icons.album)),
    Tab(icon: Icon(Icons.my_library_music)),
    Tab(icon: Icon(Icons.view_list)),
  ];

  final List<Widget> tabWidgets = [
    const PlayerMenuTab(),
    const PlayerSongsTab(),
    const PlayerAlbumTab(),
    const PlayerArtistTab(),
    const PlaylistTab(),
  ];

  Widget buildLarge(BuildContext context) {
    List<Tab> totalTabs = appTabsText(context);

    return DefaultTabController(
      length: appTabs.length,
      initialIndex: 0,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          top: true,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              DesktopNavigation(
                tabs: totalTabs,
                selectedIndex: selectedIndex,
                expanded: MediaQuery.sizeOf(context).width >= 1100,
                onSelected: (index) {
                  _desktopNavigatorKey.currentState?.popUntil(
                    (route) => route.isFirst,
                  );
                  _tabController.animateTo(index);
                },
              ),
              Expanded(
                flex: 9,
                child: ValueListenableBuilder<RouteSettings?>(
                  valueListenable: _desktopRouteSettings,
                  builder: (context, route, _) => Scaffold(
                    resizeToAvoidBottomInset: false,
                    appBar: _appBar(context, desktopRoute: route),
                    body: DesktopContentScope(
                      child: NavigatorPopHandler(
                        onPopWithResult: (result) =>
                            _desktopNavigatorKey.currentState?.pop(result),
                        child: Navigator(
                          key: _desktopNavigatorKey,
                          observers: [_desktopObserver],
                          onGenerateRoute: _desktopRoute,
                        ),
                      ),
                    ),
                    extendBody: false,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width >= 1200 ? 320 : 280,
                child: DesktopPlayerPanel(
                  onAlbum: (album) => _desktopNavigatorKey.currentState
                      ?.pushNamed('album', arguments: album),
                  onArtist: (artist) => _desktopNavigatorKey.currentState
                      ?.pushNamed('artist', arguments: artist),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Route<dynamic>? _desktopRoute(RouteSettings settings) {
    final Widget page;
    switch (settings.name) {
      case Navigator.defaultRouteName:
        page = AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) => Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: TabContent(
                index: _tabController.index,
                children: tabWidgets,
              ),
            ),
          ),
        );
      case 'album':
        page = const AlbumScreen();
      case 'artist':
        page = const ArtistScreen();
      case 'playlist':
        page = const SinglePlaylistScreen();
      case 'top_played_albums':
        page = const TopAlbumsRanking();
      case 'top_played_songs':
        page = const TopSongsRanking();
      case 'search':
        page = const SearchOverlayTab();
      case 'settings':
        page = const AppSettingsScreen();
      default:
        return null;
    }
    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }

  String _desktopTitle(BuildContext context, RouteSettings route) {
    final labels = AppLocalizations.of(context)!;
    final argument = route.arguments;
    return switch (route.name) {
      'album' when argument is AlbumData => argument.name,
      'artist' when argument is ArtistData => argument.name,
      'playlist' when argument is PlaylistData => argument.name,
      'search' => labels.search,
      'top_played_albums' => labels.top_albums,
      'top_played_songs' => labels.top_songs,
      'settings' => labels.settings,
      'settings/appearance' => labels.look_and_feel,
      'settings/songs' => labels.song_settings,
      'settings/general' => labels.app_sett,
      'settings/about' => labels.about,
      _ => tabNames(context)[selectedIndex],
    };
  }

  AppBar _appBar(BuildContext context, {RouteSettings? desktopRoute}) {
    return AppBar(
      title: desktopRoute == null && selectedIndex == 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const HarmonyMark(size: 30),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    tabNames(context)[selectedIndex],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          : Text(
              desktopRoute == null
                  ? tabNames(context)[selectedIndex]
                  : _desktopTitle(context, desktopRoute),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      leading: IconButton(
        icon: Icon(desktopRoute == null ? Icons.search : Icons.arrow_back),
        onPressed: () {
          if (desktopRoute != null) {
            _desktopNavigatorKey.currentState?.maybePop();
          } else {
            (_desktopNavigatorKey.currentState ?? Navigator.of(context))
                .pushNamed('search');
          }
        },
      ),
      actions: [
        if (Platform.isAndroid &&
            FirebaseRemoteConfig.instance.getBool("cast_enabled")) ...[
          IconButton(
            onPressed: () {
              GoogleCastDialogs.listAvaliableCasts(context);
            },
            icon: const Icon(Icons.cast),
          ),
        ],
        IconButton(
          tooltip: AppLocalizations.of(context)!.settings,
          icon: const Icon(Icons.settings),
          onPressed: () =>
              (_desktopNavigatorKey.currentState ?? Navigator.of(context))
                  .pushNamed('settings'),
        ),
      ],
    );
  }

  Widget buildNormal(BuildContext context) {
    return DefaultTabController(
      length: appTabs.length,
      initialIndex: 0,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: _appBar(context),
          body: ControlPadding(
            child: TabContent(index: selectedIndex, children: tabWidgets),
          ),
          bottomSheet: PlayerControlTab(
            onEvent: (opened) {
              setState(() {
                showTab = !opened;
              });
            },
          ),
          extendBodyBehindAppBar: true,
          bottomNavigationBar: Consumer<PlayerSettings>(
            builder: (context, value, child) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: (showTab)
                    ? AppTabBar(
                        controller: _tabController,
                        tabs: (value.isShowTabLabel)
                            ? appTabsText(context)
                            : appTabs,
                      )
                    : const SizedBox.shrink(key: Key("invisible_box")),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 900
        ? buildLarge(context)
        : buildNormal(context),
  );
}

class _DesktopRouteObserver extends NavigatorObserver {
  _DesktopRouteObserver(this.current);
  final ValueNotifier<RouteSettings?> current;
  void _set(Route<dynamic>? route) =>
      current.value = route == null || route.isFirst ? null : route.settings;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(route);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(previousRoute);
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (identical(current.value, route.settings)) _set(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _set(newRoute);
}
