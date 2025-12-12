// lib/ui/settings/settings.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để dùng TextInputFormatter
import '../now_playing/audio_player_manager.dart';
import 'theme_manager.dart'; // 🔥 Import ThemeManager

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  // ❌ XÓA BIẾN NÀY ĐI: bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- MỤC GIAO DIỆN ---
            // 🔥 BỌC VÀO ValueListenableBuilder ĐỂ LẮNG NGHE THEME THẬT
            ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeManager().themeMode,
              builder: (context, mode, child) {
                // Kiểm tra xem chế độ hiện tại có phải Dark không
                // (Nếu là system thì tùy máy, ở đây ta check đơn giản là == dark)
                // Hoặc bạn có thể check: mode == ThemeMode.dark
                bool isSwitchedOn = mode == ThemeMode.dark;

                return ListTile(
                  leading: const Icon(Icons.dark_mode, color: Colors.amber),
                  title: const Text("Giao diện Tối (Dark Mode)"),
                  trailing: Switch(
                    value: isSwitchedOn,
                    activeColor: Colors.deepPurpleAccent,
                    onChanged: (value) {
                      // 🔥 GỌI MANAGER ĐỂ ĐỔI THEME TOÀN APP
                      ThemeManager().toggleTheme(value);
                    },
                  ),
                );
              },
            ),

            const Divider(),

            // --- MỤC HẸN GIỜ ---
            ValueListenableBuilder<bool>(
              valueListenable: AudioPlayerManager().isSleepTimerActive,
              builder: (context, isActive, child) {
                return ListTile(
                  leading: Icon(
                      Icons.timer,
                      color: isActive ? Colors.deepPurpleAccent : Colors.grey
                  ),
                  title: Text(
                    isActive ? "Đang hẹn giờ tắt nhạc..." : "Hẹn giờ tắt nhạc",
                    style: TextStyle(
                      color: isActive ? Colors.deepPurpleAccent : null,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: isActive
                      ? const Text("Nhấn để hủy hoặc thay đổi")
                      : const Text("Tự động tắt nhạc sau một khoảng thời gian"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showSleepTimerModal(context);
                  },
                );
              },
            ),

            const Divider(),

            // --- MỤC PHIÊN BẢN ---
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("Phiên bản"),
              trailing: Text(
                "1.0.0 (Mai Cồ Edition)",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Các hàm _showSleepTimerModal, _showCustomTimerDialog, _buildTimerOption giữ nguyên)
  // Hàm hiện menu chọn giờ
  void _showSleepTimerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Hẹn giờ tắt nhạc",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildTimerOption(context, 15, "15 phút"),
              _buildTimerOption(context, 30, "30 phút"),
              _buildTimerOption(context, 60, "60 phút (1 tiếng)"),
              _buildTimerOption(context, 120, "120 phút (2 tiếng)"),

              // --- TÙY CHỌN TÙY CHỈNH ---
              ListTile(
                leading: const Icon(Icons.edit_calendar),
                title: const Text("Tùy chỉnh thời gian..."),
                trailing: const Icon(Icons.navigate_next),
                onTap: () {
                  Navigator.pop(context); // Đóng menu cũ
                  _showCustomTimerDialog(context); // Mở dialog nhập
                },
              ),

              const Divider(),

              // Nút tắt hẹn giờ
              ListTile(
                leading: const Icon(Icons.stop_circle_outlined, color: Colors.red),
                title: const Text("Tắt hẹn giờ", style: TextStyle(color: Colors.red)),
                onTap: () {
                  AudioPlayerManager().cancelSleepTimer();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã hủy hẹn giờ! ❌")),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Dialog nhập thời gian tùy chỉnh
  void _showCustomTimerDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nhập số phút"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            // Chỉ cho nhập số
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: "Ví dụ: 5",
              suffixText: "phút",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text;
                if (text.isNotEmpty) {
                  final minutes = int.tryParse(text);
                  if (minutes != null && minutes > 0) {
                    // Gọi hàm hẹn giờ
                    AudioPlayerManager().setSleepTimer(minutes);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Nhạc sẽ tắt sau $minutes phút ⏱️")),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text("Bắt đầu", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Widget con cho từng lựa chọn nhanh
  Widget _buildTimerOption(BuildContext context, int minutes, String title) {
    return ListTile(
      leading: const Icon(Icons.access_time),
      title: Text(title),
      onTap: () {
        AudioPlayerManager().setSleepTimer(minutes);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Nhạc sẽ tắt sau $title nữa 💤"),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}