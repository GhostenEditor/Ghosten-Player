import 'package:api/api.dart';

class ImdbUri {
  static const domain = 'https://www.themoviedb.org';
  final MediaType type;
  final String id;
  final int? season;
  final int? episode;

  const ImdbUri(this.type, this.id, {this.season, this.episode});

  Uri toUri() {
    return Uri.parse(switch (type) {
      MediaType.movie => '$domain/movie/$id',
      MediaType.series => '$domain/tv/$id',
      MediaType.season => '$domain/tv/$id/season/$season',
      MediaType.episode => '$domain/tv/$id/season/$season/episode/$episode',
    });
  }
}
