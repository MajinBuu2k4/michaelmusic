// lib/ui/home/home.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/service/file_manager.dart'; // Giữ lại để init data nếu cần
import '../settings/settings.dart';
import '../settings/theme_manager.dart';
import 'mini_player.dart';
import 'tab_download.dart'; // Import tab download đã tách
import 'song_list_view.dart'; // Import list view dùng chung

// =============================================================================
// MÀN HÌNH CHÍNH (CONTAINER)
// =============================================================================
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
    const DownloadTab(), // Tab đã tách file
    const Center(child: Text("Account")),
    const SettingsTab(),
  ];

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await [
      Permission.notification,
      Permission.storage,
      Permission.audio,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 TÍNH TOÁN KHOẢNG CÁCH ĐÁY 🔥
    // 50 (Chiều cao TabBar) + Safe Area Bottom (Thanh vuốt điều hướng)
    final double bottomPadding = 50 + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Lớp dưới cùng: TabBar và Nội dung trang
          CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              backgroundColor: Theme.of(context).colorScheme.surface, // Màu nền tab bar
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5)),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.offline_pin_rounded), label: 'Download'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
            tabBuilder: (BuildContext context, int index) {
              return _tabs[index];
            },
          ),

          // 2. Lớp trên cùng: MiniPlayer
          // 🔥 Dùng Positioned để đẩy Player lên trên TabBar
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding, // Cách đáy một khoảng bằng chiều cao TabBar
            child: const MiniPlayer(),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 1: HOME (HIỂN THỊ TẤT CẢ)
// =============================================================================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<dynamic> songs = []; // Dùng dynamic hoặc Song model tùy import
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    // Gọi hàm load từ FileManager
    final list = await FileManager().getSongs();
    if (mounted) {
      setState(() {
        songs = list;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tái sử dụng SongListView
    // Lưu ý: SongListView cần được import từ file song_list_view.dart
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SongListView(
        songs: songs.cast(), // Ép kiểu về List<Song> nếu cần
        onRefresh: _loadSongs,
      ),
    );
  }
}