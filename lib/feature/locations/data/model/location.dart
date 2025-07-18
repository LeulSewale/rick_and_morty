import 'package:meta/meta.dart';

@immutable
class Location {
  final String id;
  final String name;
  final String type;
  final String dimension;

  const Location({
    required this.id,
    required this.name,
    required this.type,
    required this.dimension,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      dimension: json['dimension'] as String,
    );
  }
} 