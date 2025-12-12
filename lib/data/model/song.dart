// lib/data/model/song.dart

class Song {
  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.source,
    required this.image,
    required this.duration,
    this.favorite = "false",
    this.counter = 0,
    this.replay = 0,
    this.localAudioPath,
    this.localImagePath,
  });

  String id;
  String title;
  String album;
  String artist;
  String source;
  String image;
  int duration;
  String favorite;
  int counter;
  int replay;
  String? localAudioPath; // Đường dẫn nhạc trong máy
  String? localImagePath; // Đường dẫn ảnh trong máy

  // Đọc từ JSON (Phải đọc đủ!)
  factory Song.fromJson(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      title: map['title'],
      album: map['album'],
      artist: map['artist'],
      source: map['source'],
      image: map['image'],
      duration: map['duration'],
      favorite: map['favorite'] ?? "false",
      counter: map['counter'] ?? 0,
      replay: map['replay'] ?? 0,
      localAudioPath: map['localAudioPath'], // <--- QUAN TRỌNG
      localImagePath: map['localImagePath'], // <--- QUAN TRỌNG
    );
  }

  // Ghi ra JSON (Phải ghi đủ!)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'album': album,
      'artist': artist,
      'source': source,
      'image': image,
      'duration': duration,
      'favorite': favorite,
      'counter': counter,
      'replay': replay,
      'localAudioPath': localAudioPath,
      'localImagePath': localImagePath,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}