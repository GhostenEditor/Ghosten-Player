import 'package:api/api.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/player.dart';

import '../utils/utils.dart';

extension FromMedia on ExPlaylistItem {
  static ExPlaylistItem fromEpisode(TVEpisode episode) {
    return ExPlaylistItem(
      id: episode.id,
      sourceType: episode.downloaded ? PlaylistItemSourceType.local : PlaylistItemSourceType.other,
      title: episode.displayTitle(),
      description: '${episode.seriesTitle} S${episode.season} E${episode.episode}${episode.airDate == null ? '' : ' - ${episode.airDate?.format()}'}',
      url: episode.url.normalize(),
      poster: episode.poster,
      subtitles: episode.subtitles
          .map((e) => Subtitle(
                url: e.url!.host.isEmpty ? e.url!.replace(host: Api.baseUrl.host, port: Api.baseUrl.port, scheme: Api.baseUrl.scheme) : e.url!,
                mimeType: SubtitleMimeType.fromString(e.mimeType)!,
                language: e.language,
              ))
          .toList(),
      start: episode.skipIntro > (episode.lastPlayedPosition ?? Duration.zero) ? episode.skipIntro : (episode.lastPlayedPosition ?? Duration.zero),
      end: episode.skipEnding,
      downloadable: !episode.downloaded,
      canSkipIntro: true,
      canSkipEnding: true,
    );
  }

  static ExPlaylistItem fromMovie(Movie movie) {
    return ExPlaylistItem(
      id: movie.id,
      sourceType: movie.downloaded ? PlaylistItemSourceType.local : PlaylistItemSourceType.other,
      title: movie.title ?? movie.filename,
      description: '${movie.originalTitle} - ${movie.airDate?.format()}',
      url: movie.url.normalize(),
      poster: movie.poster,
      subtitles: movie.subtitles
          .map((e) => Subtitle(
                url: e.url!.host.isEmpty ? e.url!.replace(host: Api.baseUrl.host, port: Api.baseUrl.port, scheme: Api.baseUrl.scheme) : e.url!,
                mimeType: SubtitleMimeType.fromString(e.mimeType)!,
                language: e.language,
              ))
          .toList(),
      start: movie.lastPlayedPosition ?? Duration.zero,
      downloadable: !movie.downloaded,
    );
  }

  static ExPlaylistItem fromChannel(Channel channel) {
    return ExPlaylistItem(
        id: channel.id,
        sourceType: PlaylistItemSourceType.hls,
        title: channel.title,
        description: channel.category,
        url: Uri.parse(channel.url),
        poster: channel.image,
        posterPadding: const EdgeInsets.only(top: 28, left: 24, right: 24, bottom: 12));
  }
}

class ExPlaylistItem extends PlaylistItem {
  final int id;
  final bool downloadable;
  final EdgeInsets posterPadding;
  final bool canSkipIntro;
  final bool canSkipEnding;

  const ExPlaylistItem({
    required this.id,
    required super.url,
    required super.sourceType,
    super.title,
    super.description,
    super.poster,
    super.subtitles,
    super.start = Duration.zero,
    super.end = Duration.zero,
    this.downloadable = false,
    this.posterPadding = EdgeInsets.zero,
    this.canSkipIntro = false,
    this.canSkipEnding = false,
  });

  @override
  ExPlaylistItem copyWith({
    String? poster,
    String? title,
    String? description,
    Uri? url,
    Duration? start,
    Duration? end,
    PlaylistItemSourceType? sourceType,
    List<Subtitle>? subtitles,
  }) {
    return ExPlaylistItem(
      id: id,
      url: url ?? this.url,
      sourceType: sourceType ?? this.sourceType,
      title: title ?? this.title,
      description: description ?? this.description,
      poster: poster ?? this.poster,
      subtitles: subtitles ?? this.subtitles,
      start: start ?? this.start,
      end: end ?? this.end,
      downloadable: downloadable,
      posterPadding: posterPadding,
      canSkipIntro: canSkipIntro,
      canSkipEnding: canSkipEnding,
    );
  }
}

enum PlayerType {
  tv,
  movie,
  live,
}
