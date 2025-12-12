// lib/ui/home/home.dart

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/model/song.dart';
import '../../data/service/file_manager.dart';
import '../now_playing/now_playing_page.dart';
import '../now_playing/audio_player_manager.dart';
import '../settings/settings.dart';
import '../settings/theme_manager.dart';
import 'mini_player.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager().themeMode,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Michael Music',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: currentMode,
          home: const MusicHomePage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const Center(child: Text("Discovery")),
    const Center(child: Text("Account")),
    const SettingsTab(),
  ];

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
    await Permission.storage.request();
    await Permission.audio.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.album), label: 'Discovery'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
            tabBuilder: (BuildContext context, int index) {
              return _tabs[index];
            },
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MiniPlayer(),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final list = await FileManager().getSongs();
    setState(() {
      songs = list;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  Widget getBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (songs.isEmpty) {
      return const Center(child: Text("Không có bài hát nào"));
    } else {
      return getListView();
    }
  }

  ListView getListView() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 100),
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  Widget getRow(int index) {
    return _SongItemSection(
      parent: this,
      song: songs[index],
    );
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 200,
            color: Theme.of(context).cardColor,
            child: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ),
          );
        });
  }

  // 🔥 HÀM NAVIGATE CHUẨN HERO (Không hiệu ứng nền)
  void navigate(Song song) {
    int index = songs.indexOf(song);
    AudioPlayerManager().setPlaylist(songs, index);

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600), // Thời gian bay
        reverseTransitionDuration: const Duration(milliseconds: 600),

        pageBuilder: (_, __, ___) => NowPlayingPage(
          songs: songs,
          playingSong: song,
        ),

        // Trả về child trực tiếp => Tắt hiệu ứng Fade/Slide của trang
        transitionsBuilder: (_, __, ___, child) {
          return child;
        },
      ),
    ).then((value) {
      _loadSongs();
    });
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    super.key,
    required this.parent,
    required this.song,
  });

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 24, right: 8),

      // Hero Tag
      leading: Hero(
        tag: song.id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _buildImage(song),
        ),
      ),

      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(CupertinoIcons.headphones, size: 12, color: Colors.grey),
          Text(" ${song.counter}"),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {
          parent.showBottomSheet();
        },
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }

  Widget _buildImage(Song song) {
    if (song.localImagePath != null && song.localImagePath!.isNotEmpty) {
      return Image.file(
        File(song.localImagePath!),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset('assets/itunes_256.png', width: 48, height: 48),
      );
    }

    if (song.image.startsWith("http")) {
      return FadeInImage.assetNetwork(
        placeholder: 'assets/itunes_256.png',
        image: song.image,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        imageErrorBuilder: (_, __, ___) => Image.asset('assets/itunes_256.png', width: 48, height: 48),
      );
    }

    return Image.asset('assets/itunes_256.png', width: 48, height: 48);
  }
}