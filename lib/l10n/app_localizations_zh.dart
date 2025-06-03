// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get accountCreateFormItemLabelClientId => '客户端ID';

  @override
  String get accountCreateFormItemLabelClientPwd => '客户端密码';

  @override
  String get accountCreateFormItemLabelOauthUrl => 'OAuth令牌链接';

  @override
  String get accountCreateFormItemLabelRefreshToken => '刷新令牌';

  @override
  String get accountUseProxy => '使用代理';

  @override
  String get actAs => '饰演';

  @override
  String audioDecoder(String decoder) {
    String _temp0 = intl.Intl.selectLogic(decoder, {'1': '启用拓展解码器', '0': '禁用拓展解码器', '2': '优先使用拓展解码器', 'other': '未知'});
    return '$_temp0';
  }

  @override
  String get audioDecoderLabel => '音频解码方式';

  @override
  String get autoCheckForUpdates => '自动检查更新';

  @override
  String autoUpdateFrequency(String frequency) {
    String _temp0 = intl.Intl.selectLogic(frequency, {
      'always': '总是',
      'everyday': '每天',
      'everyWeek': '每周',
      'never': '从不',
      'other': '未知',
    });
    return '$_temp0';
  }

  @override
  String get buttonActivate => '启用';

  @override
  String get buttonAirDate => '播出时间';

  @override
  String get buttonAll => '全部';

  @override
  String get buttonCancel => '取消';

  @override
  String get buttonCast => '投屏';

  @override
  String get buttonCollapse => '收起';

  @override
  String get buttonComplete => '完成';

  @override
  String get buttonConfirm => '确认';

  @override
  String get buttonDelete => '删除';

  @override
  String get buttonDownload => '下载';

  @override
  String get buttonEdit => '修改';

  @override
  String get buttonEditMetadata => '编辑元数据';

  @override
  String get buttonExpectFavorite => '未喜欢';

  @override
  String get buttonFavorite => '喜欢';

  @override
  String get buttonHome => '主页';

  @override
  String get buttonIncrementalSyncLibrary => '增量同步媒体库';

  @override
  String get buttonLastWatchedTime => '观看时间';

  @override
  String get buttonMarkFavorite => '标记为喜欢';

  @override
  String get buttonMarkNotPlayed => '标记为未观看';

  @override
  String get buttonMarkPlayed => '标记为已观看';

  @override
  String get buttonMore => '更多';

  @override
  String get buttonName => '名称';

  @override
  String get buttonNewFolder => '新建文件夾';

  @override
  String get buttonPause => '暂停';

  @override
  String get buttonPlay => '播放';

  @override
  String get buttonProperty => '属性';

  @override
  String get buttonRefresh => '刷新';

  @override
  String get buttonRemoveDownload => '移除下载';

  @override
  String get buttonRename => '重命名';

  @override
  String get buttonReset => '重置';

  @override
  String get buttonResume => '继续';

  @override
  String get buttonSaveMediaInfoToDriver => '保存媒体信息至文件';

  @override
  String get buttonScraperLibrary => '刮削媒体库';

  @override
  String get buttonScraperMediaInfo => '刮削媒体信息';

  @override
  String get buttonShuffle => '随机播放';

  @override
  String get buttonSkipFromEnd => '设置跳过片尾时间';

  @override
  String get buttonSkipFromStart => '设置跳过片头时间';

  @override
  String get buttonSubmit => '提交';

  @override
  String get buttonSubtitle => '添加字幕';

  @override
  String get buttonSyncLibrary => '同步媒体库';

  @override
  String get buttonTrailer => '预告片';

  @override
  String get buttonUnmarkFavorite => '取消标记为喜欢';

  @override
  String get buttonUnwatched => '未观看';

  @override
  String get buttonView => '查看';

  @override
  String get buttonWatchNow => '立即观看';

  @override
  String get buttonWatched => '已观看';

  @override
  String get checkForUpdates => '检查更新';

  @override
  String get checkingUpdates => '检查更新中...';

  @override
  String get confirmTextExit => '再按一次退出！';

  @override
  String get confirmTextLogin => '是否要登录该账号？';

  @override
  String get confirmTextResetData => '是否要重置数据?';

  @override
  String get dataSyncActionOpenSettings => '开启权限';

  @override
  String get dataSyncActionRescanBluetoothDevices => '重新扫描蓝牙设备';

  @override
  String get dataSyncActionRollback => '回退数据到上次同步前';

  @override
  String get dataSyncActionSetDiscoverable => '将蓝牙设置为可发现';

  @override
  String get dataSyncAsReceiver => '作为接收端';

  @override
  String get dataSyncAsSender => '作为发送端';

  @override
  String get dataSyncConfirmRollback => '是否要回退数据到上次同步前？';

  @override
  String dataSyncConfirmSync(Object device) {
    return '是否要将设备\"$device\"的数据同步到本机？';
  }

  @override
  String get dataSyncTipNonBluetoothAdapter => '无法获取到蓝牙适配器';

  @override
  String dataSyncTipOutOfDate(Object device) {
    return '设备\"\$$device\"软件版本过旧，无法更新，请更新';
  }

  @override
  String get dataSyncTipPermission => '请打开启相关权限';

  @override
  String get dataSyncTipSyncError => '数据同步错误';

  @override
  String get deleteAccountConfirmText => '是否要删除该网盘？';

  @override
  String get deleteAccountTip => '删除该账号会同时删除所有关联的媒体信息(不会删除网盘文件)，是否继续此操作？';

  @override
  String get deleteConfirmText => '确定是否要删除？';

  @override
  String get deleteMediaGroupConfirmText => '删除该媒体目录将同时删除管理的媒体信息(不会删除网盘文件)，是否继续此操作？';

  @override
  String get deletePlaylistTip => '删除播放列表会删除其所有频道';

  @override
  String get dnsFormItemLabelDomain => '域名';

  @override
  String get dnsFormItemLabelIP => 'IP';

  @override
  String get downloaderDeleteFileConfirmText => '是否同时删除文件？';

  @override
  String get downloaderLabelDownloaded => '已下载';

  @override
  String get downloaderLabelDownloading => '下载中';

  @override
  String driverType(String driverType) {
    String _temp0 = intl.Intl.selectLogic(driverType, {
      'alipan': '阿里云盘',
      'quark': '夸克网盘',
      'quarktv': '夸克网盘 TV',
      'webdav': 'Webdav',
      'emby': 'Emby',
      'jellyfin': 'Jellyfin',
      'local': '本地',
      'other': '未知',
    });
    return '$_temp0';
  }

  @override
  String episodeCount(Object episodes) {
    return '共$episodes集';
  }

  @override
  String episodeNumber(Object episode) {
    return '第$episode集';
  }

  @override
  String errorCode(String code, Object message) {
    String _temp0 = intl.Intl.selectLogic(code, {
      '30001': '未选择目标数据，请从列表中选择一项后重试',
      '40000': '错误请求',
      '40001': 'M3U 文件超出解析限制，请调整文件后重试',
      '40002': 'M3U文件无法解析，请检查该文件是否正确',
      '40003': '',
      '40004': 'Http Url不正确',
      '40005': '未知的IO错误: $message',
      '40006': '数据重复，插入失败',
      '40007': '其他IO错误: $message',
      '40008': 'A failure to read or write bytes on an I/O stream',
      '40009': 'JSON格式语法错误: $message',
      '40010': '数据格式错误: $message',
      '40011': '数据缺失: $message',
      '40012': '数据格式错误: $message',
      '40013': 'Invalid Http Header Value: $message',
      '40014': '该DLNA Action不支持',
      '40015': '媒体文件名缺失',
      '40016': '登录的账号类型错误',
      '40017': '账号数据缺失',
      '40018': '并发数错误',
      '40019': '不支持Range访问',
      '40020': '阿里云盘异步任务失败',
      '40021': '文件重命名冲突',
      '40022': '媒体库类型错误',
      '40023': '过滤类型错误',
      '40024': '',
      '40025': '更新了$message条数据，数据更新失败',
      '40101': '登录验证失败: $message',
      '40102': '登录失败，请确认Webdav的地址以及账号密码是否正确!',
      '40103': 'Server 账号错误，请重新登录！',
      '40301': '禁止访问',
      '40401': 'Not Found',
      '40402': 'Api Not Found',
      '40403': '文件不存在',
      '40404': '$message',
      '40800': '连接超时',
      '42900': '请求太频繁',
      '50000': '内部错误',
      '50401': '网关超时',
      '60001': '未发现可回退的数据',
      '60002': '无法获取本地文件读写权限',
      '60003': '连接超时, 请确认该设备是否打开蓝牙，并且正处于当前页面',
      '60004': '未发现蓝牙适配器',
      'other': '未知错误 $message',
    });
    return '$_temp0';
  }

  @override
  String errorDetails(String code, Object message) {
    String _temp0 = intl.Intl.selectLogic(code, {'other': ''});
    return '$_temp0';
  }

  @override
  String get errorLoadData => '数据获取失败';

  @override
  String fileCategory(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'folder': '文件夹',
      'video': '视频',
      'audio': '音频',
      'image': '图片',
      'doc': '文档',
      'other': '未知',
    });
    return '$_temp0';
  }

  @override
  String get filePropertyCategory => '类型';

  @override
  String get filePropertyCreateAt => '创建时间';

  @override
  String get filePropertyDriverType => '网盘类型';

  @override
  String get filePropertyFilename => '文件名';

  @override
  String get filePropertySize => '文件大小';

  @override
  String get filePropertyUpdateAt => '上次修改时间';

  @override
  String get formItemNotRequiredHelper => '如果你没有，请留空';

  @override
  String get formItemNotSelectedHint => '未选择';

  @override
  String get formLabelAirDate => '上映日期';

  @override
  String get formLabelEpisode => '集';

  @override
  String get formLabelFilterCategory => '筛选类型';

  @override
  String get formLabelLanguage => '语言';

  @override
  String get formLabelOriginalTitle => '原始标题';

  @override
  String get formLabelPlot => '简介';

  @override
  String get formLabelRuntime => '时长';

  @override
  String get formLabelSeason => '季';

  @override
  String get formLabelSelectedByDefault => '默认选中';

  @override
  String get formLabelTitle => '标题';

  @override
  String get formLabelVoteAverage => '评分';

  @override
  String get formLabelVoteCount => '评分数';

  @override
  String get formLabelYear => '年份';

  @override
  String get formValidatorEpisode => '请输入合法的集数';

  @override
  String get formValidatorIP => '请输入合法的IP';

  @override
  String get formValidatorRequired => '此项为必填项';

  @override
  String get formValidatorSeason => '请输入合法的季数';

  @override
  String get formValidatorUrl => '请输入合法的Url';

  @override
  String get formValidatorYear => '请输入合法的年份';

  @override
  String gender(String gender) {
    String _temp0 = intl.Intl.selectLogic(gender, {'1': '女', '2': '男', 'other': '未知'});
    return '$_temp0';
  }

  @override
  String get githubProxy => 'Github代理';

  @override
  String get hdrSupports => 'HDR 支持情况';

  @override
  String hdrType(String hdrType) {
    String _temp0 = intl.Intl.selectLogic(hdrType, {
      'invalid': 'Invalid',
      'dolbyVision': '杜比视界',
      'hdr10': 'HDR 10',
      'hlg': 'Hybrid Log-Gamma',
      'hdr10Plus': 'HDR 10+',
      'other': '未知',
    });
    return '$_temp0';
  }

  @override
  String get homeTabBrowser => '浏览';

  @override
  String get homeTabLive => '直播';

  @override
  String get homeTabMovie => '电影';

  @override
  String get homeTabSettings => '设置';

  @override
  String get homeTabTV => '剧集';

  @override
  String get iptvDefaultSource => 'IPTV 默认源';

  @override
  String get iptvSourceFetchFailed => '获取默认源失败';

  @override
  String get isLatestVersion => '当前已是最新版本';

  @override
  String lastCheckedUpdatesTime(Object time) {
    return '最近更新时间 $time';
  }

  @override
  String latestVersion(Object version) {
    return '最新版本: V$version';
  }

  @override
  String get liveCreateFormItemHelperUrl => '目前仅支持m3u格式的直播源';

  @override
  String get liveCreateFormItemLabelTitle => '直播源名称';

  @override
  String get liveCreateFormItemLabelUrl => '直播源地址';

  @override
  String get loginFormItemLabelPwd => '密码';

  @override
  String get loginFormItemLabelUserAgent => 'User Agent';

  @override
  String get loginFormItemLabelUsername => '用户名';

  @override
  String get minute => '分';

  @override
  String get modalNotificationDeleteLoadingText => '数据删除中...';

  @override
  String get modalNotificationDeleteSuccessText => '数据删除成功';

  @override
  String get modalNotificationLoadingText => '加载中...';

  @override
  String get modalNotificationResetSuccessText => '数据重置成功';

  @override
  String get modalNotificationSuccessText => '加载成功';

  @override
  String get modalTitleConfirm => '提示';

  @override
  String get modalTitleNotification => '提示';

  @override
  String get modalTitleProgress => '提示';

  @override
  String networkStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {'success': '网络状态正常', 'fail': '网络状态异常', 'other': '未知'});
    return '$_temp0';
  }

  @override
  String get noData => '暂无数据';

  @override
  String get noOverview => '暂无简介';

  @override
  String get none => '无';

  @override
  String get pageTitleAccount => '账号管理';

  @override
  String get pageTitleAccountSetting => '账户设置';

  @override
  String get pageTitleAdd => '添加';

  @override
  String get pageTitleCreateAccount => '创建账户';

  @override
  String get pageTitleCreateMovieLibrary => '添加电影目录';

  @override
  String get pageTitleCreateTVLibrary => '添加电视剧目录';

  @override
  String get pageTitleEdit => '修改';

  @override
  String get pageTitleFileViewer => '文件查看';

  @override
  String get pageTitleFilter => '筛选';

  @override
  String get pageTitleLogin => '登录';

  @override
  String get playerAlipanVideoClarityTip => '选择视频清晰度，视频将被转码压缩，若在线播放卡顿或格式不支持，可以尝试设置清晰度，若希望播放原始文件则选择NONE';

  @override
  String get playerBroadcastLine => '线路';

  @override
  String get playerEnableDecoderFallback => 'Enable Decoder Fallback';

  @override
  String get playerFastForwardSpeed => '快进速度';

  @override
  String get playerOpenFileWithParallelThreads => '使用多线程打开文件';

  @override
  String get playerParallelsCount => '线程数';

  @override
  String get playerShowThumbnails => '显示缩略图';

  @override
  String get playerSliceSize => '分片大小';

  @override
  String get playerUseHardwareCodec => '使用硬解码';

  @override
  String get playerVideoClarity => '视频清晰度';

  @override
  String queryType(String queryType) {
    String _temp0 = intl.Intl.selectLogic(queryType, {
      'genre': '类型',
      'studio': '播出平台',
      'keyword': '关键词',
      'actor': '演职人员',
      'other': '未知',
    });
    return '$_temp0';
  }

  @override
  String get refreshMediaGroupButton => '刷新媒体库';

  @override
  String scheduleTaskScrapeTitle(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'idle': '刮削未启动',
      'running': '刮削中',
      'paused': '刮削暂停',
      'completed': '刮削完成',
      'error': '刮削失败',
      'other': '$status',
    });
    return '$_temp0';
  }

  @override
  String scheduleTaskSyncSubtitle(Object data) {
    return '已同步$data个文件';
  }

  @override
  String scheduleTaskSyncTitle(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'idle': '同步未启动',
      'running': '同步中',
      'paused': '同步暂停',
      'completed': '同步完成',
      'error': '同步失败',
      'other': '$status',
    });
    return '$_temp0';
  }

  @override
  String scraperBehavior(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'exact': '精确匹配',
      'chooseFirst': '选择第一个',
      'skip': '跳过',
      'other': '未知',
    });
    return '$_temp0';
  }

  @override
  String get search => '搜索';

  @override
  String get searchFilterTitle => '全部筛选';

  @override
  String get searchHint => '搜索电影、剧集、演员等信息';

  @override
  String get searchMultiResultTip => '请选择一项查询结果';

  @override
  String get searchNoResultTip => '无法搜索到改媒体信息，可以尝试修改名称重新查询';

  @override
  String seasonCount(Object seasons) {
    return '共$seasons季';
  }

  @override
  String seasonNumber(Object season) {
    return '第$season季';
  }

  @override
  String get second => '秒';

  @override
  String get selectADriver => '请选择网盘';

  @override
  String get selectADriverAccount => '请选择一个网盘账户';

  @override
  String seriesStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'returningSeries': '回归剧',
      'ended': '已完结',
      'released': '已上映',
      'other': '$status',
    });
    return '$_temp0';
  }

  @override
  String get serverFormItemLabelServer => '服务器地址';

  @override
  String get serverFormItemLabelServerType => '类型';

  @override
  String get sessionStatusConnected => '请在手机上填写相关信息';

  @override
  String get sessionStatusCreated => '使用手机扫描二维码，辅助TV输入';

  @override
  String get sessionStatusExpired => '已过期';

  @override
  String sessionStatusFailed(Object error) {
    return '操作失败, $error';
  }

  @override
  String get sessionStatusFinished => '操作完成，等待刷新';

  @override
  String get sessionStatusPending => '数据处理中';

  @override
  String get sessionStatusUnknown => '未知错误';

  @override
  String get settingsItemAccount => '账号管理';

  @override
  String get settingsItemAutoForceLandscape => '自动横屏播放';

  @override
  String get settingsItemAutoPip => '自动画中画';

  @override
  String get settingsItemAutoPipTip => '播放器处于全屏状态时，退出到系统桌面，会自动开启画中画模式';

  @override
  String get settingsItemAutoPlay => '自动播放';

  @override
  String get settingsItemDNS => 'DNS';

  @override
  String get settingsItemDataReset => '数据重置';

  @override
  String get settingsItemDataSettings => '数据设置';

  @override
  String get settingsItemDataSync => '数据同步';

  @override
  String get settingsItemDisplaySettings => '显示设置';

  @override
  String get settingsItemDisplaySize => '显示大小';

  @override
  String get settingsItemDownload => '下载管理';

  @override
  String get settingsItemFeedback => '反馈';

  @override
  String get settingsItemInfo => '关于';

  @override
  String get settingsItemLanguage => '系统语言';

  @override
  String get settingsItemLog => '日志';

  @override
  String get settingsItemMovie => '电影目录设置';

  @override
  String get settingsItemNetworkDiagnotics => '网络诊断';

  @override
  String get settingsItemNfoEnabled => 'NFO 启用';

  @override
  String get settingsItemOthers => '其他设置';

  @override
  String get settingsItemPlayerHistory => '播放历史';

  @override
  String get settingsItemPlayerSettings => '播放设置';

  @override
  String get settingsItemProxySettings => '代理设置';

  @override
  String get settingsItemScraperBehavior => '刮削行为';

  @override
  String get settingsItemScraperBehaviorDescription => '当搜索到多条数据时，如何进行选择？';

  @override
  String get settingsItemScraperSettings => '刮削设置';

  @override
  String get settingsItemServer => '远程服务器设置';

  @override
  String get settingsItemShortcutSettings => '快捷键设置';

  @override
  String get settingsItemShortcuts => '快捷键';

  @override
  String settingsItemShortcutsKey(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'menu': '菜单键',
      'previousChannel': '直播上一个频道',
      'nextChannel': '直播下一个频道',
      'switchLinePanel': '直播线路切换',
      'channelsPanel': '直播频道列表',
      'other': '$key',
    });
    return '$_temp0';
  }

  @override
  String get settingsItemSponsor => '赞赏';

  @override
  String get settingsItemTV => '电视剧目录设置';

  @override
  String get settingsItemTheme => '主题';

  @override
  String get settingsItemTmdbEnabled => 'TMDB 启用';

  @override
  String get settingsTitle => '设置';

  @override
  String get sponsorMessage => '开发维护不易，如果您觉得此项目有用，不妨使用微信扫描上方二维码，支持本软件！';

  @override
  String get sponsorThanksMessage => '❤ 特别鸣谢以下小伙伴的打赏！';

  @override
  String get sponsorTipMessage => '若有遗漏可在Github上联系我补充';

  @override
  String get subtitleFormItemLabelLanguage => '字幕语言';

  @override
  String get subtitleFormItemLabelType => '字幕类型';

  @override
  String get subtitleFormItemLabelUrl => '地址';

  @override
  String get subtitleSetting => '字幕设置';

  @override
  String get subtitleSettingBackgroundColor => '背景颜色';

  @override
  String get subtitleSettingEdgeColor => '边缘颜色';

  @override
  String get subtitleSettingExample => '字幕样式示例';

  @override
  String get subtitleSettingForegroundColor => '文字颜色';

  @override
  String get subtitleSettingWindowColor => '窗口颜色';

  @override
  String systemLanguage(String language) {
    String _temp0 = intl.Intl.selectLogic(language, {'zh': '简体中文', 'en': 'English', 'other': '自动'});
    return '$_temp0';
  }

  @override
  String systemTheme(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {'light': '浅色', 'dark': '深色', 'other': '自动'});
    return '$_temp0';
  }

  @override
  String get tagAll => '全部';

  @override
  String get tagFavorite => '收藏夹';

  @override
  String get tagNew => '新';

  @override
  String get tagNewAdd => '新添加';

  @override
  String get tagNewRelease => '新上映';

  @override
  String get tagShowLess => '更少';

  @override
  String get tagShowMore => '更多';

  @override
  String get tagUnknown => '未知';

  @override
  String timeAgo(Object time) {
    return '$time前';
  }

  @override
  String get tipsForCopiedSuccessfully => '复制成功';

  @override
  String get tipsForDownload => '后台下载中...';

  @override
  String get tipsStayTuned => '敬请期待！';

  @override
  String get titleCast => '演员';

  @override
  String get titleCastCrew => '演职人员';

  @override
  String get titleCrew => '工作人员';

  @override
  String get titleEditM3U => '选择M3U文件';

  @override
  String get titleEditMetadata => '编辑元数据';

  @override
  String get titleEditSubtitle => '选择字幕文件';

  @override
  String get titleGenre => '类型';

  @override
  String get titleKeyword => '关键词';

  @override
  String get titleMoreFrom => '更多来自';

  @override
  String get titleNext => '接下来';

  @override
  String get titlePlaylist => '正在播放';

  @override
  String get titleScan => '扫描';

  @override
  String get titleSeasons => '剧集';

  @override
  String get titleSelectAnAccount => '请选择一个账户';

  @override
  String get titleStudios => '播出平台';

  @override
  String unitDay(num time) {
    return '$time天';
  }

  @override
  String unitHour(num time) {
    return '$time小时';
  }

  @override
  String unitMinute(num time) {
    return '$time分钟';
  }

  @override
  String unitMonth(num time) {
    return '$time月';
  }

  @override
  String unitSecond(num time) {
    return '$time秒';
  }

  @override
  String unitYear(num time) {
    return '$time年';
  }

  @override
  String get unselect => '未选择';

  @override
  String get updateFailed => '更新失败';

  @override
  String get updateNow => '立即更新';

  @override
  String get updatePrerelease => '更新预览版';

  @override
  String get updating => '正在更新';

  @override
  String get versionDeprecatedTip => '当前版本过低，请更新至最新版';

  @override
  String get videoSettingsAudio => '音频';

  @override
  String get videoSettingsSpeeding => '倍速';

  @override
  String get videoSettingsSubtitle => '字幕';

  @override
  String get videoSettingsVideo => '视频';

  @override
  String get videoSize => '画面尺寸';

  @override
  String get watchNow => '继续观看';

  @override
  String get willSkipEnding => '即将跳过片尾';
}
