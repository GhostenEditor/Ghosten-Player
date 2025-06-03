import 'package:api/api.dart';
import 'package:video_player/player.dart';

import '../utils/utils.dart';

extension FromMedia<T> on PlaylistItemDisplay<T> {
  static PlaylistItemDisplay<TVEpisode> fromEpisode(TVEpisode episode) {
    Duration start =
        episode.skipIntro > (episode.lastPlayedPosition ?? Duration.zero)
            ? episode.skipIntro
            : (episode.lastPlayedPosition ?? Duration.zero);
    if (episode.duration != null) {
      if (start > episode.duration! * 0.95) {
        start = episode.skipIntro > episode.duration! * 0.95 ? Duration.zero : episode.skipIntro;
      }
    }

    return PlaylistItemDisplay(
      fileId: episode.fileId,
      title: episode.displayTitle(),
      description:
          '${episode.seriesTitle} S${episode.season} E${episode.episode}${episode.airDate == null ? '' : ' - ${episode.airDate?.format()}'}',
      url: Uri(),
      poster: episode.poster,
      start: start,
      end: episode.skipEnding,
      source: episode,
    );
  }

  static PlaylistItemDisplay<Movie> fromMovie(Movie movie) {
    return PlaylistItemDisplay(
      fileId: movie.fileId,
      title: movie.displayTitle(),
      description: movie.releaseDate?.format(),
      url: Uri(),
      poster: movie.poster,
      start: movie.lastPlayedPosition ?? Duration.zero,
      source: movie,
    );
  }

  static PlaylistItemDisplay<Channel> fromChannel(Channel channel) {
    return PlaylistItemDisplay(
      title: channel.title,
      description: channel.category,
      url: channel.links.first,
      poster: channel.image,
      source: channel,
    );
  }
}

extension ConvertSubtitle on SubtitleData {
  Subtitle? toSubtitle() {
    if (url == null) {
      return null;
    }
    final mimeType = SubtitleMimeType.fromString(this.mimeType);
    if (mimeType == null) {
      return null;
    }
    final uri = Uri.parse(url!);
    return Subtitle(
      url:
          uri.host.isEmpty
              ? uri.replace(host: Api.baseUrl.host, port: Api.baseUrl.port, scheme: Api.baseUrl.scheme)
              : uri,
      mimeType: mimeType,
      language: language,
      label: label,
    );
  }
}
