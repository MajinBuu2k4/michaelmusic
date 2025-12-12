import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../data/model/song.dart';

class MediaInfo extends StatelessWidget {
  final Song song;
  final VoidCallback onToggleFavorite;

  const MediaInfo({
    super.key,
    required this.song,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onToggleFavorite,
          icon: Icon(
            song.favorite == "true"
                ? Icons.favorite
                : Icons.favorite_border,
            color: song.favorite == "true" ? Colors.red : Colors.grey,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                song.title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                song.artist,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.headphones,
                        size: 14, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text(
                      "${song.counter} lượt nghe",
                      style: const TextStyle(
                          fontSize: 12, color: Colors.blueGrey),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.share_outlined),
        ),
      ],
    );
  }
}