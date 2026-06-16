// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Flutter 应用模板';

  @override
  String get errorOccurred => '发生错误';

  @override
  String get backToHome => '返回首页';

  @override
  String get welcomeHome => '欢迎使用我的应用';

  @override
  String get ok => '确定';

  @override
  String get cancel => '取消';

  @override
  String get loading => '加载中';

  @override
  String get success => '成功';

  @override
  String get error => '错误';

  @override
  String get undo => '撤销';

  @override
  String get navHome => '首页';

  @override
  String get navService => '服务';

  @override
  String get navToolbox => '工具箱';

  @override
  String get navShowcase => '展示';

  @override
  String get navSetting => '设置';

  @override
  String get settingsTitle => 'YellowDog设置';

  @override
  String get smenuTheme => '主题';

  @override
  String get appearance => '外观';

  @override
  String get accentColor => '强调色';

  @override
  String get language => '语言';

  @override
  String get retry => '重试';

  @override
  String get lightTheme => '浅色';

  @override
  String get darkTheme => '深色';

  @override
  String get systemTheme => '系统';

  @override
  String get nslookupTitle => 'YellowDog NS查询';

  @override
  String get bmenuNSLookup => 'NS查询';

  @override
  String get bmenuBenchmark => '基准测试';

  @override
  String get bmenuDns => '服务器';

  @override
  String get bmenuMDns => 'mDNS';

  @override
  String get bmenuSettings => '设置';

  @override
  String get textLabelRRName => '名称';

  @override
  String get textHintRRName => 'DNS资源记录名称';

  @override
  String get textLabelRRType => '类型';

  @override
  String get textHintRRType => 'DNS资源记录类型';

  @override
  String get textLabelRRClass => '类别';

  @override
  String get textHintRRClass => 'DNS类别';

  @override
  String get textLabelRRData => '数据';

  @override
  String get textLabelRRTimeToLive => 'TTL';

  @override
  String get textLabelProtocol => '协议';

  @override
  String get textHintProtocol => 'DNS查询协议';

  @override
  String get textLabelServer => '域名服务器';

  @override
  String get textHintServer => 'DNS服务器，例如 8.8.8.8#53 或 2001:4860:4860::8888#53';

  @override
  String get textLabelECS => 'ECS';

  @override
  String get textHintECS => 'EDNS客户端子网';

  @override
  String get textLabelDNSSEC => 'DNSSEC';

  @override
  String get buttonLookup => '查询';

  @override
  String get labelAnswer => '回答';

  @override
  String get buttonClearResult => '清除结果';

  @override
  String get benchmarkTitle => 'YellowDog基准测试';

  @override
  String get textLabelSourceFile => '源文件';

  @override
  String get buttonManageSourceFile => '管理文件';

  @override
  String get textLabelConcurrencyClients => '并发客户端';

  @override
  String get textHintConcurrencyClients => '例如10';

  @override
  String get textLabelNTimes => 'N次';

  @override
  String get textHintNTimes => '例如10';

  @override
  String get buttonBenchmark => '运行基准测试';

  @override
  String get labelBenchmarkResult => '基准测试结果';

  @override
  String get labelError => '错误';

  @override
  String get buttonAtRunning => '运行中';

  @override
  String get nameServerTitle => 'YellowDog名称服务器';

  @override
  String get nameServerSecondaryTitle => '实时日志';

  @override
  String get textLabelServerPort => '服务器端口';

  @override
  String get textHintServerPort => '例如53';

  @override
  String get textLabelForwarderAddress => '转发地址';

  @override
  String get textHintForwarderAddress => '例如8.8.8.8';

  @override
  String get textLabelForwarderPort => '转发端口';

  @override
  String get textHintForwarderPort => '例如53';

  @override
  String get buttonStartServer => '启动服务器';

  @override
  String get buttonStopServer => '停止服务器';

  @override
  String get smenuAppearance => '外观';

  @override
  String get smenuColorTheme => '颜色主题';

  @override
  String get smenuBenchmark => '基准测试';

  @override
  String get smenuSourceFile => '源文件';

  @override
  String get titleSelectAppearance => '选择外观';

  @override
  String get titleSelectColorTheme => '选择颜色主题';

  @override
  String get benchmarkSourceTitle => '基准测试来源';

  @override
  String get smenuAddFile => '添加文件';

  @override
  String get labelLoading => '加载中';

  @override
  String get addBenchmarkSourceTitle => '添加基准测试来源';

  @override
  String get editBenchmarkSourceTitle => '编辑基准测试来源';

  @override
  String get showBenchmarkSourceTitle => '显示基准测试来源';

  @override
  String get textLabelSourceFileName => '名称';

  @override
  String get textHintSourceFileName => '例如：前10条记录';

  @override
  String get textLabelSourceFileContent => '内容';

  @override
  String get textHintSourceFileContent =>
      '例如：\nwww.example.com A\nexample.com CNAME';

  @override
  String get buttonAddSourceFile => '添加';

  @override
  String get buttonEditSourceFile => '编辑';

  @override
  String get buttonUpdateSourceFile => '更新';

  @override
  String get buttonDeleteSourceFile => '删除';

  @override
  String get mdnsTitle => '多播DNS';

  @override
  String get mdnsTitleSecondary => 'mDNS结果';

  @override
  String get mdnsTabTitleQuery => '查询';

  @override
  String get mdnsTabTitleListen => '监听';

  @override
  String get mdnsQueryForm => '查询表单';

  @override
  String get mdnsListenForm => '监听MDNS消息';

  @override
  String get required => '必填';

  @override
  String get invalidAddress => '无效的地址';

  @override
  String get invalidPort => '无效的端口';

  @override
  String get start => '开始';

  @override
  String get stop => '停止';

  @override
  String get pause => '暂停';

  @override
  String get resume => '继续';

  @override
  String get clear => '清除';

  @override
  String get noData => '无数据';

  @override
  String get smenuYellowDog => 'YellowDog';

  @override
  String get smenuSmenuYellowDog => '关于YellowDog';

  @override
  String get titleAboutYellowDog => '关于YellowDog';

  @override
  String get aboutYellowDog => '纪念YellowDog，1988 - 1990';

  @override
  String get aboutYellowDog2 => '你是一只强壮、聪明、忠诚的狗';

  @override
  String get deviceInfo => 'Device Info';

  @override
  String get wifiInfo => 'Wifi Info';

  @override
  String get account => 'Account';

  @override
  String get monitorTitle => 'Monitor';

  @override
  String get monitorAddHost => 'Add Host';

  @override
  String get monitorDiscovering => 'Scanning network...';

  @override
  String get monitorNoHosts =>
      'No hosts found. Add one manually or start an agent on your network.';

  @override
  String get monitorCpu => 'CPU';

  @override
  String get monitorMemory => 'Memory';

  @override
  String get monitorGpu => 'GPU';

  @override
  String get monitorNetwork => 'Network';

  @override
  String get monitorDisk => 'Disk';

  @override
  String get monitorConnecting => 'Connecting...';

  @override
  String get monitorConnected => 'Connected';

  @override
  String get monitorDisconnected => 'Disconnected';

  @override
  String get monitorError => 'Unreachable';

  @override
  String monitorLoadAvg(String one, String five, String fifteen) {
    return 'Load: $one, $five, $fifteen';
  }

  @override
  String monitorSwap(String percent) {
    return 'Swap: $percent%';
  }

  @override
  String monitorGpuTemp(String temp) {
    return '$temp°C';
  }

  @override
  String get monitorHostIp => 'IP Address';

  @override
  String get monitorHostPort => 'Port';

  @override
  String get monitorHostPortDefault => 'Default: 9723';

  @override
  String get monitorRemoveHost => 'Remove Host';

  @override
  String monitorRemoveHostConfirm(String hostname) {
    return 'Remove $hostname from the list?';
  }

  @override
  String get monitorTrustTitle => 'Trust this agent?';

  @override
  String get monitorTrustBody =>
      'Verify this fingerprint matches the agent\'s terminal output.';

  @override
  String get monitorTrustAction => 'Trust';

  @override
  String get monitorCertMismatchTitle => 'Certificate changed!';

  @override
  String get monitorCertMismatchBody =>
      'The agent\'s certificate has changed since you last connected. This could indicate a security issue.';

  @override
  String get monitorReTrust => 'Trust Anyway';

  @override
  String monitorVersionWarning(String version) {
    return 'Agent v$version — update available';
  }

  @override
  String get ttsDatasetTitle => 'TTS Dataset';

  @override
  String get ttsDatasetRefresh => 'Refresh';

  @override
  String get ttsDatasetProjectName => 'Project name';

  @override
  String get ttsDatasetSpeaker => 'Speaker';

  @override
  String get ttsDatasetLanguage => 'Language';

  @override
  String get ttsDatasetLicense => 'License';

  @override
  String get ttsDatasetCreateProject => 'Create project';

  @override
  String get ttsDatasetEnglishUs => 'English (US)';

  @override
  String get ttsDatasetChineseMandarin => 'Chinese (Mandarin)';

  @override
  String get ttsDatasetCancel => 'Cancel';

  @override
  String get ttsDatasetNoProjects => 'No projects yet';

  @override
  String get ttsDatasetProjectNotFound => 'Project not found';

  @override
  String get ttsDatasetRemoveProject => 'Remove project';

  @override
  String ttsDatasetRemoveProjectConfirm(String name) {
    return 'Remove $name from the TTS dataset projects?';
  }

  @override
  String get ttsDatasetNoProjectSelected => 'No project selected';

  @override
  String get ttsDatasetNotValidated => 'Not validated';

  @override
  String ttsDatasetValidationBlocking(int count) {
    return '$count blocking';
  }

  @override
  String get ttsDatasetReady => 'Ready';

  @override
  String get ttsDatasetProjects => 'Projects';

  @override
  String get ttsDatasetPrompts => 'Prompts';

  @override
  String get ttsDatasetAcceptedClips => 'Accepted clips';

  @override
  String get ttsDatasetValidation => 'Validation';

  @override
  String get ttsDatasetValidate => 'Validate';

  @override
  String get ttsDatasetExportZip => 'Export ZIP';

  @override
  String get ttsDatasetTrainingText => 'Training text';

  @override
  String get ttsDatasetSelectedText => 'Selected text';

  @override
  String get ttsDatasetRecordAudio => 'Record audio';

  @override
  String get ttsDatasetClearRecording => 'Clear recording';

  @override
  String get ttsDatasetPlayRecording => 'Play recording';

  @override
  String get ttsDatasetStopRecording => 'Stop recording';

  @override
  String get ttsDatasetRecorded => 'Recorded';

  @override
  String get ttsDatasetNeedsAudio => 'Need audio';

  @override
  String get ttsDatasetMicrophoneDenied => 'Microphone permission denied';

  @override
  String get ttsDatasetNoRecordingToPlay => 'No recording to play';

  @override
  String get ttsDatasetPlaybackUnavailable => 'Could not play recording';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appName => 'Flutter 应用模板';

  @override
  String get errorOccurred => '发生错误';

  @override
  String get backToHome => '返回首页';

  @override
  String get welcomeHome => '欢迎使用我的应用';

  @override
  String get ok => '确定';

  @override
  String get cancel => '取消';

  @override
  String get loading => '加载中';

  @override
  String get success => '成功';

  @override
  String get error => '错误';

  @override
  String get undo => '撤销';

  @override
  String get navHome => '首页';

  @override
  String get navService => '服务';

  @override
  String get navToolbox => '工具箱';

  @override
  String get navShowcase => '展示';

  @override
  String get navSetting => '设置';

  @override
  String get settingsTitle => 'YellowDog设置';

  @override
  String get smenuTheme => '主题';

  @override
  String get appearance => '外观';

  @override
  String get accentColor => '强调色';

  @override
  String get language => '语言';

  @override
  String get retry => '重试';

  @override
  String get lightTheme => '浅色';

  @override
  String get darkTheme => '深色';

  @override
  String get systemTheme => '系统';

  @override
  String get nslookupTitle => 'YellowDog NS查询';

  @override
  String get bmenuNSLookup => 'NS查询';

  @override
  String get bmenuBenchmark => '基准测试';

  @override
  String get bmenuDns => '服务器';

  @override
  String get bmenuMDns => 'mDNS';

  @override
  String get bmenuSettings => '设置';

  @override
  String get textLabelRRName => '名称';

  @override
  String get textHintRRName => 'DNS资源记录名称';

  @override
  String get textLabelRRType => '类型';

  @override
  String get textHintRRType => 'DNS资源记录类型';

  @override
  String get textLabelRRClass => '类别';

  @override
  String get textHintRRClass => 'DNS类别';

  @override
  String get textLabelRRData => '数据';

  @override
  String get textLabelRRTimeToLive => 'TTL';

  @override
  String get textLabelProtocol => '协议';

  @override
  String get textHintProtocol => 'DNS查询协议';

  @override
  String get textLabelServer => '域名服务器';

  @override
  String get textHintServer => 'DNS服务器，例如 8.8.8.8#53 或 2001:4860:4860::8888#53';

  @override
  String get textLabelECS => 'ECS';

  @override
  String get textHintECS => 'EDNS客户端子网';

  @override
  String get textLabelDNSSEC => 'DNSSEC';

  @override
  String get buttonLookup => '查询';

  @override
  String get labelAnswer => '回答';

  @override
  String get buttonClearResult => '清除结果';

  @override
  String get benchmarkTitle => 'YellowDog基准测试';

  @override
  String get textLabelSourceFile => '源文件';

  @override
  String get buttonManageSourceFile => '管理文件';

  @override
  String get textLabelConcurrencyClients => '并发客户端';

  @override
  String get textHintConcurrencyClients => '例如10';

  @override
  String get textLabelNTimes => 'N次';

  @override
  String get textHintNTimes => '例如10';

  @override
  String get buttonBenchmark => '运行基准测试';

  @override
  String get labelBenchmarkResult => '基准测试结果';

  @override
  String get labelError => '错误';

  @override
  String get buttonAtRunning => '运行中';

  @override
  String get nameServerTitle => 'YellowDog名称服务器';

  @override
  String get nameServerSecondaryTitle => '实时日志';

  @override
  String get textLabelServerPort => '服务器端口';

  @override
  String get textHintServerPort => '例如53';

  @override
  String get textLabelForwarderAddress => '转发地址';

  @override
  String get textHintForwarderAddress => '例如8.8.8.8';

  @override
  String get textLabelForwarderPort => '转发端口';

  @override
  String get textHintForwarderPort => '例如53';

  @override
  String get buttonStartServer => '启动服务器';

  @override
  String get buttonStopServer => '停止服务器';

  @override
  String get smenuAppearance => '外观';

  @override
  String get smenuColorTheme => '颜色主题';

  @override
  String get smenuBenchmark => '基准测试';

  @override
  String get smenuSourceFile => '源文件';

  @override
  String get titleSelectAppearance => '选择外观';

  @override
  String get titleSelectColorTheme => '选择颜色主题';

  @override
  String get benchmarkSourceTitle => '基准测试来源';

  @override
  String get smenuAddFile => '添加文件';

  @override
  String get labelLoading => '加载中';

  @override
  String get addBenchmarkSourceTitle => '添加基准测试来源';

  @override
  String get editBenchmarkSourceTitle => '编辑基准测试来源';

  @override
  String get showBenchmarkSourceTitle => '显示基准测试来源';

  @override
  String get textLabelSourceFileName => '名称';

  @override
  String get textHintSourceFileName => '例如：前10条记录';

  @override
  String get textLabelSourceFileContent => '内容';

  @override
  String get textHintSourceFileContent =>
      '例如：\nwww.example.com A\nexample.com CNAME';

  @override
  String get buttonAddSourceFile => '添加';

  @override
  String get buttonEditSourceFile => '编辑';

  @override
  String get buttonUpdateSourceFile => '更新';

  @override
  String get buttonDeleteSourceFile => '删除';

  @override
  String get mdnsTitle => '多播DNS';

  @override
  String get mdnsTitleSecondary => 'mDNS结果';

  @override
  String get mdnsTabTitleQuery => '查询';

  @override
  String get mdnsTabTitleListen => '监听';

  @override
  String get mdnsQueryForm => '查询表单';

  @override
  String get mdnsListenForm => '监听MDNS消息';

  @override
  String get required => '必填';

  @override
  String get invalidAddress => '无效的地址';

  @override
  String get invalidPort => '无效的端口';

  @override
  String get start => '开始';

  @override
  String get stop => '停止';

  @override
  String get pause => '暂停';

  @override
  String get resume => '继续';

  @override
  String get clear => '清除';

  @override
  String get noData => '无数据';

  @override
  String get smenuYellowDog => 'YellowDog';

  @override
  String get smenuSmenuYellowDog => '关于YellowDog';

  @override
  String get titleAboutYellowDog => '关于YellowDog';

  @override
  String get aboutYellowDog => '纪念YellowDog，1988 - 1990';

  @override
  String get aboutYellowDog2 => '你是一只强壮、聪明、忠诚的狗';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appName => 'Flutter 應用範本';

  @override
  String get errorOccurred => '發生錯誤';

  @override
  String get backToHome => '返回首頁';

  @override
  String get welcomeHome => '歡迎使用我的應用';

  @override
  String get ok => '確定';

  @override
  String get cancel => '取消';

  @override
  String get loading => '載入中';

  @override
  String get success => '成功';

  @override
  String get error => '錯誤';

  @override
  String get undo => '復原';

  @override
  String get navHome => '首頁';

  @override
  String get navService => '服務';

  @override
  String get navToolbox => '工具箱';

  @override
  String get navShowcase => '展示';

  @override
  String get navSetting => '設定';

  @override
  String get settingsTitle => 'YellowDog 設定';

  @override
  String get smenuTheme => '主題';

  @override
  String get appearance => '外觀';

  @override
  String get accentColor => '強調色';

  @override
  String get language => '語言';

  @override
  String get retry => '重試';

  @override
  String get lightTheme => '淺色';

  @override
  String get darkTheme => '深色';

  @override
  String get systemTheme => '系統';

  @override
  String get nslookupTitle => 'YellowDog NS 查詢';

  @override
  String get bmenuNSLookup => 'NS 查詢';

  @override
  String get bmenuBenchmark => '基準測試';

  @override
  String get bmenuDns => '伺服器';

  @override
  String get bmenuMDns => 'mDNS';

  @override
  String get bmenuSettings => '設定';

  @override
  String get textLabelRRName => '名稱';

  @override
  String get textHintRRName => 'DNS 資源紀錄名稱';

  @override
  String get textLabelRRType => '類型';

  @override
  String get textHintRRType => 'DNS 資源紀錄類型';

  @override
  String get textLabelRRClass => '類別';

  @override
  String get textHintRRClass => 'DNS 類別';

  @override
  String get textLabelRRData => '資料';

  @override
  String get textLabelRRTimeToLive => 'TTL';

  @override
  String get textLabelProtocol => '協定';

  @override
  String get textHintProtocol => 'DNS 查詢協定';

  @override
  String get textLabelServer => '名稱伺服器';

  @override
  String get textHintServer =>
      'DNS 伺服器，例如 8.8.8.8#53 或 2001:4860:4860::8888#53';

  @override
  String get textLabelECS => 'ECS';

  @override
  String get textHintECS => 'EDNS 客戶端子網';

  @override
  String get textLabelDNSSEC => 'DNSSEC';

  @override
  String get buttonLookup => '查詢';

  @override
  String get labelAnswer => '回答';

  @override
  String get buttonClearResult => '清除結果';

  @override
  String get benchmarkTitle => 'YellowDog 基準測試';

  @override
  String get textLabelSourceFile => '來源檔案';

  @override
  String get buttonManageSourceFile => '管理檔案';

  @override
  String get textLabelConcurrencyClients => '並行客戶端';

  @override
  String get textHintConcurrencyClients => '例如 10';

  @override
  String get textLabelNTimes => 'N 次';

  @override
  String get textHintNTimes => '例如 10';

  @override
  String get buttonBenchmark => '運行基準測試';

  @override
  String get labelBenchmarkResult => '基準測試結果';

  @override
  String get labelError => '錯誤';

  @override
  String get buttonAtRunning => '運行中';

  @override
  String get nameServerTitle => 'YellowDog 名稱伺服器';

  @override
  String get nameServerSecondaryTitle => '即時日誌';

  @override
  String get textLabelServerPort => '伺服器埠';

  @override
  String get textHintServerPort => '例如 53';

  @override
  String get textLabelForwarderAddress => '轉寄地址';

  @override
  String get textHintForwarderAddress => '例如 8.8.8.8';

  @override
  String get textLabelForwarderPort => '轉寄埠';

  @override
  String get textHintForwarderPort => '例如 53';

  @override
  String get buttonStartServer => '啟動伺服器';

  @override
  String get buttonStopServer => '停止伺服器';

  @override
  String get smenuAppearance => '外觀';

  @override
  String get smenuColorTheme => '顏色主題';

  @override
  String get smenuBenchmark => '基準測試';

  @override
  String get smenuSourceFile => '來源檔案';

  @override
  String get titleSelectAppearance => '選擇外觀';

  @override
  String get titleSelectColorTheme => '選擇顏色主題';

  @override
  String get benchmarkSourceTitle => '基準測試來源';

  @override
  String get smenuAddFile => '添加檔案';

  @override
  String get labelLoading => '載入中';

  @override
  String get addBenchmarkSourceTitle => '添加基準測試來源';

  @override
  String get editBenchmarkSourceTitle => '編輯基準測試來源';

  @override
  String get showBenchmarkSourceTitle => '顯示基準測試來源';

  @override
  String get textLabelSourceFileName => '名稱';

  @override
  String get textHintSourceFileName => '例如：前10名紀錄';

  @override
  String get textLabelSourceFileContent => '內容';

  @override
  String get textHintSourceFileContent =>
      '例如：\nwww.example.com A\nexample.com CNAME';

  @override
  String get buttonAddSourceFile => '添加';

  @override
  String get buttonEditSourceFile => '編輯';

  @override
  String get buttonUpdateSourceFile => '更新';

  @override
  String get buttonDeleteSourceFile => '刪除';

  @override
  String get mdnsTitle => '多播DNS';

  @override
  String get mdnsTitleSecondary => 'mDNS 結果';

  @override
  String get mdnsTabTitleQuery => '查詢';

  @override
  String get mdnsTabTitleListen => '監聽';

  @override
  String get mdnsQueryForm => '查詢表單';

  @override
  String get mdnsListenForm => '監聽MDNS訊息';

  @override
  String get required => '必填';

  @override
  String get invalidAddress => '無效的地址';

  @override
  String get invalidPort => '無效的端口';

  @override
  String get start => '開始';

  @override
  String get stop => '停止';

  @override
  String get pause => '暫停';

  @override
  String get resume => '繼續';

  @override
  String get clear => '清除';

  @override
  String get noData => '無資料';

  @override
  String get smenuYellowDog => 'YellowDog';

  @override
  String get smenuSmenuYellowDog => '關於 YellowDog';

  @override
  String get titleAboutYellowDog => '關於 YellowDog';

  @override
  String get aboutYellowDog => '紀念 YellowDog，1988 - 1990';

  @override
  String get aboutYellowDog2 => '你是一隻強壯、聰明、忠誠的狗';
}
