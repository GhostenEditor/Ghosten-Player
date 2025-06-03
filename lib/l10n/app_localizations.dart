import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('zh')];

  /// No description provided for @accountCreateFormItemLabelClientId.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get accountCreateFormItemLabelClientId;

  /// No description provided for @accountCreateFormItemLabelClientPwd.
  ///
  /// In en, this message translates to:
  /// **'Client Password'**
  String get accountCreateFormItemLabelClientPwd;

  /// No description provided for @accountCreateFormItemLabelOauthUrl.
  ///
  /// In en, this message translates to:
  /// **'OAuth Url'**
  String get accountCreateFormItemLabelOauthUrl;

  /// No description provided for @accountCreateFormItemLabelRefreshToken.
  ///
  /// In en, this message translates to:
  /// **'Refresh Token'**
  String get accountCreateFormItemLabelRefreshToken;

  /// No description provided for @accountUseProxy.
  ///
  /// In en, this message translates to:
  /// **'Use Proxy'**
  String get accountUseProxy;

  /// No description provided for @actAs.
  ///
  /// In en, this message translates to:
  /// **'as'**
  String get actAs;

  /// No description provided for @audioDecoder.
  ///
  /// In en, this message translates to:
  /// **'{decoder, select, 1{Use Extension Decoder} 0{Not Use Extension Decoder} 2{Prefer to Use Extension Decoder} other{Unknown}}'**
  String audioDecoder(String decoder);

  /// No description provided for @audioDecoderLabel.
  ///
  /// In en, this message translates to:
  /// **'Audio Decode'**
  String get audioDecoderLabel;

  /// No description provided for @autoCheckForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Auto Check For Updates'**
  String get autoCheckForUpdates;

  /// No description provided for @autoUpdateFrequency.
  ///
  /// In en, this message translates to:
  /// **'{frequency, select, always{Always} everyday{Everyday} everyWeek{Every Week} never{Never} other{Unknown}}'**
  String autoUpdateFrequency(String frequency);

  /// No description provided for @buttonActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get buttonActivate;

  /// No description provided for @buttonAirDate.
  ///
  /// In en, this message translates to:
  /// **'Air Date'**
  String get buttonAirDate;

  /// No description provided for @buttonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get buttonAll;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonCast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get buttonCast;

  /// No description provided for @buttonCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get buttonCollapse;

  /// No description provided for @buttonComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get buttonComplete;

  /// No description provided for @buttonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonConfirm;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get buttonDownload;

  /// No description provided for @buttonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

  /// No description provided for @buttonEditMetadata.
  ///
  /// In en, this message translates to:
  /// **'Edit Metadata'**
  String get buttonEditMetadata;

  /// No description provided for @buttonExpectFavorite.
  ///
  /// In en, this message translates to:
  /// **'Expect Favorite'**
  String get buttonExpectFavorite;

  /// No description provided for @buttonFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get buttonFavorite;

  /// No description provided for @buttonHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get buttonHome;

  /// No description provided for @buttonIncrementalSyncLibrary.
  ///
  /// In en, this message translates to:
  /// **'Incremental Sync Library'**
  String get buttonIncrementalSyncLibrary;

  /// No description provided for @buttonLastWatchedTime.
  ///
  /// In en, this message translates to:
  /// **'Watched Time'**
  String get buttonLastWatchedTime;

  /// No description provided for @buttonMarkFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get buttonMarkFavorite;

  /// No description provided for @buttonMarkNotPlayed.
  ///
  /// In en, this message translates to:
  /// **'Mark Not Played'**
  String get buttonMarkNotPlayed;

  /// No description provided for @buttonMarkPlayed.
  ///
  /// In en, this message translates to:
  /// **'Mark Played'**
  String get buttonMarkPlayed;

  /// No description provided for @buttonMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get buttonMore;

  /// No description provided for @buttonName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get buttonName;

  /// No description provided for @buttonNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New Folder'**
  String get buttonNewFolder;

  /// No description provided for @buttonPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get buttonPause;

  /// No description provided for @buttonPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get buttonPlay;

  /// No description provided for @buttonProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get buttonProperty;

  /// No description provided for @buttonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get buttonRefresh;

  /// No description provided for @buttonRemoveDownload.
  ///
  /// In en, this message translates to:
  /// **'Remove Download'**
  String get buttonRemoveDownload;

  /// No description provided for @buttonRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get buttonRename;

  /// No description provided for @buttonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get buttonReset;

  /// No description provided for @buttonResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get buttonResume;

  /// No description provided for @buttonSaveMediaInfoToDriver.
  ///
  /// In en, this message translates to:
  /// **'Save Media Info to Driver'**
  String get buttonSaveMediaInfoToDriver;

  /// No description provided for @buttonScraperLibrary.
  ///
  /// In en, this message translates to:
  /// **'Scrape the Media Library'**
  String get buttonScraperLibrary;

  /// No description provided for @buttonScraperMediaInfo.
  ///
  /// In en, this message translates to:
  /// **'Scrape the Media Info'**
  String get buttonScraperMediaInfo;

  /// No description provided for @buttonShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get buttonShuffle;

  /// No description provided for @buttonSkipFromEnd.
  ///
  /// In en, this message translates to:
  /// **'Skip Ending'**
  String get buttonSkipFromEnd;

  /// No description provided for @buttonSkipFromStart.
  ///
  /// In en, this message translates to:
  /// **'Skip Intro'**
  String get buttonSkipFromStart;

  /// No description provided for @buttonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get buttonSubmit;

  /// No description provided for @buttonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add Subtitle'**
  String get buttonSubtitle;

  /// No description provided for @buttonSyncLibrary.
  ///
  /// In en, this message translates to:
  /// **'Sync Library'**
  String get buttonSyncLibrary;

  /// No description provided for @buttonTrailer.
  ///
  /// In en, this message translates to:
  /// **'Trailer'**
  String get buttonTrailer;

  /// No description provided for @buttonUnmarkFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get buttonUnmarkFavorite;

  /// No description provided for @buttonUnwatched.
  ///
  /// In en, this message translates to:
  /// **'UnWatched'**
  String get buttonUnwatched;

  /// No description provided for @buttonView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get buttonView;

  /// No description provided for @buttonWatchNow.
  ///
  /// In en, this message translates to:
  /// **'Watch Now'**
  String get buttonWatchNow;

  /// No description provided for @buttonWatched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get buttonWatched;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check For Updates'**
  String get checkForUpdates;

  /// No description provided for @checkingUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking Updates...'**
  String get checkingUpdates;

  /// No description provided for @confirmTextExit.
  ///
  /// In en, this message translates to:
  /// **'Press again to exit'**
  String get confirmTextExit;

  /// No description provided for @confirmTextLogin.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log in to this account?'**
  String get confirmTextLogin;

  /// No description provided for @confirmTextResetData.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to Reset Data?'**
  String get confirmTextResetData;

  /// No description provided for @dataSyncActionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Enable Permissions'**
  String get dataSyncActionOpenSettings;

  /// No description provided for @dataSyncActionRescanBluetoothDevices.
  ///
  /// In en, this message translates to:
  /// **'Rescan Bluetooth Devices'**
  String get dataSyncActionRescanBluetoothDevices;

  /// No description provided for @dataSyncActionRollback.
  ///
  /// In en, this message translates to:
  /// **'Rollback Data'**
  String get dataSyncActionRollback;

  /// No description provided for @dataSyncActionSetDiscoverable.
  ///
  /// In en, this message translates to:
  /// **'Set Discoverable'**
  String get dataSyncActionSetDiscoverable;

  /// No description provided for @dataSyncAsReceiver.
  ///
  /// In en, this message translates to:
  /// **'As Receiver'**
  String get dataSyncAsReceiver;

  /// No description provided for @dataSyncAsSender.
  ///
  /// In en, this message translates to:
  /// **'As Sender'**
  String get dataSyncAsSender;

  /// No description provided for @dataSyncConfirmRollback.
  ///
  /// In en, this message translates to:
  /// **'Do you want to roll back the data to before the last synchronization?'**
  String get dataSyncConfirmRollback;

  /// No description provided for @dataSyncConfirmSync.
  ///
  /// In en, this message translates to:
  /// **'Do you want to synchronize the data of device \"{device}\" to this device?'**
  String dataSyncConfirmSync(Object device);

  /// No description provided for @dataSyncTipNonBluetoothAdapter.
  ///
  /// In en, this message translates to:
  /// **'Unable to obtain Bluetooth Adapter'**
  String get dataSyncTipNonBluetoothAdapter;

  /// No description provided for @dataSyncTipOutOfDate.
  ///
  /// In en, this message translates to:
  /// **'The App version of device \"\${device}\" is too old and cannot be updated. Please update it.'**
  String dataSyncTipOutOfDate(Object device);

  /// No description provided for @dataSyncTipPermission.
  ///
  /// In en, this message translates to:
  /// **'Please enable Bluetooth relevant permissions'**
  String get dataSyncTipPermission;

  /// No description provided for @dataSyncTipSyncError.
  ///
  /// In en, this message translates to:
  /// **'Sync Error'**
  String get dataSyncTipSyncError;

  /// No description provided for @deleteAccountConfirmText.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this driver?'**
  String get deleteAccountConfirmText;

  /// No description provided for @deleteAccountTip.
  ///
  /// In en, this message translates to:
  /// **'Delete this account will remove all the related medias(not delete the file in the driver), Are you sure to delete?'**
  String get deleteAccountTip;

  /// No description provided for @deleteConfirmText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to delete?'**
  String get deleteConfirmText;

  /// No description provided for @deleteMediaGroupConfirmText.
  ///
  /// In en, this message translates to:
  /// **'Delete Media Library will delete all the media related(not delete the files in the driver), are you sure?'**
  String get deleteMediaGroupConfirmText;

  /// No description provided for @deletePlaylistTip.
  ///
  /// In en, this message translates to:
  /// **'Deleting a playlist will delete all its channels'**
  String get deletePlaylistTip;

  /// No description provided for @dnsFormItemLabelDomain.
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get dnsFormItemLabelDomain;

  /// No description provided for @dnsFormItemLabelIP.
  ///
  /// In en, this message translates to:
  /// **'IP'**
  String get dnsFormItemLabelIP;

  /// No description provided for @downloaderDeleteFileConfirmText.
  ///
  /// In en, this message translates to:
  /// **'Whether to delete files at the same time?'**
  String get downloaderDeleteFileConfirmText;

  /// No description provided for @downloaderLabelDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaderLabelDownloaded;

  /// No description provided for @downloaderLabelDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloaderLabelDownloading;

  /// No description provided for @driverType.
  ///
  /// In en, this message translates to:
  /// **'{driverType, select, alipan{Alipan} quark{Quark} quarktv{Quark TV} webdav{Webdav} emby{Emby} jellyfin{Jellyfin} local{Local} other{Unknown}}'**
  String driverType(String driverType);

  /// No description provided for @episodeCount.
  ///
  /// In en, this message translates to:
  /// **'Episode {episodes}'**
  String episodeCount(Object episodes);

  /// No description provided for @episodeNumber.
  ///
  /// In en, this message translates to:
  /// **'Episode {episode}'**
  String episodeNumber(Object episode);

  /// No description provided for @errorCode.
  ///
  /// In en, this message translates to:
  /// **'{code, select, 30001{No target data selected, please select an item from the list and try again} 40000{Bad Request} 40001{The M3U file exceeds the parsing limit, please adjust the file and try again.} 40002{M3U file cannot be parsed, please check if the file is correct} 40003{} 40004{Http Url invalid} 40005{Unknown IO error: {message}} 40006{Duplicate data, insertion failed} 40007{Other IO error: {message}} 40008{A failure to read or write bytes on an I/O stream} 40009{JSON format syntax error: {message}} 40010{Data format error: {message}} 40011{Data missed: {message}} 40012{Data format error: {message}} 40013{Invalid Http Header Value: {message}} 40014{This DLNA Action is not supported} 40015{Media file name is missing} 40016{Wrong account type logged in} 40017{Account data is missing} 40018{Concurrency error} 40019{Range access is not supported} 40020{Aliyun async task failed} 40021{File rename conflict} 40022{Wrong Media library type} 40023{Wrong filter type} 40024{} 40025{Updated {message} data, data update failed} 40101{Login verification failed: {message}} 40102{Login failed, please confirm whether the Webdav address and account password are correct!}  40103{Server account error, please log in again!} 40301{Forbidden} 40401{Not Found} 40402{Api Not Found} 40403{File Not Found} 40404{{message}} 40800{Connect Timeout} 42900{Too Many Requests} 50000{Internal Error} 50401{Gateway timeout} 60001{No Data to Rollback} 60002{Can\'t obtain storage permission} 60003{Please ensure the Bluetooth is on} 60004{No Bluetooth Adaptor Found} other{Unknown Error {message}}}'**
  String errorCode(String code, Object message);

  /// No description provided for @errorDetails.
  ///
  /// In en, this message translates to:
  /// **'{code, select, other{{message}}}'**
  String errorDetails(String code, Object message);

  /// No description provided for @errorLoadData.
  ///
  /// In en, this message translates to:
  /// **'Load data failed'**
  String get errorLoadData;

  /// No description provided for @fileCategory.
  ///
  /// In en, this message translates to:
  /// **'{category, select, folder{Folder} video{Video} audio{Audio} image{Image} doc{Doc} other{Unknown}}'**
  String fileCategory(String category);

  /// No description provided for @filePropertyCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filePropertyCategory;

  /// No description provided for @filePropertyCreateAt.
  ///
  /// In en, this message translates to:
  /// **'Create At'**
  String get filePropertyCreateAt;

  /// No description provided for @filePropertyDriverType.
  ///
  /// In en, this message translates to:
  /// **'Driver Type'**
  String get filePropertyDriverType;

  /// No description provided for @filePropertyFilename.
  ///
  /// In en, this message translates to:
  /// **'Filename'**
  String get filePropertyFilename;

  /// No description provided for @filePropertySize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get filePropertySize;

  /// No description provided for @filePropertyUpdateAt.
  ///
  /// In en, this message translates to:
  /// **'Update At'**
  String get filePropertyUpdateAt;

  /// No description provided for @formItemNotRequiredHelper.
  ///
  /// In en, this message translates to:
  /// **'Leave it blank if you don\'t have it'**
  String get formItemNotRequiredHelper;

  /// No description provided for @formItemNotSelectedHint.
  ///
  /// In en, this message translates to:
  /// **'Not Selected'**
  String get formItemNotSelectedHint;

  /// No description provided for @formLabelAirDate.
  ///
  /// In en, this message translates to:
  /// **'Air Date'**
  String get formLabelAirDate;

  /// No description provided for @formLabelEpisode.
  ///
  /// In en, this message translates to:
  /// **'Episode'**
  String get formLabelEpisode;

  /// No description provided for @formLabelFilterCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter Category'**
  String get formLabelFilterCategory;

  /// No description provided for @formLabelLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get formLabelLanguage;

  /// No description provided for @formLabelOriginalTitle.
  ///
  /// In en, this message translates to:
  /// **'Original Title'**
  String get formLabelOriginalTitle;

  /// No description provided for @formLabelPlot.
  ///
  /// In en, this message translates to:
  /// **'Plot'**
  String get formLabelPlot;

  /// No description provided for @formLabelRuntime.
  ///
  /// In en, this message translates to:
  /// **'Runtime'**
  String get formLabelRuntime;

  /// No description provided for @formLabelSeason.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get formLabelSeason;

  /// No description provided for @formLabelSelectedByDefault.
  ///
  /// In en, this message translates to:
  /// **'Selected By Default'**
  String get formLabelSelectedByDefault;

  /// No description provided for @formLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get formLabelTitle;

  /// No description provided for @formLabelVoteAverage.
  ///
  /// In en, this message translates to:
  /// **'Vote Average'**
  String get formLabelVoteAverage;

  /// No description provided for @formLabelVoteCount.
  ///
  /// In en, this message translates to:
  /// **'Vote Count'**
  String get formLabelVoteCount;

  /// No description provided for @formLabelYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get formLabelYear;

  /// No description provided for @formValidatorEpisode.
  ///
  /// In en, this message translates to:
  /// **'Please input Valid Episode Number'**
  String get formValidatorEpisode;

  /// No description provided for @formValidatorIP.
  ///
  /// In en, this message translates to:
  /// **'Please input Valid IP'**
  String get formValidatorIP;

  /// No description provided for @formValidatorRequired.
  ///
  /// In en, this message translates to:
  /// **'This Field is Required'**
  String get formValidatorRequired;

  /// No description provided for @formValidatorSeason.
  ///
  /// In en, this message translates to:
  /// **'Please input Valid Season Number'**
  String get formValidatorSeason;

  /// No description provided for @formValidatorUrl.
  ///
  /// In en, this message translates to:
  /// **'Please input Valid Url'**
  String get formValidatorUrl;

  /// No description provided for @formValidatorYear.
  ///
  /// In en, this message translates to:
  /// **'Please input Valid Year'**
  String get formValidatorYear;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'{gender, select, 1{Female} 2{Male} other{Unknown}}'**
  String gender(String gender);

  /// No description provided for @githubProxy.
  ///
  /// In en, this message translates to:
  /// **'Github Proxy'**
  String get githubProxy;

  /// No description provided for @hdrSupports.
  ///
  /// In en, this message translates to:
  /// **'HDR Supports'**
  String get hdrSupports;

  /// No description provided for @hdrType.
  ///
  /// In en, this message translates to:
  /// **'{hdrType, select, invalid{Invalid} dolbyVision{Dolby Vision} hdr10{HDR 10} hlg{Hybrid Log-Gamma} hdr10Plus{HDR 10+} other{Unknown}}'**
  String hdrType(String hdrType);

  /// No description provided for @homeTabBrowser.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get homeTabBrowser;

  /// No description provided for @homeTabLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get homeTabLive;

  /// No description provided for @homeTabMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get homeTabMovie;

  /// No description provided for @homeTabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeTabSettings;

  /// No description provided for @homeTabTV.
  ///
  /// In en, this message translates to:
  /// **'TV Series'**
  String get homeTabTV;

  /// No description provided for @iptvDefaultSource.
  ///
  /// In en, this message translates to:
  /// **'IPTV Default'**
  String get iptvDefaultSource;

  /// No description provided for @iptvSourceFetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch the default IPTV source failed'**
  String get iptvSourceFetchFailed;

  /// No description provided for @isLatestVersion.
  ///
  /// In en, this message translates to:
  /// **'Is Latest Version now'**
  String get isLatestVersion;

  /// No description provided for @lastCheckedUpdatesTime.
  ///
  /// In en, this message translates to:
  /// **'Last checked updates time {time}'**
  String lastCheckedUpdatesTime(Object time);

  /// No description provided for @latestVersion.
  ///
  /// In en, this message translates to:
  /// **'Latest Version: V{version}'**
  String latestVersion(Object version);

  /// No description provided for @liveCreateFormItemHelperUrl.
  ///
  /// In en, this message translates to:
  /// **'Only sources in m3u format are supported now.'**
  String get liveCreateFormItemHelperUrl;

  /// No description provided for @liveCreateFormItemLabelTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Name'**
  String get liveCreateFormItemLabelTitle;

  /// No description provided for @liveCreateFormItemLabelUrl.
  ///
  /// In en, this message translates to:
  /// **'Live Url'**
  String get liveCreateFormItemLabelUrl;

  /// No description provided for @loginFormItemLabelPwd.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginFormItemLabelPwd;

  /// No description provided for @loginFormItemLabelUserAgent.
  ///
  /// In en, this message translates to:
  /// **'User Agent'**
  String get loginFormItemLabelUserAgent;

  /// No description provided for @loginFormItemLabelUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get loginFormItemLabelUsername;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get minute;

  /// No description provided for @modalNotificationDeleteLoadingText.
  ///
  /// In en, this message translates to:
  /// **'Deleting Data...'**
  String get modalNotificationDeleteLoadingText;

  /// No description provided for @modalNotificationDeleteSuccessText.
  ///
  /// In en, this message translates to:
  /// **'Delete Success'**
  String get modalNotificationDeleteSuccessText;

  /// No description provided for @modalNotificationLoadingText.
  ///
  /// In en, this message translates to:
  /// **'Loading Data...'**
  String get modalNotificationLoadingText;

  /// No description provided for @modalNotificationResetSuccessText.
  ///
  /// In en, this message translates to:
  /// **'Reset Success'**
  String get modalNotificationResetSuccessText;

  /// No description provided for @modalNotificationSuccessText.
  ///
  /// In en, this message translates to:
  /// **'Load Success'**
  String get modalNotificationSuccessText;

  /// No description provided for @modalTitleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get modalTitleConfirm;

  /// No description provided for @modalTitleNotification.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get modalTitleNotification;

  /// No description provided for @modalTitleProgress.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get modalTitleProgress;

  /// No description provided for @networkStatus.
  ///
  /// In en, this message translates to:
  /// **'{status, select, success{The network status is normal} fail{The network status is abnormal} other{Unknown}}'**
  String networkStatus(String status);

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @noOverview.
  ///
  /// In en, this message translates to:
  /// **'No Overview'**
  String get noOverview;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @pageTitleAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get pageTitleAccount;

  /// No description provided for @pageTitleAccountSetting.
  ///
  /// In en, this message translates to:
  /// **'Account Setting'**
  String get pageTitleAccountSetting;

  /// No description provided for @pageTitleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get pageTitleAdd;

  /// No description provided for @pageTitleCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get pageTitleCreateAccount;

  /// No description provided for @pageTitleCreateMovieLibrary.
  ///
  /// In en, this message translates to:
  /// **'Create Movie Library'**
  String get pageTitleCreateMovieLibrary;

  /// No description provided for @pageTitleCreateTVLibrary.
  ///
  /// In en, this message translates to:
  /// **'Create TV Library'**
  String get pageTitleCreateTVLibrary;

  /// No description provided for @pageTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get pageTitleEdit;

  /// No description provided for @pageTitleFileViewer.
  ///
  /// In en, this message translates to:
  /// **'File Viewer'**
  String get pageTitleFileViewer;

  /// No description provided for @pageTitleFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get pageTitleFilter;

  /// No description provided for @pageTitleLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get pageTitleLogin;

  /// No description provided for @playerAlipanVideoClarityTip.
  ///
  /// In en, this message translates to:
  /// **'Select the video clarity, the video will be transcoded and compressed. If the online playback is stuck or the format is not supported, you can try to set the definition. If you want to play the original file, select NONE.'**
  String get playerAlipanVideoClarityTip;

  /// No description provided for @playerBroadcastLine.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get playerBroadcastLine;

  /// No description provided for @playerEnableDecoderFallback.
  ///
  /// In en, this message translates to:
  /// **'Enable Decoder Fallback'**
  String get playerEnableDecoderFallback;

  /// No description provided for @playerFastForwardSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get playerFastForwardSpeed;

  /// No description provided for @playerOpenFileWithParallelThreads.
  ///
  /// In en, this message translates to:
  /// **'Open File With Parallel Threads'**
  String get playerOpenFileWithParallelThreads;

  /// No description provided for @playerParallelsCount.
  ///
  /// In en, this message translates to:
  /// **'Parallels Count'**
  String get playerParallelsCount;

  /// No description provided for @playerShowThumbnails.
  ///
  /// In en, this message translates to:
  /// **'Show Thumbnails'**
  String get playerShowThumbnails;

  /// No description provided for @playerSliceSize.
  ///
  /// In en, this message translates to:
  /// **'Slice Size'**
  String get playerSliceSize;

  /// No description provided for @playerUseHardwareCodec.
  ///
  /// In en, this message translates to:
  /// **'Use Hardware Codec'**
  String get playerUseHardwareCodec;

  /// No description provided for @playerVideoClarity.
  ///
  /// In en, this message translates to:
  /// **'Video Clarity'**
  String get playerVideoClarity;

  /// No description provided for @queryType.
  ///
  /// In en, this message translates to:
  /// **'{queryType, select, genre{Genre} studio{Studio} keyword{Keyword} actor{Actor} other{Unknown}}'**
  String queryType(String queryType);

  /// No description provided for @refreshMediaGroupButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh Media Library'**
  String get refreshMediaGroupButton;

  /// No description provided for @scheduleTaskScrapeTitle.
  ///
  /// In en, this message translates to:
  /// **'{status, select, idle{Sync Idle} running{Scraping} paused{Scrape Paused} completed{Scrape Completed} error{Scrape Failed} other{{status}}}'**
  String scheduleTaskScrapeTitle(String status);

  /// No description provided for @scheduleTaskSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{data} files have been synchronized'**
  String scheduleTaskSyncSubtitle(Object data);

  /// No description provided for @scheduleTaskSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'{status, select, idle{Sync Idle} running{Syncing} paused{Sync Paused} completed{Sync Completed} error{Sync Failed} other{{status}}}'**
  String scheduleTaskSyncTitle(String status);

  /// No description provided for @scraperBehavior.
  ///
  /// In en, this message translates to:
  /// **'{theme, select, exact{Exactly Match} chooseFirst{Choose First} skip{Skip} other{Unknown}}'**
  String scraperBehavior(String theme);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchFilterTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for movies, TV series, actors and more'**
  String get searchHint;

  /// No description provided for @searchMultiResultTip.
  ///
  /// In en, this message translates to:
  /// **'Please select a search result'**
  String get searchMultiResultTip;

  /// No description provided for @searchNoResultTip.
  ///
  /// In en, this message translates to:
  /// **'There\'s no result for this title, you can rename it and search again'**
  String get searchNoResultTip;

  /// No description provided for @seasonCount.
  ///
  /// In en, this message translates to:
  /// **'{seasons} Seasons'**
  String seasonCount(Object seasons);

  /// No description provided for @seasonNumber.
  ///
  /// In en, this message translates to:
  /// **'Season {season}'**
  String seasonNumber(Object season);

  /// No description provided for @second.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get second;

  /// No description provided for @selectADriver.
  ///
  /// In en, this message translates to:
  /// **'Please Select a Driver'**
  String get selectADriver;

  /// No description provided for @selectADriverAccount.
  ///
  /// In en, this message translates to:
  /// **'Please Select a Driver Account'**
  String get selectADriverAccount;

  /// No description provided for @seriesStatus.
  ///
  /// In en, this message translates to:
  /// **'{status, select, returningSeries{Returning Series} ended{Ended} released{Released} other{{status}}}'**
  String seriesStatus(String status);

  /// No description provided for @serverFormItemLabelServer.
  ///
  /// In en, this message translates to:
  /// **'Server Address'**
  String get serverFormItemLabelServer;

  /// No description provided for @serverFormItemLabelServerType.
  ///
  /// In en, this message translates to:
  /// **'Server Type'**
  String get serverFormItemLabelServerType;

  /// No description provided for @sessionStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Please Fill the Form on your Phone'**
  String get sessionStatusConnected;

  /// No description provided for @sessionStatusCreated.
  ///
  /// In en, this message translates to:
  /// **'Please Scan the QR Code'**
  String get sessionStatusCreated;

  /// No description provided for @sessionStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get sessionStatusExpired;

  /// No description provided for @sessionStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation Failed, {error}'**
  String sessionStatusFailed(Object error);

  /// No description provided for @sessionStatusFinished.
  ///
  /// In en, this message translates to:
  /// **'Operation Completed, Wait for Refresh'**
  String get sessionStatusFinished;

  /// No description provided for @sessionStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get sessionStatusPending;

  /// No description provided for @sessionStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Error'**
  String get sessionStatusUnknown;

  /// No description provided for @settingsItemAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsItemAccount;

  /// No description provided for @settingsItemAutoForceLandscape.
  ///
  /// In en, this message translates to:
  /// **'Auto landscape play'**
  String get settingsItemAutoForceLandscape;

  /// No description provided for @settingsItemAutoPip.
  ///
  /// In en, this message translates to:
  /// **'Auto Enter PIP mode'**
  String get settingsItemAutoPip;

  /// No description provided for @settingsItemAutoPipTip.
  ///
  /// In en, this message translates to:
  /// **'When the player is in full screen mode, exit to the system desktop and the picture-in-picture mode will be automatically turned on.'**
  String get settingsItemAutoPipTip;

  /// No description provided for @settingsItemAutoPlay.
  ///
  /// In en, this message translates to:
  /// **'Auto Play'**
  String get settingsItemAutoPlay;

  /// No description provided for @settingsItemDNS.
  ///
  /// In en, this message translates to:
  /// **'DNS'**
  String get settingsItemDNS;

  /// No description provided for @settingsItemDataReset.
  ///
  /// In en, this message translates to:
  /// **'Data Reset'**
  String get settingsItemDataReset;

  /// No description provided for @settingsItemDataSettings.
  ///
  /// In en, this message translates to:
  /// **'Data Settings'**
  String get settingsItemDataSettings;

  /// No description provided for @settingsItemDataSync.
  ///
  /// In en, this message translates to:
  /// **'Data Sync'**
  String get settingsItemDataSync;

  /// No description provided for @settingsItemDisplaySettings.
  ///
  /// In en, this message translates to:
  /// **'Display Settings'**
  String get settingsItemDisplaySettings;

  /// No description provided for @settingsItemDisplaySize.
  ///
  /// In en, this message translates to:
  /// **'Display Size'**
  String get settingsItemDisplaySize;

  /// No description provided for @settingsItemDownload.
  ///
  /// In en, this message translates to:
  /// **'Download Management'**
  String get settingsItemDownload;

  /// No description provided for @settingsItemFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsItemFeedback;

  /// No description provided for @settingsItemInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get settingsItemInfo;

  /// No description provided for @settingsItemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System Language'**
  String get settingsItemLanguage;

  /// No description provided for @settingsItemLog.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get settingsItemLog;

  /// No description provided for @settingsItemMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie Folder'**
  String get settingsItemMovie;

  /// No description provided for @settingsItemNetworkDiagnotics.
  ///
  /// In en, this message translates to:
  /// **'Network Diagnotics'**
  String get settingsItemNetworkDiagnotics;

  /// No description provided for @settingsItemNfoEnabled.
  ///
  /// In en, this message translates to:
  /// **'NFO Enabled'**
  String get settingsItemNfoEnabled;

  /// No description provided for @settingsItemOthers.
  ///
  /// In en, this message translates to:
  /// **'Others Settings'**
  String get settingsItemOthers;

  /// No description provided for @settingsItemPlayerHistory.
  ///
  /// In en, this message translates to:
  /// **'Player History'**
  String get settingsItemPlayerHistory;

  /// No description provided for @settingsItemPlayerSettings.
  ///
  /// In en, this message translates to:
  /// **'Player Settings'**
  String get settingsItemPlayerSettings;

  /// No description provided for @settingsItemProxySettings.
  ///
  /// In en, this message translates to:
  /// **'Proxy Settings'**
  String get settingsItemProxySettings;

  /// No description provided for @settingsItemScraperBehavior.
  ///
  /// In en, this message translates to:
  /// **'Scraper Behavior'**
  String get settingsItemScraperBehavior;

  /// No description provided for @settingsItemScraperBehaviorDescription.
  ///
  /// In en, this message translates to:
  /// **'How to select when multiple data are searched?'**
  String get settingsItemScraperBehaviorDescription;

  /// No description provided for @settingsItemScraperSettings.
  ///
  /// In en, this message translates to:
  /// **'Scraper Settings'**
  String get settingsItemScraperSettings;

  /// No description provided for @settingsItemServer.
  ///
  /// In en, this message translates to:
  /// **'Server Settings'**
  String get settingsItemServer;

  /// No description provided for @settingsItemShortcutSettings.
  ///
  /// In en, this message translates to:
  /// **'Shortcut Settings'**
  String get settingsItemShortcutSettings;

  /// No description provided for @settingsItemShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get settingsItemShortcuts;

  /// No description provided for @settingsItemShortcutsKey.
  ///
  /// In en, this message translates to:
  /// **'{key, select, menu{Menu} previousChannel{Previous Channel} nextChannel{Next Channel} switchLinePanel{Switch Line Panel} channelsPanel{Channels Panel} other{{key}}}'**
  String settingsItemShortcutsKey(String key);

  /// No description provided for @settingsItemSponsor.
  ///
  /// In en, this message translates to:
  /// **'Sponsor'**
  String get settingsItemSponsor;

  /// No description provided for @settingsItemTV.
  ///
  /// In en, this message translates to:
  /// **'TV Folder'**
  String get settingsItemTV;

  /// No description provided for @settingsItemTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsItemTheme;

  /// No description provided for @settingsItemTmdbEnabled.
  ///
  /// In en, this message translates to:
  /// **'TMDB Enabled'**
  String get settingsItemTmdbEnabled;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sponsorMessage.
  ///
  /// In en, this message translates to:
  /// **'Development and maintenance are not easy. If you find this project useful, you might as well use WeChat to scan the QR code above to support this software!'**
  String get sponsorMessage;

  /// No description provided for @sponsorThanksMessage.
  ///
  /// In en, this message translates to:
  /// **'❤ Special thanks to the following friends for their rewards!'**
  String get sponsorThanksMessage;

  /// No description provided for @sponsorTipMessage.
  ///
  /// In en, this message translates to:
  /// **'If there is any omission, please contact me on Github to add'**
  String get sponsorTipMessage;

  /// No description provided for @subtitleFormItemLabelLanguage.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Language'**
  String get subtitleFormItemLabelLanguage;

  /// No description provided for @subtitleFormItemLabelType.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Type'**
  String get subtitleFormItemLabelType;

  /// No description provided for @subtitleFormItemLabelUrl.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get subtitleFormItemLabelUrl;

  /// No description provided for @subtitleSetting.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Setting'**
  String get subtitleSetting;

  /// No description provided for @subtitleSettingBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get subtitleSettingBackgroundColor;

  /// No description provided for @subtitleSettingEdgeColor.
  ///
  /// In en, this message translates to:
  /// **'Edge Color'**
  String get subtitleSettingEdgeColor;

  /// No description provided for @subtitleSettingExample.
  ///
  /// In en, this message translates to:
  /// **'Subtitle style example'**
  String get subtitleSettingExample;

  /// No description provided for @subtitleSettingForegroundColor.
  ///
  /// In en, this message translates to:
  /// **'Text Color'**
  String get subtitleSettingForegroundColor;

  /// No description provided for @subtitleSettingWindowColor.
  ///
  /// In en, this message translates to:
  /// **'Window Color'**
  String get subtitleSettingWindowColor;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'{language, select, zh{简体中文} en{English} other{Auto}}'**
  String systemLanguage(String language);

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'{theme, select, light{Light} dark{Dark} other{Auto}}'**
  String systemTheme(String theme);

  /// No description provided for @tagAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tagAll;

  /// No description provided for @tagFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get tagFavorite;

  /// No description provided for @tagNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get tagNew;

  /// No description provided for @tagNewAdd.
  ///
  /// In en, this message translates to:
  /// **'New Add'**
  String get tagNewAdd;

  /// No description provided for @tagNewRelease.
  ///
  /// In en, this message translates to:
  /// **'New Release'**
  String get tagNewRelease;

  /// No description provided for @tagShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get tagShowLess;

  /// No description provided for @tagShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get tagShowMore;

  /// No description provided for @tagUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get tagUnknown;

  /// No description provided for @timeAgo.
  ///
  /// In en, this message translates to:
  /// **'{time} Ago'**
  String timeAgo(Object time);

  /// No description provided for @tipsForCopiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Copied successfully'**
  String get tipsForCopiedSuccessfully;

  /// No description provided for @tipsForDownload.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get tipsForDownload;

  /// No description provided for @tipsStayTuned.
  ///
  /// In en, this message translates to:
  /// **'Stay tuned!'**
  String get tipsStayTuned;

  /// No description provided for @titleCast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get titleCast;

  /// No description provided for @titleCastCrew.
  ///
  /// In en, this message translates to:
  /// **'Cast and Crew'**
  String get titleCastCrew;

  /// No description provided for @titleCrew.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get titleCrew;

  /// No description provided for @titleEditM3U.
  ///
  /// In en, this message translates to:
  /// **'Select a M3U File'**
  String get titleEditM3U;

  /// No description provided for @titleEditMetadata.
  ///
  /// In en, this message translates to:
  /// **'Edit Metadata'**
  String get titleEditMetadata;

  /// No description provided for @titleEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a Subtitle File'**
  String get titleEditSubtitle;

  /// No description provided for @titleGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get titleGenre;

  /// No description provided for @titleKeyword.
  ///
  /// In en, this message translates to:
  /// **'Keyword'**
  String get titleKeyword;

  /// No description provided for @titleMoreFrom.
  ///
  /// In en, this message translates to:
  /// **'More From'**
  String get titleMoreFrom;

  /// No description provided for @titleNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get titleNext;

  /// No description provided for @titlePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get titlePlaylist;

  /// No description provided for @titleScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get titleScan;

  /// No description provided for @titleSeasons.
  ///
  /// In en, this message translates to:
  /// **'Seasons'**
  String get titleSeasons;

  /// No description provided for @titleSelectAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Please Select an Account'**
  String get titleSelectAnAccount;

  /// No description provided for @titleStudios.
  ///
  /// In en, this message translates to:
  /// **'Studios'**
  String get titleStudios;

  /// No description provided for @unitDay.
  ///
  /// In en, this message translates to:
  /// **'{time, plural, =1{1 Day} other{{time} Days}}'**
  String unitDay(num time);

  /// No description provided for @unitHour.
  ///
  /// In en, this message translates to:
  /// **'{time, plural, =1{1 Hour} other{{time} Hours}}'**
  String unitHour(num time);

  /// No description provided for @unitMinute.
  ///
  /// In en, this message translates to:
  /// **'{time, plural, =1{1 Minute} other{{time} Minutes}}'**
  String unitMinute(num time);

  /// No description provided for @unitMonth.
  ///
  /// In en, this message translates to:
  /// **'{time, plural, =1{1 Month} other{{time} Months}}'**
  String unitMonth(num time);

  /// No description provided for @unitSecond.
  ///
  /// In en, this message translates to:
  /// **'{time, plural, =1{1 Second} other{{time} Seconds}}'**
  String unitSecond(num time);

  /// No description provided for @unitYear.
  ///
  /// In en, this message translates to:
  /// **'{time, plural, =1{1 Year} other{{time} Years}}'**
  String unitYear(num time);

  /// No description provided for @unselect.
  ///
  /// In en, this message translates to:
  /// **'Unselect'**
  String get unselect;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update Failed'**
  String get updateFailed;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @updatePrerelease.
  ///
  /// In en, this message translates to:
  /// **'Update Prerelease Version'**
  String get updatePrerelease;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get updating;

  /// No description provided for @versionDeprecatedTip.
  ///
  /// In en, this message translates to:
  /// **'The current version is too low, please update to the latest version'**
  String get versionDeprecatedTip;

  /// No description provided for @videoSettingsAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get videoSettingsAudio;

  /// No description provided for @videoSettingsSpeeding.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get videoSettingsSpeeding;

  /// No description provided for @videoSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subtitle'**
  String get videoSettingsSubtitle;

  /// No description provided for @videoSettingsVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoSettingsVideo;

  /// No description provided for @videoSize.
  ///
  /// In en, this message translates to:
  /// **'Video Size'**
  String get videoSize;

  /// No description provided for @watchNow.
  ///
  /// In en, this message translates to:
  /// **'Watch Now'**
  String get watchNow;

  /// No description provided for @willSkipEnding.
  ///
  /// In en, this message translates to:
  /// **'Will Skip the Ending'**
  String get willSkipEnding;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
