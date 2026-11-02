import 'package:api/api.dart';
import 'package:video_player/player.dart';

import '../utils/utils.dart';

extension FromMedia<T> on PlaylistItem {
  static PlaylistItem fromEpisode(TVEpisode episode) {
    Duration start = episode.skipIntro > (episode.lastPlayedPosition ?? Duration.zero)
        ? episode.skipIntro
        : (episode.lastPlayedPosition ?? Duration.zero);
    if (episode.duration != null) {
      if (start > episode.duration! * 0.95) {
        start = episode.skipIntro > episode.duration! * 0.95 ? Duration.zero : episode.skipIntro;
      }
    }

    return PlaylistItem(
      title: episode.displayTitle(),
      description:
          '${episode.seriesTitle} S${episode.season} E${episode.episode}${episode.airDate == null ? '' : ' - ${episode.airDate?.format()}'}',
      poster: episode.poster,
      start: start,
      end: episode.skipEnding,
      source: episode,
    );
  }

  static PlaylistItem fromMovie(Movie movie) {
    return PlaylistItem(
      title: movie.displayTitle(),
      description: movie.releaseDate?.format(),
      poster: movie.poster,
      start: movie.lastPlayedPosition ?? Duration.zero,
      source: movie,
    );
  }

  static PlaylistItem fromChannel(Channel channel) {
    return PlaylistItem(
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
    final SubtitleMimeType mimeType = switch (this.mimeType) {
      SubtitleType.srt => SubtitleMimeType.srt,
      SubtitleType.ass => SubtitleMimeType.ass,
      SubtitleType.vtt => SubtitleMimeType.vtt,
      SubtitleType.xml => SubtitleMimeType.xml,
    };
    final Uri uri = Uri.parse(url!);
    return Subtitle(
      url: uri.host.isEmpty
          ? uri.replace(host: Api.baseUrl.host, port: Api.baseUrl.port, scheme: Api.baseUrl.scheme)
          : uri,
      mimeType: mimeType,
      language: language,
      label: label,
    );
  }
}

class ChannelItem {
  const ChannelItem({required this.label, this.height, required this.query});

  final MediaSearchQuery query;
  final String label;
  final double? height;
}

class SetSkipTimeData {
  const SetSkipTimeData({required this.skipTimeType, required this.value, required this.mediaType, required this.id});

  final SkipTimeType skipTimeType;
  final Duration value;
  final MediaType mediaType;
  final dynamic id;
}

Future<PlaylistData> getPlaylistById(MediaType type, dynamic id) async {
  switch (type) {
    case MediaType.movie:
      final Movie movie = await Api.movieQueryById(id);
      return PlaylistData(playlist: [FromMedia.fromMovie(movie)], themeColor: movie.themeColor);
    case MediaType.series:
      final TVSeries item = await Api.tvSeriesQueryById(id);
      final TVEpisode? nextToPlay = item.nextToPlay;
      if (nextToPlay != null) {
        final TVSeason season = await Api.tvSeasonQueryById(nextToPlay.seasonId);
        final List<PlaylistItem> playlist = season.episodes.map(FromMedia.fromEpisode).toList();
        return PlaylistData(
          playlist: playlist,
          themeColor: item.themeColor,
          activeIndex: season.episodes.indexWhere((episode) => episode.id == nextToPlay.id),
        );
      } else {
        throw Exception('No Source');
      }
    case MediaType.season:
      final TVSeason season = await Api.tvSeasonQueryById(id);
      return PlaylistData(playlist: season.episodes.map(FromMedia.fromEpisode).toList(), themeColor: season.themeColor);
    case MediaType.episode:
      final TVEpisode episode = await Api.tvEpisodeQueryById(id);
      final TVSeason season = await Api.tvSeasonQueryById(episode.seasonId);
      return PlaylistData(
        playlist: season.episodes.map(FromMedia.fromEpisode).toList(),
        themeColor: season.themeColor,
        activeIndex: season.episodes.indexWhere((episode) => episode.id == id),
      );
  }
}

class PlaylistData {
  const PlaylistData({required this.playlist, this.activeIndex = 0, this.themeColor})
    : assert(activeIndex >= 0),
      assert(activeIndex < playlist.length);

  final List<PlaylistItem> playlist;
  final int activeIndex;
  final int? themeColor;
}

class MediaListData {
  const MediaListData({required this.type, required this.query});

  final FuzzySearchType type;
  final MediaSearchQuery query;
}

class DetailData<D> {
  const DetailData({this.id, required this.data});

  final dynamic id;
  final D data;
}
