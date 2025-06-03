// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accountCreateFormItemLabelClientId => 'Client ID';

  @override
  String get accountCreateFormItemLabelClientPwd => 'Client Password';

  @override
  String get accountCreateFormItemLabelOauthUrl => 'OAuth Url';

  @override
  String get accountCreateFormItemLabelRefreshToken => 'Refresh Token';

  @override
  String get accountUseProxy => 'Use Proxy';

  @override
  String get actAs => 'as';

  @override
  String audioDecoder(String decoder) {
    String _temp0 = intl.Intl.selectLogic(decoder, {
      '1': 'Use Extension Decoder',
      '0': 'Not Use Extension Decoder',
      '2': 'Prefer to Use Extension Decoder',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get audioDecoderLabel => 'Audio Decode';

  @override
  String get autoCheckForUpdates => 'Auto Check For Updates';

  @override
  String autoUpdateFrequency(String frequency) {
    String _temp0 = intl.Intl.selectLogic(frequency, {
      'always': 'Always',
      'everyday': 'Everyday',
      'everyWeek': 'Every Week',
      'never': 'Never',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get buttonActivate => 'Activate';

  @override
  String get buttonAirDate => 'Air Date';

  @override
  String get buttonAll => 'All';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonCast => 'Cast';

  @override
  String get buttonCollapse => 'Collapse';

  @override
  String get buttonComplete => 'Complete';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonDownload => 'Download';

  @override
  String get buttonEdit => 'Edit';

  @override
  String get buttonEditMetadata => 'Edit Metadata';

  @override
  String get buttonExpectFavorite => 'Expect Favorite';

  @override
  String get buttonFavorite => 'Favorite';

  @override
  String get buttonHome => 'Home';

  @override
  String get buttonIncrementalSyncLibrary => 'Incremental Sync Library';

  @override
  String get buttonLastWatchedTime => 'Watched Time';

  @override
  String get buttonMarkFavorite => 'Add to Favorites';

  @override
  String get buttonMarkNotPlayed => 'Mark Not Played';

  @override
  String get buttonMarkPlayed => 'Mark Played';

  @override
  String get buttonMore => 'More';

  @override
  String get buttonName => 'Name';

  @override
  String get buttonNewFolder => 'New Folder';

  @override
  String get buttonPause => 'Pause';

  @override
  String get buttonPlay => 'Play';

  @override
  String get buttonProperty => 'Property';

  @override
  String get buttonRefresh => 'Refresh';

  @override
  String get buttonRemoveDownload => 'Remove Download';

  @override
  String get buttonRename => 'Rename';

  @override
  String get buttonReset => 'Reset';

  @override
  String get buttonResume => 'Resume';

  @override
  String get buttonSaveMediaInfoToDriver => 'Save Media Info to Driver';

  @override
  String get buttonScraperLibrary => 'Scrape the Media Library';

  @override
  String get buttonScraperMediaInfo => 'Scrape the Media Info';

  @override
  String get buttonShuffle => 'Shuffle';

  @override
  String get buttonSkipFromEnd => 'Skip Ending';

  @override
  String get buttonSkipFromStart => 'Skip Intro';

  @override
  String get buttonSubmit => 'Submit';

  @override
  String get buttonSubtitle => 'Add Subtitle';

  @override
  String get buttonSyncLibrary => 'Sync Library';

  @override
  String get buttonTrailer => 'Trailer';

  @override
  String get buttonUnmarkFavorite => 'Remove from Favorites';

  @override
  String get buttonUnwatched => 'UnWatched';

  @override
  String get buttonView => 'View';

  @override
  String get buttonWatchNow => 'Watch Now';

  @override
  String get buttonWatched => 'Watched';

  @override
  String get checkForUpdates => 'Check For Updates';

  @override
  String get checkingUpdates => 'Checking Updates...';

  @override
  String get confirmTextExit => 'Press again to exit';

  @override
  String get confirmTextLogin => 'Do you want to log in to this account?';

  @override
  String get confirmTextResetData => 'Are you sure to Reset Data?';

  @override
  String get dataSyncActionOpenSettings => 'Enable Permissions';

  @override
  String get dataSyncActionRescanBluetoothDevices => 'Rescan Bluetooth Devices';

  @override
  String get dataSyncActionRollback => 'Rollback Data';

  @override
  String get dataSyncActionSetDiscoverable => 'Set Discoverable';

  @override
  String get dataSyncAsReceiver => 'As Receiver';

  @override
  String get dataSyncAsSender => 'As Sender';

  @override
  String get dataSyncConfirmRollback => 'Do you want to roll back the data to before the last synchronization?';

  @override
  String dataSyncConfirmSync(Object device) {
    return 'Do you want to synchronize the data of device \"$device\" to this device?';
  }

  @override
  String get dataSyncTipNonBluetoothAdapter => 'Unable to obtain Bluetooth Adapter';

  @override
  String dataSyncTipOutOfDate(Object device) {
    return 'The App version of device \"\$$device\" is too old and cannot be updated. Please update it.';
  }

  @override
  String get dataSyncTipPermission => 'Please enable Bluetooth relevant permissions';

  @override
  String get dataSyncTipSyncError => 'Sync Error';

  @override
  String get deleteAccountConfirmText => 'Do you want to delete this driver?';

  @override
  String get deleteAccountTip =>
      'Delete this account will remove all the related medias(not delete the file in the driver), Are you sure to delete?';

  @override
  String get deleteConfirmText => 'Are you sure to delete?';

  @override
  String get deleteMediaGroupConfirmText =>
      'Delete Media Library will delete all the media related(not delete the files in the driver), are you sure?';

  @override
  String get deletePlaylistTip => 'Deleting a playlist will delete all its channels';

  @override
  String get dnsFormItemLabelDomain => 'Domain';

  @override
  String get dnsFormItemLabelIP => 'IP';

  @override
  String get downloaderDeleteFileConfirmText => 'Whether to delete files at the same time?';

  @override
  String get downloaderLabelDownloaded => 'Downloaded';

  @override
  String get downloaderLabelDownloading => 'Downloading';

  @override
  String driverType(String driverType) {
    String _temp0 = intl.Intl.selectLogic(driverType, {
      'alipan': 'Alipan',
      'quark': 'Quark',
      'quarktv': 'Quark TV',
      'webdav': 'Webdav',
      'emby': 'Emby',
      'jellyfin': 'Jellyfin',
      'local': 'Local',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String episodeCount(Object episodes) {
    return 'Episode $episodes';
  }

  @override
  String episodeNumber(Object episode) {
    return 'Episode $episode';
  }

  @override
  String errorCode(String code, Object message) {
    String _temp0 = intl.Intl.selectLogic(code, {
      '30001': 'No target data selected, please select an item from the list and try again',
      '40000': 'Bad Request',
      '40001': 'The M3U file exceeds the parsing limit, please adjust the file and try again.',
      '40002': 'M3U file cannot be parsed, please check if the file is correct',
      '40003': '',
      '40004': 'Http Url invalid',
      '40005': 'Unknown IO error: $message',
      '40006': 'Duplicate data, insertion failed',
      '40007': 'Other IO error: $message',
      '40008': 'A failure to read or write bytes on an I/O stream',
      '40009': 'JSON format syntax error: $message',
      '40010': 'Data format error: $message',
      '40011': 'Data missed: $message',
      '40012': 'Data format error: $message',
      '40013': 'Invalid Http Header Value: $message',
      '40014': 'This DLNA Action is not supported',
      '40015': 'Media file name is missing',
      '40016': 'Wrong account type logged in',
      '40017': 'Account data is missing',
      '40018': 'Concurrency error',
      '40019': 'Range access is not supported',
      '40020': 'Aliyun async task failed',
      '40021': 'File rename conflict',
      '40022': 'Wrong Media library type',
      '40023': 'Wrong filter type',
      '40024': '',
      '40025': 'Updated $message data, data update failed',
      '40101': 'Login verification failed: $message',
      '40102': 'Login failed, please confirm whether the Webdav address and account password are correct!',
      '40103': 'Server account error, please log in again!',
      '40301': 'Forbidden',
      '40401': 'Not Found',
      '40402': 'Api Not Found',
      '40403': 'File Not Found',
      '40404': '$message',
      '40800': 'Connect Timeout',
      '42900': 'Too Many Requests',
      '50000': 'Internal Error',
      '50401': 'Gateway timeout',
      '60001': 'No Data to Rollback',
      '60002': 'Can\'t obtain storage permission',
      '60003': 'Please ensure the Bluetooth is on',
      '60004': 'No Bluetooth Adaptor Found',
      'other': 'Unknown Error $message',
    });
    return '$_temp0';
  }

  @override
  String errorDetails(String code, Object message) {
    String _temp0 = intl.Intl.selectLogic(code, {'other': '$message'});
    return '$_temp0';
  }

  @override
  String get errorLoadData => 'Load data failed';

  @override
  String fileCategory(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'folder': 'Folder',
      'video': 'Video',
      'audio': 'Audio',
      'image': 'Image',
      'doc': 'Doc',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get filePropertyCategory => 'Category';

  @override
  String get filePropertyCreateAt => 'Create At';

  @override
  String get filePropertyDriverType => 'Driver Type';

  @override
  String get filePropertyFilename => 'Filename';

  @override
  String get filePropertySize => 'File Size';

  @override
  String get filePropertyUpdateAt => 'Update At';

  @override
  String get formItemNotRequiredHelper => 'Leave it blank if you don\'t have it';

  @override
  String get formItemNotSelectedHint => 'Not Selected';

  @override
  String get formLabelAirDate => 'Air Date';

  @override
  String get formLabelEpisode => 'Episode';

  @override
  String get formLabelFilterCategory => 'Filter Category';

  @override
  String get formLabelLanguage => 'Language';

  @override
  String get formLabelOriginalTitle => 'Original Title';

  @override
  String get formLabelPlot => 'Plot';

  @override
  String get formLabelRuntime => 'Runtime';

  @override
  String get formLabelSeason => 'Season';

  @override
  String get formLabelSelectedByDefault => 'Selected By Default';

  @override
  String get formLabelTitle => 'Title';

  @override
  String get formLabelVoteAverage => 'Vote Average';

  @override
  String get formLabelVoteCount => 'Vote Count';

  @override
  String get formLabelYear => 'Year';

  @override
  String get formValidatorEpisode => 'Please input Valid Episode Number';

  @override
  String get formValidatorIP => 'Please input Valid IP';

  @override
  String get formValidatorRequired => 'This Field is Required';

  @override
  String get formValidatorSeason => 'Please input Valid Season Number';

  @override
  String get formValidatorUrl => 'Please input Valid Url';

  @override
  String get formValidatorYear => 'Please input Valid Year';

  @override
  String gender(String gender) {
    String _temp0 = intl.Intl.selectLogic(gender, {'1': 'Female', '2': 'Male', 'other': 'Unknown'});
    return '$_temp0';
  }

  @override
  String get githubProxy => 'Github Proxy';

  @override
  String get hdrSupports => 'HDR Supports';

  @override
  String hdrType(String hdrType) {
    String _temp0 = intl.Intl.selectLogic(hdrType, {
      'invalid': 'Invalid',
      'dolbyVision': 'Dolby Vision',
      'hdr10': 'HDR 10',
      'hlg': 'Hybrid Log-Gamma',
      'hdr10Plus': 'HDR 10+',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get homeTabBrowser => 'Browser';

  @override
  String get homeTabLive => 'Live';

  @override
  String get homeTabMovie => 'Movie';

  @override
  String get homeTabSettings => 'Settings';

  @override
  String get homeTabTV => 'TV Series';

  @override
  String get iptvDefaultSource => 'IPTV Default';

  @override
  String get iptvSourceFetchFailed => 'Fetch the default IPTV source failed';

  @override
  String get isLatestVersion => 'Is Latest Version now';

  @override
  String lastCheckedUpdatesTime(Object time) {
    return 'Last checked updates time $time';
  }

  @override
  String latestVersion(Object version) {
    return 'Latest Version: V$version';
  }

  @override
  String get liveCreateFormItemHelperUrl => 'Only sources in m3u format are supported now.';

  @override
  String get liveCreateFormItemLabelTitle => 'Live Name';

  @override
  String get liveCreateFormItemLabelUrl => 'Live Url';

  @override
  String get loginFormItemLabelPwd => 'Password';

  @override
  String get loginFormItemLabelUserAgent => 'User Agent';

  @override
  String get loginFormItemLabelUsername => 'Username';

  @override
  String get minute => 'Minute';

  @override
  String get modalNotificationDeleteLoadingText => 'Deleting Data...';

  @override
  String get modalNotificationDeleteSuccessText => 'Delete Success';

  @override
  String get modalNotificationLoadingText => 'Loading Data...';

  @override
  String get modalNotificationResetSuccessText => 'Reset Success';

  @override
  String get modalNotificationSuccessText => 'Load Success';

  @override
  String get modalTitleConfirm => 'Notice';

  @override
  String get modalTitleNotification => 'Notice';

  @override
  String get modalTitleProgress => 'Notice';

  @override
  String networkStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'The network status is normal',
      'fail': 'The network status is abnormal',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get noData => 'No Data';

  @override
  String get noOverview => 'No Overview';

  @override
  String get none => 'None';

  @override
  String get pageTitleAccount => 'Account';

  @override
  String get pageTitleAccountSetting => 'Account Setting';

  @override
  String get pageTitleAdd => 'Add';

  @override
  String get pageTitleCreateAccount => 'Create Account';

  @override
  String get pageTitleCreateMovieLibrary => 'Create Movie Library';

  @override
  String get pageTitleCreateTVLibrary => 'Create TV Library';

  @override
  String get pageTitleEdit => 'Edit';

  @override
  String get pageTitleFileViewer => 'File Viewer';

  @override
  String get pageTitleFilter => 'Filter';

  @override
  String get pageTitleLogin => 'Login';

  @override
  String get playerAlipanVideoClarityTip =>
      'Select the video clarity, the video will be transcoded and compressed. If the online playback is stuck or the format is not supported, you can try to set the definition. If you want to play the original file, select NONE.';

  @override
  String get playerBroadcastLine => 'Line';

  @override
  String get playerEnableDecoderFallback => 'Enable Decoder Fallback';

  @override
  String get playerFastForwardSpeed => 'Speed';

  @override
  String get playerOpenFileWithParallelThreads => 'Open File With Parallel Threads';

  @override
  String get playerParallelsCount => 'Parallels Count';

  @override
  String get playerShowThumbnails => 'Show Thumbnails';

  @override
  String get playerSliceSize => 'Slice Size';

  @override
  String get playerUseHardwareCodec => 'Use Hardware Codec';

  @override
  String get playerVideoClarity => 'Video Clarity';

  @override
  String queryType(String queryType) {
    String _temp0 = intl.Intl.selectLogic(queryType, {
      'genre': 'Genre',
      'studio': 'Studio',
      'keyword': 'Keyword',
      'actor': 'Actor',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get refreshMediaGroupButton => 'Refresh Media Library';

  @override
  String scheduleTaskScrapeTitle(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'idle': 'Sync Idle',
      'running': 'Scraping',
      'paused': 'Scrape Paused',
      'completed': 'Scrape Completed',
      'error': 'Scrape Failed',
      'other': '$status',
    });
    return '$_temp0';
  }

  @override
  String scheduleTaskSyncSubtitle(Object data) {
    return '$data files have been synchronized';
  }

  @override
  String scheduleTaskSyncTitle(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'idle': 'Sync Idle',
      'running': 'Syncing',
      'paused': 'Sync Paused',
      'completed': 'Sync Completed',
      'error': 'Sync Failed',
      'other': '$status',
    });
    return '$_temp0';
  }

  @override
  String scraperBehavior(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'exact': 'Exactly Match',
      'chooseFirst': 'Choose First',
      'skip': 'Skip',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get search => 'Search';

  @override
  String get searchFilterTitle => 'Filters';

  @override
  String get searchHint => 'Search for movies, TV series, actors and more';

  @override
  String get searchMultiResultTip => 'Please select a search result';

  @override
  String get searchNoResultTip => 'There\'s no result for this title, you can rename it and search again';

  @override
  String seasonCount(Object seasons) {
    return '$seasons Seasons';
  }

  @override
  String seasonNumber(Object season) {
    return 'Season $season';
  }

  @override
  String get second => 'Second';

  @override
  String get selectADriver => 'Please Select a Driver';

  @override
  String get selectADriverAccount => 'Please Select a Driver Account';

  @override
  String seriesStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'returningSeries': 'Returning Series',
      'ended': 'Ended',
      'released': 'Released',
      'other': '$status',
    });
    return '$_temp0';
  }

  @override
  String get serverFormItemLabelServer => 'Server Address';

  @override
  String get serverFormItemLabelServerType => 'Server Type';

  @override
  String get sessionStatusConnected => 'Please Fill the Form on your Phone';

  @override
  String get sessionStatusCreated => 'Please Scan the QR Code';

  @override
  String get sessionStatusExpired => 'Expired';

  @override
  String sessionStatusFailed(Object error) {
    return 'Operation Failed, $error';
  }

  @override
  String get sessionStatusFinished => 'Operation Completed, Wait for Refresh';

  @override
  String get sessionStatusPending => 'Pending';

  @override
  String get sessionStatusUnknown => 'Unknown Error';

  @override
  String get settingsItemAccount => 'Account';

  @override
  String get settingsItemAutoForceLandscape => 'Auto landscape play';

  @override
  String get settingsItemAutoPip => 'Auto Enter PIP mode';

  @override
  String get settingsItemAutoPipTip =>
      'When the player is in full screen mode, exit to the system desktop and the picture-in-picture mode will be automatically turned on.';

  @override
  String get settingsItemAutoPlay => 'Auto Play';

  @override
  String get settingsItemDNS => 'DNS';

  @override
  String get settingsItemDataReset => 'Data Reset';

  @override
  String get settingsItemDataSettings => 'Data Settings';

  @override
  String get settingsItemDataSync => 'Data Sync';

  @override
  String get settingsItemDisplaySettings => 'Display Settings';

  @override
  String get settingsItemDisplaySize => 'Display Size';

  @override
  String get settingsItemDownload => 'Download Management';

  @override
  String get settingsItemFeedback => 'Feedback';

  @override
  String get settingsItemInfo => 'Info';

  @override
  String get settingsItemLanguage => 'System Language';

  @override
  String get settingsItemLog => 'Log';

  @override
  String get settingsItemMovie => 'Movie Folder';

  @override
  String get settingsItemNetworkDiagnotics => 'Network Diagnotics';

  @override
  String get settingsItemNfoEnabled => 'NFO Enabled';

  @override
  String get settingsItemOthers => 'Others Settings';

  @override
  String get settingsItemPlayerHistory => 'Player History';

  @override
  String get settingsItemPlayerSettings => 'Player Settings';

  @override
  String get settingsItemProxySettings => 'Proxy Settings';

  @override
  String get settingsItemScraperBehavior => 'Scraper Behavior';

  @override
  String get settingsItemScraperBehaviorDescription => 'How to select when multiple data are searched?';

  @override
  String get settingsItemScraperSettings => 'Scraper Settings';

  @override
  String get settingsItemServer => 'Server Settings';

  @override
  String get settingsItemShortcutSettings => 'Shortcut Settings';

  @override
  String get settingsItemShortcuts => 'Shortcuts';

  @override
  String settingsItemShortcutsKey(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'menu': 'Menu',
      'previousChannel': 'Previous Channel',
      'nextChannel': 'Next Channel',
      'switchLinePanel': 'Switch Line Panel',
      'channelsPanel': 'Channels Panel',
      'other': '$key',
    });
    return '$_temp0';
  }

  @override
  String get settingsItemSponsor => 'Sponsor';

  @override
  String get settingsItemTV => 'TV Folder';

  @override
  String get settingsItemTheme => 'Theme';

  @override
  String get settingsItemTmdbEnabled => 'TMDB Enabled';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sponsorMessage =>
      'Development and maintenance are not easy. If you find this project useful, you might as well use WeChat to scan the QR code above to support this software!';

  @override
  String get sponsorThanksMessage => '❤ Special thanks to the following friends for their rewards!';

  @override
  String get sponsorTipMessage => 'If there is any omission, please contact me on Github to add';

  @override
  String get subtitleFormItemLabelLanguage => 'Subtitle Language';

  @override
  String get subtitleFormItemLabelType => 'Subtitle Type';

  @override
  String get subtitleFormItemLabelUrl => 'URL';

  @override
  String get subtitleSetting => 'Subtitle Setting';

  @override
  String get subtitleSettingBackgroundColor => 'Background Color';

  @override
  String get subtitleSettingEdgeColor => 'Edge Color';

  @override
  String get subtitleSettingExample => 'Subtitle style example';

  @override
  String get subtitleSettingForegroundColor => 'Text Color';

  @override
  String get subtitleSettingWindowColor => 'Window Color';

  @override
  String systemLanguage(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {'zh': '简体中文', 'en': 'English', 'other': 'Auto'});
    return '$_temp0';
  }

  @override
  String systemTheme(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {'light': 'Light', 'dark': 'Dark', 'other': 'Auto'});
    return '$_temp0';
  }

  @override
  String get tagAll => 'All';

  @override
  String get tagFavorite => 'Favorite';

  @override
  String get tagNew => 'New';

  @override
  String get tagNewAdd => 'New Add';

  @override
  String get tagNewRelease => 'New Release';

  @override
  String get tagShowLess => 'Show Less';

  @override
  String get tagShowMore => 'Show More';

  @override
  String get tagUnknown => 'Unknown';

  @override
  String timeAgo(Object time) {
    return '$time Ago';
  }

  @override
  String get tipsForCopiedSuccessfully => 'Copied successfully';

  @override
  String get tipsForDownload => 'Downloading...';

  @override
  String get tipsStayTuned => 'Stay tuned!';

  @override
  String get titleCast => 'Cast';

  @override
  String get titleCastCrew => 'Cast and Crew';

  @override
  String get titleCrew => 'Crew';

  @override
  String get titleEditM3U => 'Select a M3U File';

  @override
  String get titleEditMetadata => 'Edit Metadata';

  @override
  String get titleEditSubtitle => 'Select a Subtitle File';

  @override
  String get titleGenre => 'Genre';

  @override
  String get titleKeyword => 'Keyword';

  @override
  String get titleMoreFrom => 'More From';

  @override
  String get titleNext => 'Next';

  @override
  String get titlePlaylist => 'Playlist';

  @override
  String get titleScan => 'Scan';

  @override
  String get titleSeasons => 'Seasons';

  @override
  String get titleSelectAnAccount => 'Please Select an Account';

  @override
  String get titleStudios => 'Studios';

  @override
  String unitDay(num time) {
    String _temp0 = intl.Intl.pluralLogic(time, locale: localeName, other: '$time Days', one: '1 Day');
    return '$_temp0';
  }

  @override
  String unitHour(num time) {
    String _temp0 = intl.Intl.pluralLogic(time, locale: localeName, other: '$time Hours', one: '1 Hour');
    return '$_temp0';
  }

  @override
  String unitMinute(num time) {
    String _temp0 = intl.Intl.pluralLogic(time, locale: localeName, other: '$time Minutes', one: '1 Minute');
    return '$_temp0';
  }

  @override
  String unitMonth(num time) {
    String _temp0 = intl.Intl.pluralLogic(time, locale: localeName, other: '$time Months', one: '1 Month');
    return '$_temp0';
  }

  @override
  String unitSecond(num time) {
    String _temp0 = intl.Intl.pluralLogic(time, locale: localeName, other: '$time Seconds', one: '1 Second');
    return '$_temp0';
  }

  @override
  String unitYear(num time) {
    String _temp0 = intl.Intl.pluralLogic(time, locale: localeName, other: '$time Years', one: '1 Year');
    return '$_temp0';
  }

  @override
  String get unselect => 'Unselect';

  @override
  String get updateFailed => 'Update Failed';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updatePrerelease => 'Update Prerelease Version';

  @override
  String get updating => 'Updating';

  @override
  String get versionDeprecatedTip => 'The current version is too low, please update to the latest version';

  @override
  String get videoSettingsAudio => 'Audio';

  @override
  String get videoSettingsSpeeding => 'Speed';

  @override
  String get videoSettingsSubtitle => 'Subtitle';

  @override
  String get videoSettingsVideo => 'Video';

  @override
  String get videoSize => 'Video Size';

  @override
  String get watchNow => 'Watch Now';

  @override
  String get willSkipEnding => 'Will Skip the Ending';
}
