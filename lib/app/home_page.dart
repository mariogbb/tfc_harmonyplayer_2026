import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:player/data/settings.dart';
import 'package:player/ui/playback/google_cast_dialogs.dart';
import 'package:player/ui/core/adaptive_layout.dart';
import 'package:player/ui/playback/control_tab.dart';
import 'package:player/data/data.dart';
import 'package:player/data/dao.dart';
import 'package:player/ui/welcome/welcome_screen.dart';
import 'package:player/ui/library/albums/albums_tab.dart';
import 'package:player/ui/library/artists/artists_tab.dart';
import 'package:player/ui/home/menu_tab.dart';
import 'package:player/ui/playlists/playlists_tab.dart';
import 'package:player/ui/library/songs/songs_tab.dart';
import 'package:player/ui/core/app_tab_bar.dart';
import 'package:player/l10n/app_localizations.dart';
import 'package:player/ui/core/control_padding.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.showWelcome}) : super(key: key);
  final bool showWelcome;
  final PlayerData playerData = PlayerData.instance;
  final PlayerDatabase database = PlayerDatabase.instance;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with
        WidgetsBindingObserver,
        AdaptiveElement<HomePage>,
        TickerProviderStateMixin {
  int selectedIndex = 0;
  late bool showInitScreen;
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
    showInitScreen = widget.showWelcome;
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1,
    );

    _tabController =
        TabController(length: appTabs.length, vsync: this, initialIndex: 0)
          ..addListener(() {
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
    try {
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
      if (!mounted) return;

      if (state.isDenied) {
        req.add(Permission.manageExternalStorage);
      }

      if (req.isNotEmpty) {
        await req.request();

        state = await Permission.storage.status;
        if (!mounted) return;

        if (state.isGranted) {
          widget.playerData.initState();
        } else {
          widget.playerData.libraryController.permissionDenied();
        }
      } else {
        widget.playerData.initState();
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
                      duration: const Duration(milliseconds: 500),
                      child: (showTab)
                          ? Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Material(
                                    color: Theme.of(context).primaryColor
                                        .withAlpha(50),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: totalTabs.map((element) {
                                        return GestureDetector(
                                          onTap: () => _tabController.animateTo(
                                            totalTabs.indexOf(element),
                                          ),
                                          child: DecoratedBox(
                                            decoration:
                                                (_tabController.index ==
                                                    totalTabs.indexOf(element))
                                                ? BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
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
                                                      color:
                                                          (_tabController
                                                                  .index ==
                                                              totalTabs.indexOf(
                                                                element,
                                                              ))
                                                          ? Theme.of(context)
                                                                .primaryColor
                                                          : null,
                                                    ),
                                                child: Tab(
                                                  iconMargin:
                                                      const EdgeInsets.all(10),
                                                  icon: element.icon,
                                                  height: 60,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(key: Key("invisible_box")),
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
          ),
        ],
        PopupMenuButton<int>(
          icon: const Icon(Icons.settings),
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
              ),
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
        ? WelcomeScreen(onWellcomeClose: onWellcomeClose)
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
                          : const SizedBox.shrink(key: Key("invisible_box")),
                    );
                  },
                ),
              ),
            ),
          );
  }
}
