import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'api_method_channel.dart';
import 'models.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

abstract class ApiPlatform extends PlatformInterface {
  ApiPlatform() : super(token: _token);

  static final Object _token = Object();

  static ApiPlatform _instance = MethodChannelApi();

  static ApiPlatform get instance => _instance;

  static set instance(ApiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  abstract final ApiClient client;

  Uri baseUrl = Uri(
    scheme: 'http',
    host: '127.0.0.1',
    port: 38916,
  );

  Future<String?> databasePath() {
    throw UnimplementedError('databasePath() has not been implemented.');
  }

  Future<bool?> initialized() async => true;

  Future<void> syncData(String filePath) {
    throw UnimplementedError('syncData() has not been implemented.');
  }

  Future<void> rollbackData() {
    throw UnimplementedError('rollbackData() has not been implemented.');
  }

  Future<void> resetData() {
    throw UnimplementedError('resetData() has not been implemented.');
  }

  Future<void> log(int level, String message) {
    throw UnimplementedError('log() has not been implemented.');
  }

  Future<void> requestStoragePermission() async {}

  /// File Start
  Future<DriverFileInfo> fileInfo(String id) async {
    final data = await client.get<Json>('/file/info', queryParameters: {'id': id});
    final a = DriverFileInfo.fromJson(data!);
    return a;
  }

  Future<List<DriverFile>> fileList(int driverId, String parentFileId, {FileType? type, String? category}) async {
    final data = await client.post<JsonList>('/file/list', data: {
      'driverId': driverId,
      'type': type?.name,
      'category': category,
      'parentFileId': parentFileId,
    });
    return List.generate(data!.length, (index) => DriverFile.fromJson(data[index]));
  }

  Future<void> fileRename(int driverId, String fileId, String newName) {
    return client.post('/file/rename', data: {'driverId': driverId, 'fileId': fileId, 'name': newName});
  }

  Future<void> fileRemove(int driverId, String fileId) {
    return client.delete('/file/remove', data: {'driverId': driverId, 'fileId': fileId});
  }

  Future<void> fileMkdir(int driverId, String parentFileId, String name) {
    return client.put('/file/mkdir', data: {'driverId': driverId, 'parentFileId': parentFileId, 'name': name});
  }

  Future<PlaybackInfo> playbackInfo(dynamic id) async {
    final data = await client.get<Json>('/playback/info', queryParameters: {'id': id});
    return PlaybackInfo.fromJson(data!);
  }

  /// File End

  /// Player Start
  Future<List<PlayerHistory>> playerHistory() async {
    final data = await client.get<JsonList>('/player/history');
    return data!.map((e) => PlayerHistory.fromJson(e)).toList();
  }

  /// Player End

  /// Subtitle Start
  Future<List<SubtitleData>> subtitleQueryById(String id) async {
    final data = await client.get<JsonList>('/subtitle/query/id', queryParameters: {'id': id});
    return data!.map((e) => SubtitleData.fromJson(e)).toList();
  }

  Future<void> subtitleInsert(String id, SubtitleData subtitle) {
    return client.put('/subtitle/update/id', data: {
      'id': id,
      'url': subtitle.url?.toString(),
      'label': subtitle.label,
      'mimeType': subtitle.mimeType,
      'language': subtitle.language,
      'selected': subtitle.selected,
    });
  }

  Future<void> subtitleDeleteById(dynamic id) {
    return client.delete('/subtitle/delete/id', data: {'id': id});
  }

  /// Subtitle End

  /// Setting Start
  Future<SettingScraper> settingScraperQuery() async {
    final data = await client.get<Json>('/setting/scraper/query');
    return SettingScraper.fromJson(data!);
  }

  Future<void> settingScraperUpdate(SettingScraper data) {
    return client.post('/setting/scraper/update', data: data.toJson());
  }

  /// Setting End

  /// DownloadTask Start
  Future<void> downloadTaskCreate(dynamic id) async {
    await requestStoragePermission();
    return client.put('/download/task/create', data: {'id': id});
  }

  Future<void> downloadTaskPauseById(int id) {
    return client.post('/download/task/pause/id', data: {'id': id});
  }

  Future<void> downloadTaskResumeById(int id) {
    return client.post('/download/task/resume/id', data: {'id': id});
  }

  Future<void> downloadTaskDeleteById(int id, {bool deleteFile = false}) {
    return client.delete('/download/task/delete/id', data: {'id': id, 'deleteFile': deleteFile});
  }

  Future<List<DownloadTask>> downloadTaskQueryByAll() async {
    final data = await client.get<JsonList>('/download/task/query/all');
    return data!.map((e) => DownloadTask.fromJson(e)).toList();
  }

  /// DownloadTask End

  /// ScheduleTask Start
  Future<List<ScheduleTask>> scheduleTaskQueryByAll() async {
    final data = await client.get<JsonList>('/schedule/task/query/all');
    return data!.map((e) => ScheduleTask.fromJson(e)).toList();
  }

  Future<void> scheduleTaskPauseById(int id) async {
    return client.post('/schedule/task/pause/id', data: {'id': id});
  }

  Future<void> scheduleTaskResumeById(int id) async {
    return client.post('/schedule/task/resume/id', data: {'id': id});
  }

  Future<void> scheduleTaskDeleteById(int id) async {
    return client.delete('/schedule/task/delete/id', data: {'id': id});
  }

  /// ScheduleTask End

  /// Session Start
  Future<Session<T>> sessionStatus<T>(String id) async {
    final data = await client.get('/session/status', queryParameters: {'id': id});
    return Session.fromJson(data);
  }

  Future<SessionCreate> sessionCreate() {
    throw UnimplementedError('sessionCreate() has not been implemented.');
  }

  /// Session End

  /// DNS Start

  Future<List<DNSOverride>> dnsOverrideQueryAll() async {
    final data = await client.get<JsonList>('/dns/override/query/all');
    return data!.map((e) => DNSOverride.fromJson(e)).toList();
  }

  Future<void> dnsOverrideInsert({required String domain, required String ip}) {
    return client.put('/dns/override/insert', data: {'domain': domain, 'ip': ip});
  }

  Future<void> dnsOverrideUpdateById({required int id, required String domain, required String ip}) {
    return client.post('/dns/override/update/id', data: {'id': id, 'domain': domain, 'ip': ip});
  }

  Future<void> dnsOverrideDeleteById(int id) {
    return client.delete('/dns/override/delete/id', data: {'id': id});
  }

  /// DNS End

  /// Server Start

  Future<List<Server>> serverQueryAll() async {
    final data = await client.get<JsonList>('/server/query/all');
    return data!.map((e) => Server.fromJson(e)).toList();
  }

  Future<void> serverInsert(Json data) {
    return client.put('/server/insert', data: data);
  }

  Future<void> serverActiveById(int id) {
    return client.post('/server/active/id', data: {'id': id});
  }

  Future<void> serverDeleteById(int id) {
    return client.delete('/server/delete/id', data: {'id': id});
  }

  /// Server End

  /// Search Start
  Future<SearchFuzzyResult> searchFuzzy(
    String type, {
    String? filter,
    List<dynamic>? genres,
    List<dynamic>? studios,
    List<dynamic>? keywords,
    List<dynamic>? mediaCast,
    List<dynamic>? mediaCrew,
    bool? watched,
    bool? favorite,
    required int offset,
    required int limit,
  }) async {
    final data = await client.post<Json>('/search/fuzzy', data: {
      'type': type,
      'filter': filter,
      'genres': genres,
      'studios': studios,
      'keywords': keywords,
      'mediaCast': mediaCast,
      'mediaCrew': mediaCrew,
      'watched': watched,
      'favorite': favorite,
      'limit': limit,
      'offset': offset,
    });
    return SearchFuzzyResult.fromJson(data!);
  }

  /// Search End

  /// Playlist Start
  Future<List<Playlist>> playlistQueryAll() async {
    final data = await client.get<JsonList>('/playlist/query/all');
    return data!.map((e) => Playlist.fromJson(e)).toList();
  }

  Future<Playlist> playlistQueryById(dynamic id) async {
    final data = await client.get<Json>('/playlist/query/id', queryParameters: {'id': id});
    return Playlist.fromJson(data!);
  }

  Future<void> playlistInsert(Json data) {
    return client.put('/playlist/insert', data: data);
  }

  Future<void> playlistUpdateById(Json data) {
    return client.post('/playlist/update/id', data: data);
  }

  Future<void> playlistDeleteById(int id) {
    return client.delete('/playlist/delete/id', data: {'id': id});
  }

  Future<void> playlistRefreshById(int id) {
    return client.post('/playlist/refresh/id', data: {'id': id});
  }

  Future<List<Channel>> playlistChannelsQueryById(int id) async {
    final data = await client.get<JsonList>('/playlist/channels/query/id', queryParameters: {'id': id});
    return data!.map((e) => Channel.fromJson(e)).toList();
  }

  Future<List<ChannelEpgItem>> epgQueryByChannelId(int id) async {
    final data = await client.get<JsonList>('/playlist/channel/epg', queryParameters: {'id': id});
    return data!.map((e) => ChannelEpgItem.fromJson(e)).toList();
  }

  /// Playlist End

  /// Driver Start
  Future<List<DriverAccount>> driverQueryAll() async {
    final data = await client.get<JsonList>('/driver/query/all');
    return data!.map((e) => DriverAccount.fromJson(e)).toList();
  }

  Stream<dynamic> driverInsert(Json data) async* {
    throw UnimplementedError('driverInsert() has not been implemented.');
  }

  Future<Map<String, dynamic>?> driverSettingQueryById(int id) {
    return client.get<Json>('/driver/setting/query/id', queryParameters: {'id': id});
  }

  Future<void> driverSettingUpdateById(int id, Map<String, dynamic> settings) {
    return client.post('/driver/setting/update/id', data: {'id': id, 'settings': settings});
  }

  Future<void> driverDeleteById(int id) {
    return client.delete('/driver/delete/id', data: {'id': id});
  }

  /// Driver End

  /// Movie Start
  Future<List<MediaRecommendation>> movieRecommendation() async {
    final data = await client.get<JsonList>('/movie/recommendation');
    return data!.map((e) => MediaRecommendation.fromJson(e)).toList();
  }

  Future<PageData<Movie>> movieQueryAll([MediaSearchQuery? query]) async {
    final data = await client.get<Json>('/movie/query/all', queryParameters: query?.toMap());
    return PageData.fromJson(data!, (data['data'] as JsonList).map((e) => Movie.fromJson(e)));
  }

  Future<List<Movie>> movieQueryByFilter(QueryType type, dynamic id) async {
    final data = await client.get<JsonList>('/movie/query/filter', queryParameters: {'id': id, 'type': type.name});
    return data!.map((e) => Movie.fromJson(e)).toList();
  }

  Future<Movie> movieQueryById(dynamic id) async {
    final data = await client.get<Map<String, dynamic>>('/movie/query/id', queryParameters: {'id': id});
    return Movie.fromJson(data!);
  }

  Future<List<Movie>> movieNextToPlayQueryAll() async {
    final data = await client.get<JsonList>('/movie/nextToPlay/query/all');
    return data!.map((e) => Movie.fromJson(e)).toList();
  }

  Future<void> movieMetadataUpdateById(Json data) {
    return client.post('/movie/metadata/update/id', data: data);
  }

  Future<void> movieScraperById(dynamic id, String scraperId, String scraperType, String? language) {
    return client.post('/movie/scraper/id', data: {'id': id, 'scraperId': scraperId, 'scraperType': scraperType, 'language': language});
  }

  Future<List<SearchResult>> movieScraperSearch(dynamic id, String title, {String? language, String? year}) async {
    final data = await client.get<JsonList>('/movie/scraper/search', queryParameters: {'id': id, 'title': title, 'year': year, 'language': language});
    return data!.map((e) => SearchResult.fromJson(e)).toList();
  }

  Future<void> movieRenameById(dynamic id) {
    return client.post('/movie/rename/id', data: {'id': id});
  }

  Future<void> movieDeleteById(dynamic id) {
    return client.delete('/movie/delete/id', data: {'id': id});
  }

  /// Movie End

  /// TV Start
  Future<List<MediaRecommendation>> tvRecommendation() async {
    final data = await client.get<JsonList>('/tv/recommendation');
    return data!.map((e) => MediaRecommendation.fromJson(e)).toList();
  }

  /// TV Series Start
  Future<PageData<TVSeries>> tvSeriesQueryAll([MediaSearchQuery? query]) async {
    final data = await client.get<Json>('/tv/series/query/all', queryParameters: query?.toMap());
    return PageData.fromJson(data!, (data['data'] as JsonList).map((e) => TVSeries.fromJson(e)));
  }

  Future<List<TVSeries>> tvSeriesQueryByFilter(QueryType type, dynamic id) async {
    final data = await client.get<JsonList>('/tv/series/query/filter', queryParameters: {'id': id, 'type': type.name});
    return data!.map((e) => TVSeries.fromJson(e)).toList();
  }

  Future<TVSeries> tvSeriesQueryById(dynamic id) async {
    final data = await client.get<Map<String, dynamic>>('/tv/series/query/id', queryParameters: {'id': id});
    return TVSeries.fromJson(data!);
  }

  Future<List<TVEpisode>> tvSeriesNextToPlayQueryAll() async {
    final data = await client.get<JsonList>('/tv/series/nextToPlay/query/all');
    return data!.map((e) => TVEpisode.fromJson(e)).toList();
  }

  Future<void> tvSeriesScraperById(dynamic id, String scraperId, String scraperType, String? language) {
    return client.post('/tv/series/scraper/id', data: {'id': id, 'scraperId': scraperId, 'scraperType': scraperType, 'scraperLang': language});
  }

  Future<List<SearchResult>> tvSeriesScraperSearch(dynamic id, String title, {String? language, String? year}) async {
    final data = await client.get<JsonList>('/tv/series/scraper/search', queryParameters: {'id': id, 'title': title, 'year': year, 'language': language});
    return data!.map((e) => SearchResult.fromJson(e)).toList();
  }

  Future<void> tvSeriesSyncById(dynamic id) {
    return client.post('/tv/series/sync/id', data: {'id': id});
  }

  Future<void> tvSeriesMetadataUpdateById(Json data) {
    return client.post('/tv/series/metadata/update/id', data: data);
  }

  Future<void> tvSeriesRenameById(dynamic id) {
    return client.post('/tv/series/rename/id', data: {'id': id});
  }

  Future<void> tvSeriesDeleteById(dynamic id) {
    return client.delete('/tv/series/delete/id', data: {'id': id});
  }

  /// TV Series End

  /// TV Season Start
  Future<TVSeason> tvSeasonQueryById(dynamic id) async {
    final data = await client.get<Map<String, dynamic>>('/tv/season/query/id', queryParameters: {'id': id});
    return TVSeason.fromJson(data!);
  }

  Future<int> tvSeasonNumberUpdate(TVSeason season, int seasonNum) async {
    final data = await client.post('/tv/season/number/update', data: {'id': season.id, 'season': seasonNum});
    return data['id'];
  }

  Future<void> tvSeasonDeleteById(dynamic id) {
    return client.post('/tv/season/delete/id', data: {'id': id});
  }

  /// TV Season End

  /// TV Episode Start
  Future<TVEpisode> tvEpisodeQueryById(dynamic id) async {
    final data = await client.get<Map<String, dynamic>>('/tv/episode/query/id', queryParameters: {'id': id});
    return TVEpisode.fromJson(data!);
  }

  Future<void> tvEpisodeMetadataUpdateById(Json data) {
    return client.post('/tv/episode/metadata/update/id', data: data);
  }

  Future<void> tvEpisodeDeleteById(dynamic id) {
    return client.delete('/tv/episode/delete/id', data: {'id': id});
  }

  /// TV Episode End
  /// TV End

  /// Library Start
  Future<List<Library>> libraryQueryAll(LibraryType type) async {
    final data = await client.get<JsonList>('/library/query/all', queryParameters: {'type': type.name});
    return data!.map((e) => Library.fromJson(e)).toList();
  }

  Future<dynamic> libraryInsert({
    required LibraryType type,
    required int driverId,
    required String id,
    required String parentId,
    required String filename,
  }) {
    return client.put('/library/insert', data: {
      'type': type.name,
      'driverId': driverId,
      'id': id,
      'parentId': parentId,
      'filename': filename,
    }).then((value) => value['id'] as dynamic);
  }

  Future<void> libraryRefreshById(dynamic id, bool incremental) {
    return client.post('/library/refresh/id', data: {
      'id': id,
      'incremental': incremental,
    });
  }

  Future<void> libraryDeleteById(dynamic id) {
    return client.delete('/library/delete/id', data: {'id': id});
  }

  /// Library End

  /// Miscellaneous Start
  Future<List<Genre>> genreQueryAll() async {
    final data = await client.get<JsonList>('/genre/query/all');
    return data!.map((e) => Genre.fromJson(e)).toList();
  }

  Future<List<Studio>> studioQueryAll() async {
    final data = await client.get<JsonList>('/studio/query/all');
    return data!.map((e) => Studio.fromJson(e)).toList();
  }

  Future<List<Keyword>> keywordQueryAll() async {
    final data = await client.get<JsonList>('/keyword/query/all');
    return data!.map((e) => Keyword.fromJson(e)).toList();
  }

  Future<List<Actor>> actorQueryAll() async {
    final data = await client.get<JsonList>('/actor/query/all');
    return data!.map((e) => Actor.fromJson(e)).toList();
  }

  Future<List<MediaCast>> castQueryAll() async {
    final data = await client.get<JsonList>('/cast/query/all');
    return data!.map((e) => MediaCast.fromJson(e)).toList();
  }

  Future<List<MediaCrew>> crewQueryAll() async {
    final data = await client.get<JsonList>('/crew/query/all');
    return data!.map((e) => MediaCrew.fromJson(e)).toList();
  }

  Future<void> markWatched(MediaType type, dynamic id, bool watched) {
    return client.post('/markWatched/update', data: {'id': id, 'marked': watched, 'type': type.name});
  }

  Future<void> markFavorite(MediaType type, dynamic id, bool favorite) {
    return client.post('/markFavorite/update', data: {'id': id, 'marked': favorite, 'type': type.name});
  }

  Future<void> updatePlayedStatus(
    LibraryType type,
    dynamic id, {
    required Duration position,
    required Duration duration,
    String? eventType,
    dynamic others,
  }) {
    return client.post('/playedStatus/update', data: {
      'type': type.name,
      'id': id,
      'position': position.inMilliseconds,
      'duration': duration.inMilliseconds,
      'eventType': eventType,
      'others': others,
    });
  }

  Future<void> setSkipTime(SkipTimeType type, MediaType mediaType, dynamic id, Duration time) {
    return client.post('/skipTime/update', data: {
      'type': type.name,
      'mediaType': mediaType.name,
      'id': id,
      'time': time.inMilliseconds,
    });
  }

  Stream<List<NetworkDiagnotics>> networkDiagnostics() {
    throw UnimplementedError('networkDiagnostics() has not been implemented.');
  }

  Future<PageData<Log>> logQueryPage(int limit, int offset, [(int, int)? range]) async {
    final data = await client.get<Json>('/log/query/page', queryParameters: {
      'limit': limit,
      'offset': offset,
      'start': range?.$1,
      'end': range?.$2,
    });
    return PageData.fromJson(data!, (data['data'] as JsonList).map((e) => Log.fromJson(e)));
  }

  Future<UpdateData?> checkUpdate(String updateUrl, bool prerelease, Version currentVersion) {
    return Future.value();
  }

  /// Miscellaneous End

  /// Cast Start
  Stream<List<dynamic>> dlnaDiscover() {
    throw UnimplementedError('dlnaDiscover() has not been implemented.');
  }

  Future<void> dlnaSetUri(String id, Uri uri, {String? title, required String playType}) {
    return client.post('/dlna/setUrl', data: {
      'id': id,
      'uri': uri.toString(),
      'title': title,
      'playType': playType,
    });
  }

  Future<void> dlnaPlay(String id) {
    return client.post('/dlna/play', data: {'id': id});
  }

  Future<void> dlnaPause(String id) {
    return client.post('/dlna/pause', data: {'id': id});
  }

  Future<void> dlnaStop(String id) {
    return client.post('/dlna/stop', data: {'id': id});
  }

  Future<void> dlnaSeek(String id, Duration seek) {
    return client.post('/dlna/seek', data: {'id': id, 'seek': seek.inSeconds});
  }

  Future<dynamic> dlnaGetPositionInfo(String id) {
    return client.post('/dlna/getPositionInfo', data: {'id': id});
  }

  Future<dynamic> dlnaGetCurrentTransportActions(String id) {
    return client.post('/dlna/getCurrentTransportActions', data: {'id': id});
  }

  Future<dynamic> dlnaGetMediaInfo(String id) {
    return client.post('/dlna/getMediaInfo', data: {'id': id});
  }

  Future<dynamic> dlnaGetTransportInfo(String id) {
    return client.post('/dlna/getTransportInfo', data: {'id': id});
  }

  Future<void> dlnaNext(String id) {
    return client.post('/dlna/next', data: {'id': id});
  }

  Future<void> dlnaPrevious(String id) {
    return client.post('/dlna/previous', data: {'id': id});
  }

  Future<void> dlnaSetPlayMode(String id, String playMode) {
    return client.post('/dlna/setPlayMode', data: {'id': id, 'mode': playMode});
  }

  Future<dynamic> dlnaGetDeviceCapabilities(String id) {
    return client.post('/dlna/getDeviceCapabilities', data: {'id': id});
  }

  Future<void> dlnaSetMute(String id, bool mute) {
    return client.post('/dlna/setMute', data: {'id': id, 'mute': mute});
  }

  Future<dynamic> dlnaGetMute(String id) {
    return client.post('/dlna/getMute', data: {'id': id});
  }

  Future<void> dlnaSetVolume(String id, double volume) {
    return client.post('/dlna/setVolume', data: {'id': id, 'volume': volume});
  }

  Future<double> dlnaGetVolume(String id) {
    return client.post<double>('/dlna/getVolume', data: {'id': id}).then((data) => data!);
  }

  ///  Cast End
}

abstract class ApiClient {
  const ApiClient();

  Future<T?> get<T>(String path, {Json? queryParameters});

  Future<T?> post<T>(String path, {Object? data});

  Future<T?> put<T>(String path, {Object? data});

  Future<T?> delete<T>(String path, {Object? data});
}
