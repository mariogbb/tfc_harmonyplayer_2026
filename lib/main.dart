import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:player/data/settings.dart';
import 'package:player/dialogs/google_cast_dialogs.dart';
import 'package:player/layout/adaptive_layout.dart';
import 'package:player/control/control_tab.dart';
import 'package:player/data/data.dart';
import 'package:player/data/dao.dart';
import 'package:player/screens/playlist/single_playlist_screen.dart';
import 'package:player/screens/rankings/top_played_albums.dart';
import 'package:player/screens/rankings/top_played_songs.dart';
import 'package:player/screens/settings/settings_screen.dart';
import 'package:player/screens/welcome_screen/welcome_screen.dart';
import 'package:player/tabs/albums/albums_tab.dart';
import 'package:player/tabs/artists/artists_tab.dart';
import 'package:player/tabs/menu/menu_tab.dart';
import 'package:player/screens/album_screen.dart';
import 'package:player/screens/artist_screen.dart';
import 'package:player/screens/search_overlay.dart';
import 'package:player/tabs/playlists/playlists_tab.dart';
import 'package:player/tabs/songs/songs_tab.dart';
import 'package:player/tabs/tab_bar.dart';
import 'package:player/theme_data/dark_theme.dart';
import 'package:player/theme_data/light_theme.dart';
import 'package:player/theme_data/theme_provider.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/widgets/control_padding.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool showInitScreen = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isLinux && !Platform.isWindows) {
    await Firebase.initializeApp();

    // "Fatal" errors log on firebase
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Async platform errors log on firebase
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.signInAnonymously();
    } on FirebaseAuthException catch (_) {}

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await remoteConfig.setDefaults({"cast_enabled": false});

      remoteConfig.onConfigUpdated.listen((event) async {
        await remoteConfig.activate();
      });

      await remoteConfig.fetchAndActivate();
    } on FirebaseException catch (_) {}
  }

  PlayerData playerData = PlayerData();
  PlayerDatabase database = PlayerDatabase();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  await Settings.init();
  Settings.ensureCacheProvider();

  int? initScreen = prefs.getInt("initScreen");

  if (initScreen == null) {
    prefs.setInt("initScreen", 1);
    // PlayerSettings.instance.setDefaultValues();

    showInitScreen = true;
  }

  await database.initState();
  await playerData.initHandler();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PlayerData(),
        ),
        ChangeNotifierProvider(
          create: (context) => PlayerData.instance.handler,
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PlayerSettings(),
        )
      ],
      child: Consumer2<ThemeProvider, PlayerSettings>(
        child: MyHomePage(),
        builder: (context, themeValue, settingsValue, child) {
          return MaterialApp(
            themeMode: themeValue.selectedThemeMode,
            theme: LightTheme.getTheme(themeValue.selectedPrimaryColor),
            darkTheme: DarkTheme.getTheme(themeValue.selectedPrimaryColor),
            debugShowCheckedModeBanner: false,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            locale: settingsValue.getAppLocale,
            title: 'Harmony Player',
            color: themeValue.selectedPrimaryColor,
            home: child,
            routes: {
              'search': ((context) => const SearchOverlayTab()),
              'album': ((context) => const AlbumScreen()),
              'artist': (context) => const ArtistScreen(),
              'playlist': ((context) => const SinglePlaylistScreen()),
              'settings': ((context) => const AppSettingsScreen()),
              'top_played_albums': ((context) => const TopAlbumsRanking()),
              'top_played_songs': (context) => const TopSongsRanking()
            },
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  final PlayerData playerData = PlayerData.instance;
  final PlayerDatabase database = PlayerDatabase.instance;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with
        WidgetsBindingObserver,
        AdaptiveElement<MyHomePage>,
        TickerProviderStateMixin {
  int selectedIndex = 0;
  bool showTab = true;
  late TabController _tabController;
  late AnimationController _animationController;

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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1,
    );

    _tabController = TabController(
      length: appTabs.length,
      vsync: this,
      initialIndex: 0,
    )..addListener(() {
        if (_tabController.indexIsChanging) {
          setState(() {
            selectedIndex = _tabController.index;
            _animationController.forward(from: 0.25);
          });
        }
      });

    requestPermissions();
  }

  void requestPermissions() async {
    if (Platform.isLinux || Platform.isWindows) {
      widget.playerData.initState();
      return;
    }
    List<Permission> req = [];

    var state = await Permission.storage.status;

    if (state.isDenied) {
      req.add(Permission.storage);
    }

    state = await Permission.manageExternalStorage.status;

    if (state.isDenied) {
      req.add(Permission.manageExternalStorage);
    }

    if (req.isNotEmpty) {
      await req.request();

      state = await Permission.storage.status;

      if (state.isGranted) {
        widget.playerData.initState();
      }
    } else {
      widget.playerData.initState();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.playerData.handler.player.dispose();
    widget.playerData.handler.stop();
    widget.database.database.close();
    PlayerData.instance.handler.dispose();
    PlayerData.instance.dispose();
    _tabController.dispose();
    _animationController.dispose();
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
    Tab(
      icon: Icon(Icons.person),
    ),
    Tab(
      icon: Icon(Icons.music_note),
    ),
    Tab(
      icon: Icon(Icons.album),
    ),
    Tab(
      icon: Icon(Icons.my_library_music),
    ),
    Tab(
      icon: Icon(Icons.view_list),
    ),
  ];

  final List<Widget> tabWidgets = [
    const PlayerMenuTab(),
    const PlayerSongsTab(),
    const PlayerAlbumTab(),
    const PlayerArtistTab(),
    const PlaylistTab(),
  ];

  @override
  Widget buildLarge(BuildContext context) {
    List<Tab> totalTabs = appTabsText(context);

    return (showInitScreen)
        ? WelcomeScreen(onWellcomeClose: onWellcomeClose)
        : DefaultTabController(
            length: appTabs.length,
            initialIndex: 0,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                top: true,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(
                        milliseconds: 500,
                      ),
                      child: (showTab)
                          ? Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Material(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withAlpha(50),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: totalTabs.map(
                                        (element) {
                                          return GestureDetector(
                                            onTap: () =>
                                                _tabController.animateTo(
                                                    totalTabs.indexOf(element)),
                                            child: DecoratedBox(
                                              decoration: (_tabController
                                                          .index ==
                                                      totalTabs
                                                          .indexOf(element))
                                                  ? BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      color: Theme.of(context)
                                                          .focusColor,
                                                    )
                                                  : const BoxDecoration(),
                                              child: SizedBox(
                                                width: 50,
                                                child: IconTheme(
                                                  data: Theme.of(context)
                                                      .iconTheme
                                                      .copyWith(
                                                        color: (_tabController
                                                                    .index ==
                                                                totalTabs
                                                                    .indexOf(
                                                                        element))
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : null,
                                                      ),
                                                  child: Tab(
                                                    iconMargin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    icon: element.icon,
                                                    height: 60,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(
                              key: Key("invisible_box"),
                            ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Scaffold(
                        resizeToAvoidBottomInset: false,
                        appBar: _appBar(context),
                        body: ScaleTransition(
                          scale: _animationController,
                          child: tabWidgets[_tabController.index],
                        ),
                        bottomSheet: PlayerControlTab(
                          onEvent: (opened) {
                            setState(() {
                              showTab = !opened;
                            });
                          },
                        ),
                        extendBodyBehindAppBar: true,
                        extendBody: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text(tabNames(context)[selectedIndex]),
      leading: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          Navigator.of(context).pushNamed("search");
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
          )
        ],
        PopupMenuButton<int>(
          icon: const Icon(
            Icons.settings,
          ),
          onSelected: (value) {
            if (value == 1) {
              Navigator.of(context).pushNamed("settings");
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                onTap: () => PlayerData.instance.initState(),
                value: 0,
                child: ListTile(
                  leading: Icon(
                    Icons.replay_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(AppLocalizations.of(context)!.reload_songs),
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(AppLocalizations.of(context)!.settings),
                ),
              )
            ];
          },
        ),
      ],
    );
  }

  void onWellcomeClose() {
    setState(() {
      showInitScreen = false;
    });
  }

  @override
  Widget buildNormal(BuildContext context) {
    return (showInitScreen)
        ? WelcomeScreen(
            onWellcomeClose: onWellcomeClose,
          )
        : DefaultTabController(
            length: appTabs.length,
            initialIndex: 0,
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: _appBar(context),
                body: ControlPadding(
                  child: ScaleTransition(
                    scale: _animationController,
                    child: tabWidgets[_tabController.index],
                  ),
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
                      duration: const Duration(milliseconds: 500),
                      child: (showTab)
                          ? AppTabBar(
                              controller: _tabController,
                              tabs: (value.isShowTabLabel)
                                  ? appTabsText(context)
                                  : appTabs,
                            )
                          : const SizedBox.shrink(
                              key: Key("invisible_box"),
                            ),
                    );
                  },
                ),
              ),
            ),
          );
  }
}
