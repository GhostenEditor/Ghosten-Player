import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

typedef Json = Map<String, dynamic>;
typedef JsonList = List<dynamic>;

class SortConfig {
  final FilterType? filter;
  final SortType type;
  final SortDirection direction;

  const SortConfig({this.filter, required this.type, required this.direction});

  SortConfig.fromJson(dynamic json)
      : type = SortType.fromString(json?['type']),
        direction = SortDirection.fromString(json?['direction']),
        filter = FilterType.fromString(json?['filter']);

  Json toMap() => {
        'type': type.name,
        'direction': direction.name,
        if (filter?.name != null) 'filter': filter?.name,
      };

  SortConfig copyWith({
    SortType? type,
    SortDirection? direction,
    FilterType? filter,
  }) {
    return SortConfig(
      type: type ?? this.type,
      direction: direction ?? this.direction,
      filter: filter ?? this.filter,
    );
  }
}

class MediaSearchQuery {
  final SortConfig? sort;
  final int? limit;
  final int? offset;

  const MediaSearchQuery({this.sort, this.limit, this.offset});

  Json toMap() {
    return {
      ...?sort?.toMap(),
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    };
  }
}

class MediaBase extends Equatable {
  final dynamic id;
  final String? title;
  final String? poster;
  final String? logo;
  final String? backdrop;
  final int? themeColor;
  final bool watched;
  final bool favorite;
  final DateTime? airDate;
  final String? overview;
  final String updateAt;

  MediaBase.fromJson(Json json)
      : id = json['id'],
        title = json['title'],
        poster = json['poster'],
        themeColor = json['themeColor'],
        watched = json['watched'],
        favorite = json['favorite'],
        airDate = (json['airDate'] as String?)?.toDateTime(),
        logo = json['logo'],
        backdrop = json['backdrop'],
        overview = json['overview'],
        updateAt = json['updateAt'];

  @override
  List<Object?> get props => [id, updateAt];
}

class Media extends MediaBase {
  final String? originalTitle;
  final DateTime? lastPlayedTime;
  final List<Actor> actors;
  final List<MediaCast> mediaCast;
  final List<MediaCrew> mediaCrew;
  final double? voteAverage;

  Media.fromJson(super.json)
      : originalTitle = json['originalTitle'],
        lastPlayedTime = (json['lastPlayedTime'] as String?)?.toDateTime(),
        voteAverage = json['voteAverage'],
        actors = (json['actors'] as JsonList?)?.toActors() ?? [],
        mediaCast = (json['mediaCast'] as JsonList?)?.toCast() ?? [],
        mediaCrew = (json['mediaCrew'] as JsonList?)?.toCrew() ?? [],
        super.fromJson();

  String displayTitle() {
    if (title != null && originalTitle != null) {
      return title == originalTitle ? title! : '$title ($originalTitle)';
    } else {
      return title ?? originalTitle ?? '';
    }
  }

  String displayRecentTitle() {
    return displayTitle();
  }
}

class MediaRecommendation {
  final dynamic id;
  final String? title;
  final String? originalTitle;
  final DateTime? airDate;
  final String? poster;
  final String? logo;
  final String? backdrop;
  final String? overview;
  final int? themeColor;
  final double? voteAverage;
  final int? voteCount;
  final MediaStatus status;
  final List<Genre> genres;

  MediaRecommendation.fromJson(Json json)
      : id = json['id'],
        title = json['title'],
        originalTitle = json['originalTitle'],
        airDate = (json['airDate'] as String?)?.toDateTime(),
        poster = json['poster'],
        themeColor = json['themeColor'],
        logo = json['logo'],
        backdrop = json['backdrop'],
        overview = json['overview'],
        voteAverage = json['voteAverage'],
        voteCount = json['voteCount'],
        status = MediaStatus.fromString(json['status']),
        genres = (json['genres'] as JsonList).toGenres();

  String displayTitle() {
    if (title != null && originalTitle != null) {
      return title == originalTitle ? title! : '$title ($originalTitle)';
    } else {
      return title ?? originalTitle ?? '';
    }
  }
}

class Movie extends Media {
  final int? voteCount;
  final String? country;
  final String? trailer;
  final MediaStatus status;
  final List<Genre> genres;
  final List<Studio> studios;
  final List<Keyword> keywords;
  final Duration? lastPlayedPosition;
  final bool downloaded;
  final String? fileId;
  final DateTime? releaseDate;
  final Duration? duration;
  final Scrapper scrapper;

  Movie.fromJson(super.json)
      : voteCount = json['voteCount'],
        country = json['country'],
        trailer = json['trailer'],
        status = MediaStatus.fromString(json['status']),
        lastPlayedPosition = (json['lastPlayedPosition'] as int?).toDuration(),
        keywords = (json['keywords'] as JsonList).toKeywords(),
        genres = (json['genres'] as JsonList).toGenres(),
        studios = (json['studios'] as JsonList).toStudios(),
        downloaded = json['downloaded'] ?? false,
        fileId = json['fileId'],
        duration = (json['duration'] as int?)?.toDuration(),
        releaseDate = (json['releaseDate'] as String?)?.toDateTime(),
        scrapper = Scrapper.fromJson(json['scrapper']),
        super.fromJson();
}

class TVSeries extends Media {
  final int? voteCount;
  final String? country;
  final String? trailer;
  final MediaStatus status;
  final Duration skipIntro;
  final Duration skipEnding;
  final List<Genre> genres;
  final List<Studio> studios;
  final List<Keyword> keywords;
  final List<TVSeason> seasons;
  final TVEpisode? nextToPlay;
  final DateTime? firstAirDate;
  final DateTime? lastAirDate;
  final Scrapper scrapper;

  TVSeries.fromJson(super.json)
      : voteCount = json['voteCount'],
        country = json['country'],
        trailer = json['trailer'],
        status = MediaStatus.fromString(json['status']),
        skipIntro = (json['skipIntro'] as int?).toDuration(),
        skipEnding = (json['skipEnding'] as int?).toDuration(),
        keywords = (json['keywords'] as JsonList).toKeywords(),
        genres = (json['genres'] as JsonList).toGenres(),
        studios = (json['studios'] as JsonList).toStudios(),
        seasons = (json['seasons'] as JsonList).toSeasons(),
        firstAirDate = (json['firstAirDate'] as String?)?.toDateTime(),
        lastAirDate = (json['lastAirDate'] as String?)?.toDateTime(),
        nextToPlay = json['nextToPlay'] == null ? null : TVEpisode.fromJson(json['nextToPlay']),
        scrapper = Scrapper.fromJson(json['scrapper']),
        super.fromJson();
}

class TVSeason extends Media {
  final int season;
  final String? seriesTitle;
  final Duration skipIntro;
  final Duration skipEnding;
  final int? episodeCount;
  final List<TVEpisode> episodes;

  TVSeason.fromJson(super.json)
      : seriesTitle = json['seriesTitle'],
        season = json['season'],
        skipIntro = (json['skipIntro'] as int?).toDuration(),
        skipEnding = (json['skipEnding'] as int?).toDuration(),
        episodeCount = json['episodeCount'],
        episodes = (json['episodes'] as JsonList).toEpisodes(),
        super.fromJson();
}

class TVEpisode extends Media {
  final int episode;
  final int season;
  final dynamic seasonId;
  final dynamic seriesId;
  final String? seriesTitle;
  final String? seasonTitle;
  final Duration skipIntro;
  final Duration skipEnding;
  final Duration? lastPlayedPosition;
  final bool downloaded;
  final List<MediaCast> guestStars;
  final String? fileId;
  final int? fileSize;
  final Duration? duration;

  TVEpisode.fromJson(super.json)
      : episode = json['episode'],
        season = json['season'],
        seasonId = json['seasonId'],
        seasonTitle = json['seasonTitle'],
        seriesId = json['seriesId'],
        seriesTitle = json['seriesTitle'],
        fileId = json['fileId'],
        skipIntro = (json['skipIntro'] as int?).toDuration(),
        skipEnding = (json['skipEnding'] as int?).toDuration(),
        duration = (json['duration'] as int?)?.toDuration(),
        lastPlayedPosition = (json['lastPlayedPosition'] as int?).toDuration(),
        downloaded = json['downloaded'] ?? false,
        guestStars = (json['guestStars'] as JsonList?)?.toCast() ?? [],
        fileSize = json['fileSize'],
        super.fromJson();

  @override
  String displayRecentTitle() => '$seriesTitle S$season E$episode - ${displayTitle()}';
}

class Scrapper {
  final String? type;
  final String? id;

  Scrapper.fromJson(Json json)
      : id = json['id'],
        type = json['type'],
        super();
}

class MediaCast {
  final dynamic id;
  final String name;
  final String? originalName;
  final String? knownForDepartment;
  final bool? adult;
  final int? gender;
  final String? role;
  final String? profile;
  final double? popularity;
  final int? episodeCount;
  final Scrapper scrapper;

  MediaCast.fromJson(Json json)
      : id = json['id'],
        name = json['name'],
        originalName = json['originalName'],
        knownForDepartment = json['knownForDepartment'],
        gender = json['gender'],
        profile = json['profile'],
        role = json['role'],
        episodeCount = json['episodeCount'],
        popularity = json['popularity'],
        adult = json['adult'],
        scrapper = Scrapper.fromJson(json['scrapper']);
}

class MediaCrew {
  final dynamic id;
  final String name;
  final String? originalName;
  final String? knownForDepartment;
  final String? department;
  final bool? adult;
  final int? gender;
  final String? job;
  final String? profile;
  final double? popularity;
  final int? episodeCount;
  final Scrapper scrapper;

  MediaCrew.fromJson(Json json)
      : id = json['id'],
        name = json['name'],
        originalName = json['originalName'],
        knownForDepartment = json['knownForDepartment'],
        department = json['department'],
        gender = json['gender'],
        profile = json['profile'],
        job = json['job'],
        episodeCount = json['episodeCount'],
        popularity = json['popularity'],
        adult = json['adult'],
        scrapper = Scrapper.fromJson(json['scrapper']);
}

class Actor {
  final dynamic id;
  final String name;
  final String originalName;
  final bool? adult;
  final int? gender;
  final String? character;
  final String? profile;
  final Scrapper scrapper;

  Actor.fromJson(Json json)
      : id = json['id'],
        name = json['name'],
        originalName = json['originalName'],
        gender = json['gender'],
        profile = json['profile'],
        character = json['character'],
        adult = json['adult'],
        scrapper = Scrapper.fromJson(json['scrapper']),
        super();
}

class Genre extends Equatable {
  final String name;
  final dynamic id;
  final Scrapper scrapper;

  Genre.fromJson(Json json)
      : id = json['id'],
        name = json['name'],
        scrapper = Scrapper.fromJson(json['scrapper']),
        super();

  @override
  List<Object?> get props => [id];
}

class Keyword extends Equatable {
  final String name;
  final dynamic id;
  final Scrapper scrapper;

  Keyword.fromJson(Json json)
      : id = json['id'],
        name = json['name'],
        scrapper = Scrapper.fromJson(json['scrapper']),
        super();

  @override
  List<Object?> get props => [id];
}

class Studio extends Equatable {
  final dynamic id;
  final String name;
  final String? country;
  final String? logo;
  final Scrapper scrapper;

  Studio.fromJson(Json json)
      : id = json['id'],
        name = json['name'],
        logo = json['logo'],
        country = json['country'],
        scrapper = Scrapper.fromJson(json['scrapper']),
        super();

  @override
  List<Object?> get props => [id];
}

class SubtitleData {
  final dynamic id;
  final String? url;
  final String? label;
  final String? language;
  final String? mimeType;
  final bool selected;

  const SubtitleData({
    this.id,
    this.url,
    this.mimeType,
    this.label,
    this.language,
    this.selected = false,
  });

  static const SubtitleData empty = SubtitleData();

  SubtitleData.fromJson(Json json)
      : id = json['id'],
        url = json['url'],
        label = json['label'],
        language = json['language'],
        mimeType = json['mimeType'],
        selected = json['selected'];
}

class Library {
  final dynamic id;
  final int driverId;
  final String filename;
  final String driverName;
  final DriverType driverType;
  final String? driverAvatar;
  final String? poster;

  Library.fromJson(Json json)
      : id = json['id'],
        filename = json['filename'],
        driverName = json['driverName'],
        driverAvatar = json['driverAvatar'],
        driverType = DriverType.fromString(json['driverType']),
        driverId = json['driverId'],
        poster = json['poster'];
}

class DNSOverride {
  final int id;
  final String domain;
  final String ip;

  const DNSOverride({required this.id, required this.domain, required this.ip});

  DNSOverride.fromJson(Json json)
      : id = json['id'],
        domain = json['domain'],
        ip = json['ip'];
}

class Server {
  final int id;
  final String host;
  final bool active;
  final bool invalid;
  final ServerType type;
  final String? username;

  Server.fromJson(Json json)
      : id = json['id'],
        host = json['host'],
        active = json['active'],
        invalid = json['invalid'],
        username = json['username'],
        type = ServerType.fromString(json['type']);
}

enum ServerType {
  local,
  remote,
  emby,
  jellyfin;

  static ServerType fromString(String? str) {
    return ServerType.values.firstWhere((element) => element.name == str, orElse: () => ServerType.local);
  }
}

class Playlist {
  final int id;
  final String url;
  final String? title;

  Playlist.fromJson(Json json)
      : id = json['id'],
        url = json['url'],
        title = json['title'];
}

class Channel {
  final int id;
  final List<Uri> links;
  final String? title;
  final String? image;
  final String? category;

  Channel.fromJson(Json json)
      : id = json['id'],
        links = (json['links'] as List<dynamic>).map((l) => Uri.tryParse(l)).nonNulls.toList(),
        title = json['title'],
        image = json['image'],
        category = json['category'];
}

class ChannelEpgItem {
  DateTime? start;
  DateTime? stop;
  String title;

  ChannelEpgItem.fromJson(Json json)
      : start = epgTimeToDateTime(json['start']),
        stop = epgTimeToDateTime(json['stop']),
        title = json['title'];
}

class SearchResult {
  final String id;
  final String title;
  final String type;
  final String? originalTitle;
  final String? overview;
  final String? poster;
  final DateTime? airDate;

  SearchResult.fromJson(Json json)
      : id = json['id'],
        title = json['title'],
        originalTitle = json['originalTitle'],
        type = json['type'],
        overview = json['overview'],
        poster = json['poster'],
        airDate = (json['airDate'] as String?)?.toDateTime();
}

class SearchFuzzyResult {
  final PageData<Movie> movies;
  final PageData<TVSeries> series;
  final PageData<TVEpisode> episodes;
  final PageData<MediaCast> mediaCast;
  final PageData<MediaCrew> mediaCrew;

  SearchFuzzyResult.fromJson(Json json)
      : movies = PageData.fromJson(json['movies'], (json['movies']['data'] as JsonList).map((e) => Movie.fromJson(e))),
        series = PageData.fromJson(json['series'], (json['series']['data'] as JsonList).map((e) => TVSeries.fromJson(e))),
        episodes = PageData.fromJson(json['episodes'], (json['episodes']['data'] as JsonList).map((e) => TVEpisode.fromJson(e))),
        mediaCast = PageData.fromJson(json['mediaCast'], (json['mediaCast']['data'] as JsonList).map((e) => MediaCast.fromJson(e))),
        mediaCrew = PageData.fromJson(json['mediaCrew'], (json['mediaCrew']['data'] as JsonList).map((e) => MediaCrew.fromJson(e)));
}

class Session<T> {
  final SessionStatus status;
  final T? data;

  Session.fromJson(Json json)
      : status = SessionStatus.fromString(json['status']),
        data = json['data'];
}

class SessionCreate {
  final String id;
  final Uri uri;

  const SessionCreate({required this.id, required this.uri});
}

class DriverAccount {
  int id;
  DriverType type;
  String name;
  String? avatar;

  DriverAccount.fromJson(Json json)
      : id = json['id'],
        type = DriverType.fromString(json['type']),
        name = json['name'],
        avatar = json['avatar'];
}

class DriverFileInfo {
  final String filename;
  final int size;
  final DriverType driverType;
  final DateTime createdAt;

  DriverFileInfo.fromJson(Json json)
      : filename = json['filename'],
        driverType = DriverType.fromString(json['driverType']),
        createdAt = (json['createAt'] as String).toDateTime()!,
        size = json['size'];
}

class DriverFile {
  final String name;
  final String id;
  final String parentId;
  final FileType type;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final FileCategory? category;
  final int? size;
  final Uri? url;
  final String? fileId;

  DriverFile.fromJson(Json json)
      : name = json['name'],
        category = json['category'] == null ? null : FileCategory.fromString(json['category']),
        id = json['id'],
        parentId = json['parentId'],
        type = FileType.fromString(json['type']),
        createdAt = (json['createdAt'] as String?)?.toDateTime(),
        updatedAt = (json['updatedAt'] as String?)?.toDateTime(),
        size = json['size'],
        url = json['url'] != null ? Uri.tryParse(json['url']) : null,
        fileId = json['fileId'];
}

class PlayerHistory {
  final dynamic id;
  final MediaType mediaType;
  final String title;
  final String? poster;
  final Duration duration;
  final DateTime lastPlayedTime;
  final Duration lastPlayedPosition;

  PlayerHistory.fromJson(Json json)
      : id = json['id'],
        mediaType = MediaType.fromString(json['mediaType']),
        title = json['title'],
        poster = json['poster'],
        duration = (json['duration'] as int?).toDuration(),
        lastPlayedTime = ((json['lastPlayedTime'] as String?)?.toDateTime())!,
        lastPlayedPosition = (json['lastPlayedPosition'] as int?).toDuration();
}

class PlaybackInfo {
  final String url;
  final String? container;
  final List<SubtitleData> subtitles;
  final dynamic others;

  PlaybackInfo.fromJson(Json json)
      : url = json['url'],
        container = json['container'],
        subtitles = (json['subtitles'] as JsonList).toSubtitles(),
        others = json['others'];
}

class DownloadTask {
  final int id;
  final dynamic mediaId;
  final String? poster;
  final int size;
  final double? progress;
  final int? speed;
  final Duration elapsed;
  final String title;
  final MediaType mediaType;
  final DateTime createdAt;
  final DownloadTaskStatus status;

  DownloadTask.fromJson(Json json)
      : id = json['id'],
        mediaId = json['mediaId'],
        poster = json['poster'],
        size = json['size'],
        progress = json['progress'],
        speed = json['speed'],
        elapsed = Duration(seconds: json['elapsed']),
        title = json['title'],
        mediaType = MediaType.fromString(json['mediaType']),
        createdAt = (json['createdAt'] as String).toDateTime()!,
        status = DownloadTaskStatus.fromString(json['status']);
}

enum DownloadTaskStatus {
  idle,
  downloading,
  complete,
  failed;

  static DownloadTaskStatus fromString(String? name) {
    return DownloadTaskStatus.values.firstWhereOrNull((s) => s.name == name) ?? (throw Exception('Wrong DownloadTaskStatus Type of "$name"'));
  }
}

class ScheduleTask {
  final int id;
  final int rid;
  final int? pid;
  final ScheduleTaskType type;
  final ScheduleTaskStatus status;
  final dynamic data;

  ScheduleTask.fromJson(Json json)
      : id = json['id'],
        rid = json['rid'],
        pid = json['pid'],
        type = ScheduleTaskType.fromString(json['type']),
        status = ScheduleTaskStatus.fromString(json['status']),
        data = json['data'];
}

enum ScheduleTaskType {
  syncLibrary,
  scrapeLibrary;

  static ScheduleTaskType fromString(String? name) {
    return ScheduleTaskType.values.firstWhereOrNull((s) => s.name == name) ?? (throw Exception('Wrong ScheduleTaskType Type of "$name"'));
  }
}

enum ScheduleTaskStatus {
  idle,
  running,
  paused,
  completed,
  error;

  static ScheduleTaskStatus fromString(String? name) {
    return ScheduleTaskStatus.values.firstWhereOrNull((s) => s.name == name) ?? (throw Exception('Wrong ScheduleTaskStatus Type of "$name"'));
  }
}

enum ScraperBehavior {
  skip,
  chooseFirst,
  exact;

  static ScraperBehavior fromString(String s) {
    return ScraperBehavior.values.firstWhere((e) => e.name == s);
  }
}

class SettingScraper {
  final bool nfoEnabled;
  final bool tmdbEnabled;
  final ScraperBehavior behavior;
  final int tmdbMaxCast;
  final int tmdbMaxCrew;

  const SettingScraper({
    required this.nfoEnabled,
    required this.tmdbEnabled,
    required this.behavior,
    required this.tmdbMaxCast,
    required this.tmdbMaxCrew,
  });

  SettingScraper.fromJson(Json json)
      : behavior = ScraperBehavior.fromString(json['behavior']),
        nfoEnabled = json['nfoEnabled'],
        tmdbEnabled = json['tmdbEnabled'],
        tmdbMaxCast = json['tmdbMaxCast'],
        tmdbMaxCrew = json['tmdbMaxCrew'];

  Json toJson() {
    return {
      'behavior': behavior.name,
      'nfoEnabled': nfoEnabled,
      'tmdbEnabled': tmdbEnabled,
      'tmdbMaxCast': tmdbMaxCast,
      'tmdbMaxCrew': tmdbMaxCrew,
    };
  }

  SettingScraper copyWith({
    bool? nfoEnabled,
    bool? tmdbEnabled,
    ScraperBehavior? behavior,
    int? tmdbMaxCast,
    int? tmdbMaxCrew,
  }) {
    return SettingScraper(
      nfoEnabled: nfoEnabled ?? this.nfoEnabled,
      tmdbEnabled: tmdbEnabled ?? this.tmdbEnabled,
      behavior: behavior ?? this.behavior,
      tmdbMaxCast: tmdbMaxCast ?? this.tmdbMaxCast,
      tmdbMaxCrew: tmdbMaxCrew ?? this.tmdbMaxCrew,
    );
  }
}

class UpdateResp {
  final List<UpdateRespAsset> assets;
  final DateTime? createAt;
  final Version tagName;
  final String comment;
  final bool prerelease;

  UpdateResp.fromJson(dynamic json)
      : assets = List.generate(json['assets'].length, (index) => UpdateRespAsset.fromJson(json['assets'][index])),
        tagName = Version.fromString(json['tag_name'].substring(1)),
        comment = json['body'],
        prerelease = json['prerelease'],
        createAt = (json['published_at'] as String).toDateTime();
}

class UpdateRespAsset {
  final String name;
  final String url;

  UpdateRespAsset.fromJson(Json json)
      : name = json['name'],
        url = json['browser_download_url'];
}

class UpdateData {
  final DateTime? createAt;
  final Version tagName;
  final String comment;
  final String url;

  const UpdateData({
    required this.url,
    required this.tagName,
    required this.comment,
    this.createAt,
  });
}

class Version {
  final int major;
  final int minor;
  final int patch;
  final int? alpha;
  final int? beta;

  const Version(this.major, this.minor, this.patch, {this.alpha, this.beta});

  Version.unknown()
      : major = 0,
        minor = 0,
        patch = 0,
        alpha = null,
        beta = null;

  factory Version.fromString(String s) {
    final arr = s.split('-');
    final pre = arr.elementAtOrNull(0);
    final suf = arr.elementAtOrNull(1);
    if (pre == null) {
      return Version.unknown();
    } else {
      final list = pre.split('.');
      if (list.length != 3) {
        return Version.unknown();
      }
      final major = int.tryParse(list[0]);
      final minor = int.tryParse(list[1]);
      final patch = int.tryParse(list[2]);
      if (major == null || minor == null || patch == null) {
        return Version.unknown();
      }
      int? a;
      int? b;
      if (suf != null) {
        if (suf.startsWith('alpha.')) {
          a = int.tryParse(suf.substring(6));
        }
        if (suf.startsWith('beta.')) {
          b = int.tryParse(suf.substring(5));
        }
      }
      return Version(major, minor, patch, alpha: a, beta: b);
    }
  }

  @override
  String toString() {
    if (alpha != null) {
      return '$major.$minor.$patch-alpha.$alpha';
    }
    if (beta != null) {
      return '$major.$minor.$patch-beta.$beta';
    }
    return '$major.$minor.$patch';
  }

  bool isPrerelease() {
    return alpha != null || beta != null;
  }

  double toDouble() {
    double d = patch + minor * 1000.0 + major * 1000000.0;
    if (alpha != null || beta != null) {
      d -= 1;
    }
    if (alpha != null) {
      d += (alpha! + 1) / 1000000.0;
    }
    if (beta != null) {
      d += (beta! + 1) / 1000.0;
    }
    return d;
  }

  bool operator >(Version other) {
    return toDouble() > other.toDouble();
  }

  bool operator <(Version other) {
    return toDouble() < other.toDouble();
  }
}

enum NetworkDiagnoticsStatus {
  success,
  fail;

  static NetworkDiagnoticsStatus fromString(String s) {
    return NetworkDiagnoticsStatus.values.firstWhere((e) => e.name == s);
  }
}

class NetworkDiagnotics {
  final NetworkDiagnoticsStatus status;
  final String domain;
  final String? ip;
  final String? error;
  final String? tip;

  NetworkDiagnotics.fromJson(Json json)
      : status = NetworkDiagnoticsStatus.fromString(json['status']),
        domain = json['domain'],
        ip = json['ip'],
        tip = json['tip'],
        error = json['error'];

  @override
  bool operator ==(Object other) => other is NetworkDiagnotics && status == other.status && domain == other.domain;

  @override
  int get hashCode => Object.hash(status, domain);
}

class PageData<D> {
  final int offset;
  final int limit;
  final int count;
  final List<D> data;

  PageData.fromJson(Json json, Iterable<D> iter)
      : offset = json['offset'],
        limit = json['limit'],
        count = json['count'],
        data = iter.toList();
}

class Log {
  final LogLevel level;
  final DateTime time;
  final String message;

  Log.fromJson(Json json)
      : level = LogLevel.fromInt(json['level']),
        time = DateTime.parse(json['time']),
        message = json['message'];
}

enum LogLevel {
  error,
  warn,
  info,
  debug,
  trace;

  static LogLevel fromInt(int? level) {
    return switch (level) {
      1 => LogLevel.error,
      2 => LogLevel.warn,
      3 => LogLevel.info,
      4 => LogLevel.debug,
      5 => LogLevel.trace,
      _ => throw Exception('Wrong Log Level of "$level"'),
    };
  }
}

enum MediaType {
  movie,
  series,
  season,
  episode;

  static MediaType fromString(String? name) {
    return switch (name) {
      'movie' => MediaType.movie,
      'series' => MediaType.series,
      'season' => MediaType.season,
      'episode' => MediaType.episode,
      _ => throw Exception('Wrong Media Type of "$name"'),
    };
  }
}

enum DriverType {
  alipan,
  quark,
  webdav,
  emby,
  jellyfin,
  local;

  static DriverType fromString(String? name) {
    return DriverType.values.firstWhere((s) => s.name == name);
  }
}

enum QueryType {
  genre,
  studio,
  keyword,
  actor;

  static QueryType fromString(String? name) {
    return switch (name) {
      'genre' => QueryType.genre,
      'studio' => QueryType.studio,
      'keyword' => QueryType.keyword,
      'actor' => QueryType.actor,
      _ => throw Exception('Wrong Filter Type of "$name"'),
    };
  }
}

enum FileType {
  file,
  folder;

  static FileType fromString(String s) {
    return switch (s) {
      'file' => FileType.file,
      'folder' => FileType.folder,
      _ => throw UnimplementedError('$s has not been implemented.'),
    };
  }
}

enum FileCategory {
  video,
  audio,
  image,
  doc,
  other;

  static FileCategory fromString(String s) {
    return FileCategory.values.firstWhere((e) => e.name == s, orElse: () => FileCategory.other);
  }
}

enum MediaStatus {
  returningSeries,
  ended,
  released,
  unknown;

  static MediaStatus fromString(String? name) {
    return switch (name) {
      'Returning Series' => MediaStatus.returningSeries,
      'Ended' => MediaStatus.ended,
      'Released' => MediaStatus.released,
      'Unknown' => MediaStatus.unknown,
      _ => MediaStatus.unknown,
    };
  }
}

enum LibraryType { tv, movie }

enum SkipTimeType {
  intro,
  ending,
}

enum SessionStatus {
  created,
  progressing,
  data,
  finished,
  failed;

  static SessionStatus fromString(String str) {
    final l = str.toLowerCase();
    return SessionStatus.values.firstWhere((element) => element.name == l);
  }
}

enum SortType {
  title,
  airDate,
  createAt,
  lastPlayedTime;

  static SortType fromString(String? str) {
    return SortType.values.firstWhere((element) => element.name == str, orElse: () => SortType.title);
  }
}

enum SortDirection {
  asc,
  desc;

  static SortDirection fromString(String? str) {
    return SortDirection.values.firstWhere((element) => element.name == str, orElse: () => SortDirection.desc);
  }
}

enum FilterType {
  favorite,
  exceptFavorite,
  watched,
  unwatched;

  static FilterType fromString(String? str) {
    return FilterType.values.firstWhere((element) => element.name == str);
  }
}

enum HdrType {
  invalid,
  dolbyVision,
  hdr10,
  hlg,
  hdr10Plus;

  static HdrType fromInt(int n) {
    return switch (n) {
      1 => HdrType.dolbyVision,
      2 => HdrType.hdr10,
      3 => HdrType.hlg,
      4 => HdrType.hdr10Plus,
      _ => HdrType.invalid,
    };
  }
}

extension on int? {
  Duration toDuration() {
    return Duration(milliseconds: this ?? 0);
  }
}

extension on String {
  DateTime? toDateTime() {
    return DateTime.tryParse(this);
  }
}

DateTime? epgTimeToDateTime(String? s) {
  if (s == null) {
    return null;
  } else {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(s.substring(0, 2)), int.parse(s.substring(3, 5)));
  }
}

extension on JsonList {
  List<Actor> toActors() => List.generate(length, (index) => Actor.fromJson(this[index]));

  List<MediaCast> toCast() => List.generate(length, (index) => MediaCast.fromJson(this[index]));

  List<MediaCrew> toCrew() => List.generate(length, (index) => MediaCrew.fromJson(this[index]));

  List<Genre> toGenres() => List.generate(length, (index) => Genre.fromJson(this[index]));

  List<Keyword> toKeywords() => List.generate(length, (index) => Keyword.fromJson(this[index]));

  List<Studio> toStudios() => List.generate(length, (index) => Studio.fromJson(this[index]));

  List<TVSeason> toSeasons() => List.generate(length, (index) => TVSeason.fromJson(this[index]));

  List<TVEpisode> toEpisodes() => List.generate(length, (index) => TVEpisode.fromJson(this[index]));

  List<SubtitleData> toSubtitles() => List.generate(length, (index) => SubtitleData.fromJson(this[index]));
}
