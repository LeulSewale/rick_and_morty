import 'package:meta/meta.dart';

@immutable
class Episode {
  final String id;
  final String name;
  final String episode;
  final String airDate;

  const Episode({
    required this.id,
    required this.name,
    required this.episode,
    required this.airDate,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as String,
      name: json['name'] as String,
      episode: json['episode'] as String,
      airDate: json['air_date'] as String,
    );
  }
} 