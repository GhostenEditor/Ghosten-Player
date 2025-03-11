import 'package:api/api.dart';
import 'package:video_player/player.dart';

import '../utils/utils.dart';

extension FromMedia<T> on PlaylistItem<T> {
  static PlaylistItem<TVEpisode> fromEpisode(TVEpisode episode) {
    Duration start = episode.skipIntro > (episode.lastPlayedPosition ?? Duration.zero) ? episode.skipIntro : (episode.lastPlayedPosition ?? Duration.zero);
    if (episode.duration != null) {
      if (start > episode.duration! * 0.95) {
        start = episode.skipIntro > episode.duration! * 0.95 ? Duration.zero : episode.skipIntro;
      }
    }
    return PlaylistItem(
      sourceType: episode.downloaded ? PlaylistItemSourceType.local : PlaylistItemSourceType.other,
      title: episode.displayTitle(),
      description: '${episode.seriesTitle} S${episode.season} E${episode.episode}${episode.airDate == null ? '' : ' - ${episode.airDate?.format()}'}',
      url: episode.url.normalize(),
      poster: episode.poster,
      subtitles: episode.subtitles.map((e) => e.toSubtitle()).toList(),
      start: start,
      end: episode.skipEnding,
      source: episode,
    );
  }

  static PlaylistItem<Movie> fromMovie(Movie movie) {
    return PlaylistItem(
        sourceType: movie.downloaded ? PlaylistItemSourceType.local : PlaylistItemSourceType.other,
        title: movie.displayTitle(),
        description: movie.airDate?.format(),
        url: movie.url.normalize(),
        poster: movie.poster,
        subtitles: movie.subtitles.map((e) => e.toSubtitle()).toList(),
        start: movie.lastPlayedPosition ?? Duration.zero,
        source: movie);
  }

  static PlaylistItem<Channel> fromChannel(Channel channel) {
    return PlaylistItem(
      sourceType: PlaylistItemSourceType.hls,
      title: channel.title,
      description: channel.category,
      url: channel.links.first,
      poster: channel.image,
      source: channel,
    );
  }
}

extension on SubtitleData {
  Subtitle toSubtitle() {
    return Subtitle(
      url: url!.host.isEmpty ? url!.replace(host: Api.baseUrl.host, port: Api.baseUrl.port, scheme: Api.baseUrl.scheme) : url!,
      mimeType: SubtitleMimeType.fromString(mimeType)!,
      language: language,
    );
  }
}
