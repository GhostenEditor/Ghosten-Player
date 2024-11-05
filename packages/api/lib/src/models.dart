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

  const MediaSearchQuery({required this.sort, this.search});

  Json toMap() {
    return {...sort.toMap(), 'search': search};
  }
}

class MediaBase {
  final int id;
  final String? title;
  final String? poster;
  final String? logo;
  final String? backdrop;
  final int? themeColor;
  final bool watched;
  final bool favorite;
  final DateTime? airDate;
  final String? overview;

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
        overview = json['overview'];
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

class Movie extends Media {
  final double? voteAverage;
  final int voteCount;
  final String? country;
  final String? trailer;
  final SeriesStatus status;
  final List<Genre> genres;
  final List<Studio> studios;
  final List<Keyword> keywords;
  final Duration? lastPlayedPosition;
  final String? url;
  final bool downloaded;
  final String ext;
  final int fileSize;
  final List<SubtitleData> subtitles;
  final Scrapper scrapper;

  Movie.fromJson(super.json)
      : voteAverage = json['voteAverage'],
        voteCount = json['voteCount'],
        country = json['country'],
        trailer = json['trailer'],
        status = SeriesStatus.fromString(json['status']),
        lastPlayedPosition = (json['lastPlayedPosition'] as int?).toDuration(),
        keywords = (json['keywords'] as JsonList).toKeywords(),
        genres = (json['genres'] as JsonList).toGenres(),
        studios = (json['studios'] as JsonList).toStudios(),
        url = json['url'],
        downloaded = json['downloaded'] ?? false,
        ext = json['ext'],
        fileSize = json['fileSize'],
        subtitles = (json['subtitles'] as JsonList).toSubtitles(),
        scrapper = Scrapper.fromJson(json['scrapper']),
        super.fromJson();
}

class TVSeries extends Media {
  final double? voteAverage;
  final int? voteCount;
  final String? country;
  final String? trailer;
  final SeriesStatus status;
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
        status = SeriesStatus.fromString(json['status']),
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
  final int seasonId;
  final String? seriesTitle;
  final String? seasonTitle;
  final Duration skipIntro;
  final Duration skipEnding;
  final Duration? lastPlayedPosition;
  final String? url;
  final bool downloaded;
  final String ext;
  final int fileSize;
  final List<SubtitleData> subtitles;

  TVEpisode.fromJson(super.json)
      : episode = json['episode'],
        season = json['season'],
        seasonId = json['seasonId'],
        seasonTitle = json['seasonTitle'],
        seriesTitle = json['seriesTitle'],
        skipIntro = (json['skipIntro'] as int?).toDuration(),
        skipEnding = (json['skipEnding'] as int?).toDuration(),
        lastPlayedPosition = (json['lastPlayedPosition'] as int?).toDuration(),
        url = json['url'],
        downloaded = json['downloaded'] ?? false,
        ext = json['ext'],
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
  final int id;
  final String name;
  final String originalName;
  final bool adult;
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
  final int id;
  final Scrapper scrapper;

  Genre.fromJson(Json json)
      : id = json['id'],
        name = json['name'],
        scrapper = Scrapper.fromJson(json['scrapper']),
        super();
}

class Keyword {
  final String name;
  final int id;
  final Scrapper scrapper;

  Keyword.fromJson(Json json)
      : id = json['id'],
        name = json['name'],
        scrapper = Scrapper.fromJson(json['scrapper']),
        super();
}

class Studio {
  final int id;
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
  final int id;
  final int driverId;
  final String filename;
  final String driverName;
  final DriverType driverType;
  final String? driverAvatar;

  Library.fromJson(Json json)
      : id = json['id'],
        filename = json['filename'],
        driverName = json['driverName'],
        driverAvatar = json['driverAvatar'],
        driverType = DriverType.fromString(json['driverType']),
        driverId = json['driverId'];
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

  const Server({required this.id, required this.host, required this.active});

  Server.fromJson(Json json)
      : id = json['id'],
        host = json['host'],
        active = json['active'];
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
  final String url;
  final String? title;
  final String? image;
  final String? category;

  Channel.fromJson(Json json)
      : id = json['id'],
        url = json['url'],
        title = json['title'],
        image = json['image'],
        category = json['category'];
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

class Session {
  final SessionStatus status;
  final dynamic data;

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
  String? category;
  int? size;
  String? url;

  DriverFile.fromJson(Json json)
      : name = json['name'],
        category = json['category'],
        id = json['id'],
        parentId = json['parentId'],
        type = FileType.fromString(json['type']),
        createdAt = (json['createdAt'] as String?)?.toDateTime(),
        updatedAt = (json['updatedAt'] as String?)?.toDateTime(),
        size = json['size'],
        url = json['url'];
}

class PlayerHistory {
  final int id;
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
  final int mediaId;
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
  webdav,
  local;

  static DriverType fromString(String? name) {
    return switch (name) {
      'alipan' => DriverType.alipan,
      'webdav' => DriverType.webdav,
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

enum SeriesStatus {
  returningSeries,
  ended,
  released,
  unknown;

  static SeriesStatus fromString(String? name) {
    return switch (name) {
      'Returning Series' => SeriesStatus.returningSeries,
      'Ended' => SeriesStatus.ended,
      'Released' => SeriesStatus.released,
      'Unknown' => SeriesStatus.unknown,
      _ => SeriesStatus.unknown,
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

extension on JsonList {
  List<Actor> toActors() => List.generate(length, (index) => Actor.fromJson(this[index]));

  List<Genre> toGenres() => List.generate(length, (index) => Genre.fromJson(this[index]));

  List<Keyword> toKeywords() => List.generate(length, (index) => Keyword.fromJson(this[index]));

  List<Studio> toStudios() => List.generate(length, (index) => Studio.fromJson(this[index]));

  List<TVSeason> toSeasons() => List.generate(length, (index) => TVSeason.fromJson(this[index]));

  List<TVEpisode> toEpisodes() => List.generate(length, (index) => TVEpisode.fromJson(this[index]));

  List<SubtitleData> toSubtitles() => List.generate(length, (index) => SubtitleData.fromJson(this[index]));
}
