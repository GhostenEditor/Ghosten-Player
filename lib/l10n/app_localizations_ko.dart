// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get accountCreateFormItemLabelClientId => '클라이언트 ID';

  @override
  String get accountCreateFormItemLabelClientPwd => '클라이언트 비밀번호';

  @override
  String get accountCreateFormItemLabelOauthUrl => 'OAuth URL';

  @override
  String get accountCreateFormItemLabelRefreshToken => '리프레시 토큰';

  @override
  String get accountUseProxy => '프록시 사용';

  @override
  String get actAs => '역';

  @override
  String audioDecoder(String decoder) {
    String _temp0 = intl.Intl.selectLogic(decoder, {
      '1': '확장 디코더 사용',
      '0': '확장 디코더 사용 안 함',
      '2': '확장 디코더 우선 사용',
      'other': '알 수 없음',
    });
    return '$_temp0';
  }

  @override
  String get audioDecoderLabel => '오디오 디코딩';

  @override
  String get autoCheckForUpdates => '자동 업데이트 확인';

  @override
  String autoUpdateFrequency(String frequency) {
    String _temp0 = intl.Intl.selectLogic(frequency, {
      'always': '항상',
      'everyday': '매일',
      'everyWeek': '매주',
      'never': '안 함',
      'other': '알 수 없음',
    });
    return '$_temp0';
  }

  @override
  String get buttonActivate => '활성화';

  @override
  String get buttonAirDate => '방영일';

  @override
  String get buttonAll => '전체';

  @override
  String get buttonCancel => '취소';

  @override
  String get buttonCast => '캐스트';

  @override
  String get buttonCollapse => '접기';

  @override
  String get buttonComplete => '완료';

  @override
  String get buttonConfirm => '확인';

  @override
  String get buttonDelete => '삭제';

  @override
  String get buttonDownload => '다운로드';

  @override
  String get buttonEdit => '수정';

  @override
  String get buttonEditMetadata => '메타데이터 수정';

  @override
  String get buttonExpectFavorite => '즐겨찾기 안 함';

  @override
  String get buttonFavorite => '즐겨찾기';

  @override
  String get buttonHome => '홈';

  @override
  String get buttonIncrementalSyncLibrary => '증분 동기화';

  @override
  String get buttonLastWatchedTime => '시청 시간';

  @override
  String get buttonMarkFavorite => '즐겨찾기에 추가';

  @override
  String get buttonMarkNotPlayed => '안 봄으로 표시';

  @override
  String get buttonMarkPlayed => '봄으로 표시';

  @override
  String get buttonMore => '더보기';

  @override
  String get buttonName => '이름';

  @override
  String get buttonNewFolder => '새 폴더';

  @override
  String get buttonPause => '일시정지';

  @override
  String get buttonPlay => '재생';

  @override
  String get buttonProperty => '속성';

  @override
  String get buttonRefresh => '새로고침';

  @override
  String get buttonRemoveDownload => '다운로드 삭제';

  @override
  String get buttonRename => '이름 변경';

  @override
  String get buttonReset => '초기화';

  @override
  String get buttonResume => '재개';

  @override
  String get buttonSaveMediaInfoToDriver => '미디어 정보를 드라이브에 저장';

  @override
  String get buttonScraperLibrary => '미디어 라이브러리 스크랩';

  @override
  String get buttonScraperMediaInfo => '미디어 정보 스크랩';

  @override
  String get buttonShuffle => '무작위 재생';

  @override
  String get buttonSkipFromEnd => '엔딩 건너뛰기 설정';

  @override
  String get buttonSkipFromStart => '인트로 건너뛰기 설정';

  @override
  String get buttonSubmit => '제출';

  @override
  String get buttonSubtitle => '자막 추가';

  @override
  String get buttonSyncLibrary => '라이브러리 동기화';

  @override
  String get buttonTrailer => '예고편';

  @override
  String get buttonUnmarkFavorite => '즐겨찾기에서 제거';

  @override
  String get buttonUnwatched => '시청 안 함';

  @override
  String get buttonView => '보기';

  @override
  String get buttonWatchNow => '지금 시청';

  @override
  String get buttonWatched => '시청함';

  @override
  String get checkForUpdates => '업데이트 확인';

  @override
  String get checkingUpdates => '업데이트 확인 중...';

  @override
  String get confirmTextExit => '한 번 더 누르면 종료됩니다';

  @override
  String get confirmTextLogin => '이 계정으로 로그인하시겠습니까?';

  @override
  String get confirmTextResetData => '데이터를 초기화하시겠습니까?';

  @override
  String get dataSyncActionOpenSettings => '권한 활성화';

  @override
  String get dataSyncActionRescanBluetoothDevices => '블루투스 기기 다시 검색';

  @override
  String get dataSyncActionRollback => '데이터 롤백';

  @override
  String get dataSyncActionSetDiscoverable => '검색 가능 상태로 설정';

  @override
  String get dataSyncAsReceiver => '수신자로';

  @override
  String get dataSyncAsSender => '발신자로';

  @override
  String get dataSyncConfirmRollback => '마지막 동기화 이전 상태로 데이터를 롤백하시겠습니까?';

  @override
  String dataSyncConfirmSync(Object device) {
    return '\"$device\" 기기의 데이터를 이 기기와 동기화하시겠습니까?';
  }

  @override
  String get dataSyncTipNonBluetoothAdapter => '블루투스 어댑터를 찾을 수 없습니다';

  @override
  String dataSyncTipOutOfDate(Object device) {
    return '\"\$$device\" 기기의 앱 버전이 너무 낮아 업데이트할 수 없습니다. 앱을 업데이트해 주세요.';
  }

  @override
  String get dataSyncTipPermission => '블루투스 관련 권한을 허용해 주세요';

  @override
  String get dataSyncTipSyncError => '동기화 오류';

  @override
  String get deleteAccountConfirmText => '이 드라이브를 삭제하시겠습니까?';

  @override
  String get deleteAccountTip =>
      '이 계정을 삭제하면 관련된 모든 미디어 정보가 삭제됩니다(드라이브의 실제 파일은 삭제되지 않음). 삭제하시겠습니까?';

  @override
  String get deleteConfirmText => '삭제하시겠습니까?';

  @override
  String get deleteMediaGroupConfirmText =>
      '미디어 라이브러리를 삭제하면 관련된 모든 미디어 정보가 삭제됩니다(드라이브의 파일은 삭제되지 않음). 계속하시겠습니까?';

  @override
  String get deletePlaylistTip => '재생목록을 삭제하면 포함된 모든 채널이 삭제됩니다';

  @override
  String get dnsFormItemLabelDomain => '도메인';

  @override
  String get dnsFormItemLabelIP => 'IP';

  @override
  String get downloaderDeleteFileConfirmText => '파일도 함께 삭제하시겠습니까?';

  @override
  String get downloaderLabelDownloadFailed => '다운로드 실패';

  @override
  String get downloaderLabelDownloaded => '다운로드됨';

  @override
  String get downloaderLabelDownloading => '다운로드 중';

  @override
  String driverType(String driverType) {
    String _temp0 = intl.Intl.selectLogic(driverType, {
      'alipan': 'Alipan',
      'quark': 'Quark',
      'quarktv': 'Quark TV',
      'webdav': 'WebDAV',
      'emby': 'Emby',
      'jellyfin': 'Jellyfin',
      'local': '로컬',
      'other': '알 수 없음',
    });
    return '$_temp0';
  }

  @override
  String episodeCount(Object episodes) {
    return '총 $episodes화';
  }

  @override
  String episodeNumber(Object episode) {
    return '$episode화';
  }

  @override
  String errorCode(String code, Object message) {
    String _temp0 = intl.Intl.selectLogic(code, {
      '30001': '대상 데이터가 선택되지 않았습니다. 목록에서 항목을 선택한 후 다시 시도해 주세요',
      '40000': '잘못된 요청입니다',
      '40001': 'M3U 파일이 파싱 제한을 초과했습니다. 파일을 조정한 후 다시 시도해 주세요.',
      '40002': 'M3U 파일을 파싱할 수 없습니다. 파일이 올바른지 확인해 주세요',
      '40003': '',
      '40004': 'Http URL이 올바르지 않습니다',
      '40005': '알 수 없는 IO 오류: $message',
      '40006': '중복된 데이터로 인해 삽입에 실패했습니다',
      '40007': '기타 IO 오류: $message',
      '40008': 'I/O 스트림에서 바이트를 읽거나 쓰는 데 실패했습니다',
      '40009': 'JSON 형식 구문 오류: $message',
      '40010': '데이터 형식 오류: $message',
      '40011': '데이터 누락: $message',
      '40012': '데이터 형식 오류: $message',
      '40013': '잘못된 Http 헤더 값입니다',
      '40014': '이 DLNA 작업은 지원되지 않습니다',
      '40015': '미디어 파일 이름이 없습니다',
      '40016': '잘못된 계정 유형으로 로그인했습니다',
      '40017': '계정 데이터가 없습니다',
      '40018': '동시 처리 오류',
      '40019': 'Range 접근이 지원되지 않습니다',
      '40020': '알리윤(Aliyun) 비동기 작업이 실패했습니다',
      '40021': '파일 이름 변경 충돌',
      '40022': '잘못된 미디어 라이브러리 유형입니다',
      '40023': '잘못된 필터 유형입니다',
      '40024': '',
      '40025': '$message개 데이터가 업데이트되었으나, 데이터 업데이트에 실패했습니다',
      '40026': '데이터 형식 오류: $message',
      '40101': '로그인 인증 실패: $message',
      '40102': '로그인에 실패했습니다. WebDAV 주소와 계정 정보가 올바른지 확인해 주세요!',
      '40103': '서버 계정 오류입니다. 다시 로그인해 주세요!',
      '40301': '접근이 금지되었습니다',
      '40401': '찾을 수 없습니다',
      '40402': 'API를 찾을 수 없습니다',
      '40403': '파일을 찾을 수 없습니다',
      '40404': '$message',
      '40800': '연결 시간 초과',
      '42900': '요청이 너무 많습니다',
      '50000': '내부 오류',
      '50401': '게이트웨이 시간 초과',
      '60001': '롤백할 데이터가 없습니다',
      '60002': '저장소 권한을 얻을 수 없습니다',
      '60003': '블루투스가 켜져 있는지 확인해 주세요',
      '60004': '블루투스 어댑터를 찾을 수 없습니다',
      'other': '알 수 없는 오류 $message',
    });
    return '$_temp0';
  }

  @override
  String errorDetails(String code, Object message) {
    String _temp0 = intl.Intl.selectLogic(code, {'other': '$message'});
    return '$_temp0';
  }

  @override
  String get errorLoadData => '데이터 로드 실패';

  @override
  String fileCategory(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'folder': '폴더',
      'video': '비디오',
      'audio': '오디오',
      'image': '이미지',
      'doc': '문서',
      'other': '알 수 없음',
    });
    return '$_temp0';
  }

  @override
  String get filePropertyCategory => '분류';

  @override
  String get filePropertyCreateAt => '생성일';

  @override
  String get filePropertyDriverType => '드라이브 유형';

  @override
  String get filePropertyFilename => '파일 이름';

  @override
  String get filePropertySize => '파일 크기';

  @override
  String get filePropertyUpdateAt => '수정일';

  @override
  String get formItemNotRequiredHelper => '없으면 비워두세요';

  @override
  String get formItemNotSelectedHint => '선택 안 함';

  @override
  String get formLabelAirDate => '방영일';

  @override
  String get formLabelEpisode => '에피소드';

  @override
  String get formLabelFilterCategory => '필터 분류';

  @override
  String get formLabelLanguage => '언어';

  @override
  String get formLabelOriginalTitle => '원제';

  @override
  String get formLabelPlot => '줄거리';

  @override
  String get formLabelRuntime => '상영 시간';

  @override
  String get formLabelSeason => '시즌';

  @override
  String get formLabelSelectedByDefault => '기본 선택';

  @override
  String get formLabelTitle => '제목';

  @override
  String get formLabelVoteAverage => '평균 평점';

  @override
  String get formLabelVoteCount => '평가 수';

  @override
  String get formLabelYear => '연도';

  @override
  String get formValidatorEpisode => '올바른 에피소드 번호를 입력해 주세요';

  @override
  String get formValidatorIP => '올바른 IP를 입력해 주세요';

  @override
  String get formValidatorRequired => '필수 입력 항목입니다';

  @override
  String get formValidatorSeason => '올바른 시즌 번호를 입력해 주세요';

  @override
  String get formValidatorUrl => '올바른 URL을 입력해 주세요';

  @override
  String get formValidatorYear => '올바른 연도를 입력해 주세요';

  @override
  String gender(String gender) {
    String _temp0 = intl.Intl.selectLogic(gender, {
      '1': '여성',
      '2': '남성',
      'other': '알 수 없음',
    });
    return '$_temp0';
  }

  @override
  String get githubProxy => 'Github 프록시';

  @override
  String get hdrSupports => 'HDR 지원';

  @override
  String hdrType(String hdrType) {
    String _temp0 = intl.Intl.selectLogic(hdrType, {
      'invalid': '지원 안 함',
      'dolbyVision': 'Dolby Vision',
      'hdr10': 'HDR 10',
      'hlg': 'Hybrid Log-Gamma',
      'hdr10Plus': 'HDR 10+',
      'other': '알 수 없음',
    });
    return '$_temp0';
  }

  @override
  String get homeTabBrowser => '탐색';

  @override
  String get homeTabLive => '실시간';

  @override
  String get homeTabMovie => '영화';

  @override
  String get homeTabSettings => '설정';

  @override
  String get homeTabTV => 'TV 프로그램';

  @override
  String get iptvDefaultSource => 'IPTV 기본 소스';

  @override
  String get iptvSourceFetchFailed => '기본 IPTV 소스를 가져오지 못했습니다';

  @override
  String get isLatestVersion => '최신 버전입니다';

  @override
  String lastCheckedUpdatesTime(Object time) {
    return '마지막 업데이트 확인: $time';
  }

  @override
  String latestVersion(Object version) {
    return '최신 버전: V$version';
  }

  @override
  String get liveCreateFormItemHelperUrl => '현재 m3u 형식의 소스만 지원됩니다.';

  @override
  String get liveCreateFormItemLabelTitle => '채널 이름';

  @override
  String get liveCreateFormItemLabelUrl => '채널 주소';

  @override
  String get loginFormItemLabelPwd => '비밀번호';

  @override
  String get loginFormItemLabelUserAgent => 'User Agent';

  @override
  String get loginFormItemLabelUsername => '사용자 이름';

  @override
  String get minute => '분';

  @override
  String get modalNotificationDeleteLoadingText => '데이터 삭제 중...';

  @override
  String get modalNotificationDeleteSuccessText => '삭제되었습니다';

  @override
  String get modalNotificationLoadingText => '데이터 불러오는 중...';

  @override
  String get modalNotificationResetSuccessText => '초기화되었습니다';

  @override
  String get modalNotificationSuccessText => '불러오기 완료';

  @override
  String get modalTitleConfirm => '알림';

  @override
  String get modalTitleNotification => '알림';

  @override
  String get modalTitleProgress => '알림';

  @override
  String networkStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': '네트워크 상태가 정상입니다',
      'fail': '네트워크 상태가 비정상입니다',
      'other': '알 수 없음',
    });
    return '$_temp0';
  }

  @override
  String get noData => '데이터 없음';

  @override
  String get noOverview => '줄거리 없음';

  @override
  String get none => '없음';

  @override
  String get pageTitleAccount => '계정';

  @override
  String get pageTitleAccountSetting => '계정 설정';

  @override
  String get pageTitleAdd => '추가';

  @override
  String get pageTitleCreateAccount => '계정 생성';

  @override
  String get pageTitleCreateMovieLibrary => '영화 라이브러리 생성';

  @override
  String get pageTitleCreateTVLibrary => 'TV 라이브러리 생성';

  @override
  String get pageTitleEdit => '수정';

  @override
  String get pageTitleFileViewer => '파일 뷰어';

  @override
  String get pageTitleFilter => '필터';

  @override
  String get pageTitleLogin => '로그인';

  @override
  String get playerAlipanVideoClarityTip =>
      '동영상 화질을 선택하면 영상이 트랜스코딩되어 압축됩니다. 온라인 재생이 끊기거나 형식이 지원되지 않으면 화질을 설정해 보세요. 원본 파일을 재생하려면 NONE을 선택하세요.';

  @override
  String get playerBroadcastLine => '회선';

  @override
  String get playerEnableDecoderFallback => '디코더 폴백 사용';

  @override
  String get playerFastForwardSpeed => '속도';

  @override
  String get playerOpenFileWithParallelThreads => '병렬 스레드로 파일 열기';

  @override
  String get playerParallelsCount => '병렬 스레드 수';

  @override
  String get playerShowLiteProgressbar => '재생 진행률 표시';

  @override
  String get playerShowThumbnails => '썸네일 표시';

  @override
  String get playerSliceSize => '분할 크기';

  @override
  String playerType(String playerType) {
    String _temp0 = intl.Intl.selectLogic(playerType, {
      'media3': 'Media3',
      'mpv': 'MPV',
      'other': '알 수 없음',
    });
    return '$_temp0';
  }

  @override
  String get playerUseHardwareCodec => '하드웨어 디코딩 사용';

  @override
  String get playerVideoClarity => '동영상 화질';

  @override
  String queryType(String queryType) {
    String _temp0 = intl.Intl.selectLogic(queryType, {
      'genre': '장르',
      'studio': '제작사',
      'keyword': '키워드',
      'actor': '배우',
      'other': '알 수 없음',
    });
    return '$_temp0';
  }

  @override
  String get refreshMediaGroupButton => '미디어 라이브러리 새로고침';

  @override
  String scheduleTaskScrapeTitle(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'idle': '대기 중',
      'running': '스크랩 중',
      'paused': '스크랩 일시정지',
      'completed': '스크랩 완료',
      'error': '스크랩 실패',
      'other': '$status',
    });
    return '$_temp0';
  }

  @override
  String scheduleTaskSyncSubtitle(Object data) {
    return '$data개 파일이 동기화되었습니다';
  }

  @override
  String scheduleTaskSyncTitle(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'idle': '동기화 대기 중',
      'running': '동기화 중',
      'paused': '동기화 일시정지',
      'completed': '동기화 완료',
      'error': '동기화 실패',
      'other': '$status',
    });
    return '$_temp0';
  }

  @override
  String scraperBehavior(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'exact': '정확히 일치',
      'chooseFirst': '첫 번째 선택',
      'skip': '건너뛰기',
      'other': '알 수 없음',
    });
    return '$_temp0';
  }

  @override
  String get search => '검색';

  @override
  String get searchFilterTitle => '필터';

  @override
  String get searchHint => '영화, TV 프로그램, 배우 등을 검색하세요';

  @override
  String get searchMultiResultTip => '검색 결과를 선택해 주세요';

  @override
  String get searchNoResultTip => '이 제목에 대한 검색 결과가 없습니다. 이름을 변경한 후 다시 검색해 보세요';

  @override
  String seasonCount(Object seasons) {
    return '총 $seasons개 시즌';
  }

  @override
  String seasonNumber(Object season) {
    return '시즌 $season';
  }

  @override
  String get second => '초';

  @override
  String get selectADriver => '드라이브를 선택해 주세요';

  @override
  String get selectADriverAccount => '드라이브 계정을 선택해 주세요';

  @override
  String seriesStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'returningSeries': '방영 중',
      'ended': '종영',
      'released': '공개됨',
      'other': '$status',
    });
    return '$_temp0';
  }

  @override
  String get serverFormItemLabelServer => '서버 주소';

  @override
  String get serverFormItemLabelServerType => '서버 유형';

  @override
  String get sessionStatusConnected => '휴대폰에서 정보를 입력해 주세요';

  @override
  String get sessionStatusCreated => 'QR 코드를 스캔해 주세요';

  @override
  String get sessionStatusExpired => '만료됨';

  @override
  String sessionStatusFailed(Object error) {
    return '작업 실패, $error';
  }

  @override
  String get sessionStatusFinished => '작업 완료, 새로고침을 기다려 주세요';

  @override
  String get sessionStatusPending => '처리 중';

  @override
  String get sessionStatusUnknown => '알 수 없는 오류';

  @override
  String get settingsItemAccount => '계정 관리';

  @override
  String get settingsItemAutoForceLandscape => '자동 가로 화면 재생';

  @override
  String get settingsItemAutoPip => '자동 PIP 모드 진입';

  @override
  String get settingsItemAutoPipTip =>
      '플레이어가 전체 화면 상태일 때 시스템 홈 화면으로 나가면 자동으로 PIP(화면 속 화면) 모드가 켜집니다.';

  @override
  String get settingsItemAutoPlay => '자동 재생';

  @override
  String get settingsItemDNS => 'DNS';

  @override
  String get settingsItemDataReset => '데이터 초기화';

  @override
  String get settingsItemDataSettings => '데이터 설정';

  @override
  String get settingsItemDataSync => '데이터 동기화';

  @override
  String get settingsItemDisplaySettings => '화면 설정';

  @override
  String get settingsItemDisplaySize => '화면 크기';

  @override
  String get settingsItemDownload => '다운로드 관리';

  @override
  String get settingsItemFeedback => '피드백';

  @override
  String get settingsItemHelp => '도움말';

  @override
  String get settingsItemInfo => '정보';

  @override
  String get settingsItemLanguage => '시스템 언어';

  @override
  String get settingsItemLog => '로그';

  @override
  String get settingsItemMovie => '영화 폴더 설정';

  @override
  String get settingsItemNetworkDiagnostics => '네트워크 진단';

  @override
  String get settingsItemNfoEnabled => 'NFO 사용';

  @override
  String get settingsItemOthers => '기타 설정';

  @override
  String get settingsItemPlayerHistory => '재생 기록';

  @override
  String get settingsItemPlayerKernel => '플레이어 커널';

  @override
  String get settingsItemPlayerSettings => '재생 설정';

  @override
  String get settingsItemProxySettings => '프록시 설정';

  @override
  String get settingsItemScraperBehavior => '스크랩 동작';

  @override
  String get settingsItemScraperBehaviorDescription =>
      '검색 결과가 여러 개일 때 어떻게 선택할까요?';

  @override
  String get settingsItemScraperSettings => '스크랩 설정';

  @override
  String get settingsItemServer => '원격 서버 설정';

  @override
  String get settingsItemShortcutSettings => '단축키 설정';

  @override
  String get settingsItemShortcuts => '단축키';

  @override
  String settingsItemShortcutsKey(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'menu': '메뉴',
      'previousChannel': '이전 채널',
      'nextChannel': '다음 채널',
      'switchLinePanel': '회선 전환 패널',
      'channelsPanel': '채널 목록 패널',
      'other': '$key',
    });
    return '$_temp0';
  }

  @override
  String get settingsItemSponsor => '후원';

  @override
  String get settingsItemTV => 'TV 폴더 설정';

  @override
  String get settingsItemTheme => '테마';

  @override
  String get settingsItemTmdbEnabled => 'TMDB 사용';

  @override
  String get settingsTitle => '설정';

  @override
  String get sponsorMessage =>
      '개발과 유지 관리는 쉽지 않습니다. 이 프로젝트가 유용하다고 느끼신다면 위 QR 코드를 위챗으로 스캔하여 후원해 주세요!';

  @override
  String get sponsorThanksMessage => '❤ 후원해 주신 다음 분들께 특별히 감사드립니다!';

  @override
  String get sponsorTipMessage => '누락된 부분이 있다면 Github으로 연락해 추가해 주세요';

  @override
  String get subtitleFormItemLabelLanguage => '자막 언어';

  @override
  String get subtitleFormItemLabelType => '자막 형식';

  @override
  String get subtitleFormItemLabelUrl => 'URL';

  @override
  String get subtitleSetting => '자막 설정';

  @override
  String get subtitleSettingBackgroundColor => '배경 색상';

  @override
  String get subtitleSettingEdgeColor => '테두리 색상';

  @override
  String get subtitleSettingExample => '자막 스타일 예시';

  @override
  String get subtitleSettingForegroundColor => '글자 색상';

  @override
  String get subtitleSettingWindowColor => '창 색상';

  @override
  String systemLanguage(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {
      'zh': '简体中文',
      'en': 'English',
      'ko': '한국어',
      'other': '자동',
    });
    return '$_temp0';
  }

  @override
  String systemTheme(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'light': '라이트',
      'dark': '다크',
      'other': '자동',
    });
    return '$_temp0';
  }

  @override
  String get tagAll => '전체';

  @override
  String get tagFavorite => '즐겨찾기';

  @override
  String get tagNew => '신규';

  @override
  String get tagNewAdd => '새로 추가됨';

  @override
  String get tagNewRelease => '최신 공개';

  @override
  String get tagShowLess => '간략히';

  @override
  String get tagShowMore => '더 보기';

  @override
  String get tagUnknown => '알 수 없음';

  @override
  String timeAgo(Object time) {
    return '$time 전';
  }

  @override
  String get tipsForCopiedSuccessfully => '복사되었습니다';

  @override
  String get tipsForDownload => '다운로드 중...';

  @override
  String get tipsStayTuned => '기대해 주세요!';

  @override
  String get titleCasts => '출연진';

  @override
  String get titleCastsCrews => '출연 및 제작진';

  @override
  String get titleCrews => '제작진';

  @override
  String get titleEditM3U => 'M3U 파일 선택';

  @override
  String get titleEditMetadata => '메타데이터 수정';

  @override
  String get titleEditSubtitle => '자막 파일 선택';

  @override
  String get titleGenres => '장르';

  @override
  String get titleKeywords => '키워드';

  @override
  String get titleMoreFrom => '관련 작품';

  @override
  String get titleNext => '다음';

  @override
  String get titlePlaylist => '재생 목록';

  @override
  String get titleScan => '스캔';

  @override
  String get titleSeasons => '시즌';

  @override
  String get titleSelectAnAccount => '계정을 선택해 주세요';

  @override
  String get titleStudios => '제작사';

  @override
  String unitDay(num time) {
    String _temp0 = intl.Intl.pluralLogic(
      time,
      locale: localeName,
      other: '$time일',
      one: '1일',
    );
    return '$_temp0';
  }

  @override
  String unitHour(num time) {
    String _temp0 = intl.Intl.pluralLogic(
      time,
      locale: localeName,
      other: '$time시간',
      one: '1시간',
    );
    return '$_temp0';
  }

  @override
  String unitMinute(num time) {
    String _temp0 = intl.Intl.pluralLogic(
      time,
      locale: localeName,
      other: '$time분',
      one: '1분',
    );
    return '$_temp0';
  }

  @override
  String unitMonth(num time) {
    String _temp0 = intl.Intl.pluralLogic(
      time,
      locale: localeName,
      other: '$time개월',
      one: '1개월',
    );
    return '$_temp0';
  }

  @override
  String unitSecond(num time) {
    String _temp0 = intl.Intl.pluralLogic(
      time,
      locale: localeName,
      other: '$time초',
      one: '1초',
    );
    return '$_temp0';
  }

  @override
  String unitYear(num time) {
    String _temp0 = intl.Intl.pluralLogic(
      time,
      locale: localeName,
      other: '$time년',
      one: '1년',
    );
    return '$_temp0';
  }

  @override
  String get unselect => '선택 해제';

  @override
  String get updateFailed => '업데이트 실패';

  @override
  String get updateNow => '지금 업데이트';

  @override
  String get updatePrerelease => '프리릴리스 버전 업데이트';

  @override
  String get updating => '업데이트 중';

  @override
  String get versionDeprecatedTip => '현재 버전이 너무 낮습니다. 최신 버전으로 업데이트해 주세요';

  @override
  String get videoAspectRatio => '화면 비율';

  @override
  String get videoResizeMode => '화면 맞춤 방식';

  @override
  String get videoSettingsAudio => '오디오';

  @override
  String get videoSettingsSpeeding => '배속';

  @override
  String get videoSettingsSubtitle => '자막';

  @override
  String get videoSettingsVideo => '비디오';

  @override
  String get watchNow => '이어보기';

  @override
  String get willSkipEnding => '곧 엔딩을 건너뜁니다';
}
