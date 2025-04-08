import 'package:equatable/equatable.dart';

typedef Json = Map<String, dynamic>;
typedef JsonList = List<dynamic>;

class SortConfig {
  final FilterType filter;
  final SortType type;
  final SortDirection direction;

  const SortConfig({required this.filter, required this.type, required this.direction});

  SortConfig.fromJson(dynamic json)
      : type = SortType.fromString(json?['type']),
        direction = SortDirection.fromString(json?['direction']),
        filter = FilterType.fromString(json?['filter']);

  Json toMap() => {'type': type.name, 'direction': direction.name, 'filter': filter.name};

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
  final SortConfig sort;
  final String? search;
  final int? limit;

  const MediaSearchQuery({required this.sort, this.search, this.limit});

  Json toMap() {
    return {...sort.toMap(), 'search': search, 'limit': limit};
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
  final String filename;
  final List<Actor> actors;

  Media.fromJson(super.json)
      : originalTitle = json['originalTitle'],
        lastPlayedTime = (json['lastPlayedTime'] as String?)?.toDateTime(),
        actors = (json['actors'] as JsonList).toActors(),
        filename = json['filename'],
        super.fromJson();

  String displayTitle() {
    if (title != null && originalTitle != null) {
      return title == originalTitle ? title! : '$title ($originalTitle)';
    } else {
      return title ?? originalTitle ?? filename;
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
  final String filename;
  final DateTime? airDate;
  final String? poster;
  final String? logo;
  final String? backdrop;
  final String? overview;
  final int? themeColor;
  final double? voteAverage;
  final int voteCount;
  final MediaStatus status;
  final List<Genre> genres;

  MediaRecommendation.fromJson(Json json)
      : id = json['id'],
        title = json['title'],
        originalTitle = json['originalTitle'],
        filename = json['filename'],
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
      return title ?? originalTitle ?? filename;
    }
  }
}

class Movie extends Media {
  final double? voteAverage;
  final int voteCount;
  final String? country;
  final String? trailer;
  final MediaStatus status;
  final List<Genre> genres;
  final List<Studio> studios;
  final List<Keyword> keywords;
  final Duration? lastPlayedPosition;
  final bool downloaded;
  final String ext;
  final Uri? url;
  final int? fileSize;
  final List<SubtitleData> subtitles;
  final Duration? duration;
  final Scrapper scrapper;

  Movie.fromJson(super.json)
      : voteAverage = json['voteAverage'],
        voteCount = json['voteCount'],
        country = json['country'],
        trailer = json['trailer'],
        status = MediaStatus.fromString(json['status']),
        lastPlayedPosition = (json['lastPlayedPosition'] as int?).toDuration(),
        keywords = (json['keywords'] as JsonList).toKeywords(),
        genres = (json['genres'] as JsonList).toGenres(),
        studios = (json['studios'] as JsonList).toStudios(),
        downloaded = json['downloaded'] ?? false,
        ext = json['ext'],
        url = json['url'] != null ? Uri.parse(json['url']) : null,
        fileSize = json['fileSize'],
        duration = (json['duration'] as int?)?.toDuration(),
        subtitles = (json['subtitles'] as JsonList).toSubtitles(),
        scrapper = Scrapper.fromJson(json['scrapper']),
        super.fromJson();
}

class TVSeries extends Media {
  final double? voteAverage;
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
  final Scrapper scrapper;

  TVSeries.fromJson(super.json)
      : voteAverage = json['voteAverage'],
        voteCount = json['voteCount'],
        country = json['country'],
        trailer = json['trailer'],
        status = MediaStatus.fromString(json['status']),
        skipIntro = (json['skipIntro'] as int?).toDuration(),
        skipEnding = (json['skipEnding'] as int?).toDuration(),
        keywords = (json['keywords'] as JsonList).toKeywords(),
        genres = (json['genres'] as JsonList).toGenres(),
        studios = (json['studios'] as JsonList).toStudios(),
        seasons = (json['seasons'] as JsonList).toSeasons(),
        nextToPlay = json['nextToPlay'] == null ? null : TVEpisode.fromJson(json['nextToPlay']),
        scrapper = Scrapper.fromJson(json['scrapper']),
        super.fromJson();
}

class TVSeason extends MediaBase {
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
  final String ext;
  final Uri? url;
  final int? fileSize;
  final Duration? duration;
  final List<SubtitleData> subtitles;

  TVEpisode.fromJson(super.json)
      : episode = json['episode'],
        season = json['season'],
        seasonId = json['seasonId'],
        seasonTitle = json['seasonTitle'],
        seriesId = json['seriesId'],
        seriesTitle = json['seriesTitle'],
        skipIntro = (json['skipIntro'] as int?).toDuration(),
        skipEnding = (json['skipEnding'] as int?).toDuration(),
        duration = (json['duration'] as int?)?.toDuration(),
        lastPlayedPosition = (json['lastPlayedPosition'] as int?).toDuration(),
        downloaded = json['downloaded'] ?? false,
        ext = json['ext'],
        url = json['url'] != null ? Uri.parse(json['url']) : null,
        fileSize = json['fileSize'],
        subtitles = (json['subtitles'] as JsonList).toSubtitles(),
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

class Genre {
  final String name;
  final dynamic id;
  final Scrapper scrapper;

  Genre.fromJson(Json json)
      : id = json['id'],
        name = json['name'],
        scrapper = Scrapper.fromJson(json['scrapper']),
        super();
}

class Keyword {
  final String name;
  final dynamic id;
  final Scrapper scrapper;

  Keyword.fromJson(Json json)
      : id = json['id'],
        name = json['name'],
        scrapper = Scrapper.fromJson(json['scrapper']),
        super();
}

class Studio {
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
}

class SubtitleData {
  final Uri? url;
  final String? title;
  final String? language;
  final String? mimeType;

  const SubtitleData({
    this.url,
    this.mimeType,
    this.title,
    this.language,
  });

  static const SubtitleData empty = SubtitleData();

  SubtitleData.fromJson(Json json)
      : url = Uri.parse(json['url']),
        title = json['title'],
        language = json['language'],
        mimeType = json['mimeType'];
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
  final int id;
  final String title;
  final String? originalTitle;
  final String? overview;
  final String? poster;
  final DateTime? airDate;

  SearchResult.fromJson(Json json)
      : id = json['id'],
        title = json['title'],
        originalTitle = json['originalTitle'],
        overview = json['overview'],
        poster = json['poster'],
        airDate = (json['airDate'] as String?)?.toDateTime();
}

class SearchFuzzyResult {
  final List<Movie> movies;
  final List<TVSeries> series;
  final List<TVEpisode> episodes;
  final List<Actor> actors;

  SearchFuzzyResult.fromJson(Json json)
      : movies = (json['movies'] as JsonList).map((e) => Movie.fromJson(e)).toList(),
        series = (json['series'] as JsonList).map((e) => TVSeries.fromJson(e)).toList(),
        episodes = (json['episodes'] as JsonList).map((e) => TVEpisode.fromJson(e)).toList(),
        actors = (json['actors'] as JsonList).map((e) => Actor.fromJson(e)).toList();
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

  DriverFile.fromJson(Json json)
      : name = json['name'],
        category = json['category'] == null ? null : FileCategory.fromString(json['category']),
        id = json['id'],
        parentId = json['parentId'],
        type = FileType.fromString(json['type']),
        createdAt = (json['createdAt'] as String?)?.toDateTime(),
        updatedAt = (json['updatedAt'] as String?)?.toDateTime(),
        size = json['size'],
        url = json['url'] != null ? Uri.tryParse(json['url']) : null;
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
    return switch (name) {
      'idle' => DownloadTaskStatus.idle,
      'downloading' => DownloadTaskStatus.downloading,
      'complete' => DownloadTaskStatus.complete,
      'failed' => DownloadTaskStatus.failed,
      _ => throw Exception('Wrong DownloadTaskStatus Type of "$name"'),
    };
  }
}

class UpdateResp {
  List<UpdateRespAsset> assets;
  DateTime? createAt;
  Version tagName;
  String comment;

  UpdateResp.fromJson(Json json)
      : assets = List.generate(json['assets'].length, (index) => UpdateRespAsset.fromJson(json['assets'][index])),
        tagName = Version.fromString(json['tag_name'].substring(1)),
        comment = json['body'],
        createAt = (json['published_at'] as String).toDateTime();
}

class UpdateRespAsset {
  String name;
  String url;

  UpdateRespAsset.fromJson(Json json)
      : name = json['name'],
        url = json['browser_download_url'];
}

class Version {
  final int major;
  final int minor;
  final int patch;

  const Version(this.major, this.minor, this.patch);

  Version.unknown()
      : major = 0,
        minor = 0,
        patch = 0;

  factory Version.fromString(String s) {
    final arr = s.split('.');
    if (arr.length != 3) {
      return Version.unknown();
    }
    final major = int.tryParse(arr[0]);
    final minor = int.tryParse(arr[1]);
    final patch = int.tryParse(arr[2]);
    if (major == null || minor == null || patch == null) {
      return Version.unknown();
    }
    return Version(major, minor, patch);
  }

  @override
  String toString() {
    return '$major.$minor.$patch';
  }

  bool operator >(Version other) {
    return major > other.major || (major == other.major && minor > other.minor) || (major == other.major && minor == other.minor && patch > other.patch);
  }

  bool operator <(Version other) {
    return major < other.major || (major == other.major && minor < other.minor) || (major == other.major && minor == other.minor && patch < other.patch);
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
  local;

  static DriverType fromString(String? name) {
    return switch (name) {
      'alipan' => DriverType.alipan,
      'quark' => DriverType.quark,
      'webdav' => DriverType.webdav,
      'emby' => DriverType.emby,
      'local' => DriverType.local,
      _ => throw Exception('Wrong Driver Type of "$name"'),
    };
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
  all,
  favorite,
  exceptFavorite,
  watched,
  unwatched;

  static FilterType fromString(String? str) {
    return FilterType.values.firstWhere((element) => element.name == str, orElse: () => FilterType.all);
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

  List<Genre> toGenres() => List.generate(length, (index) => Genre.fromJson(this[index]));

  List<Keyword> toKeywords() => List.generate(length, (index) => Keyword.fromJson(this[index]));

  List<Studio> toStudios() => List.generate(length, (index) => Studio.fromJson(this[index]));

  List<TVSeason> toSeasons() => List.generate(length, (index) => TVSeason.fromJson(this[index]));

  List<TVEpisode> toEpisodes() => List.generate(length, (index) => TVEpisode.fromJson(this[index]));

  List<SubtitleData> toSubtitles() => List.generate(length, (index) => SubtitleData.fromJson(this[index]));
}
