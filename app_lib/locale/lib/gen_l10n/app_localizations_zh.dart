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
  String get accountRefresh => 'Refresh accounts';

  @override
  String get accountSecretMissing => 'Account secret missing';

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

  @override
  String get backplaneTitle => 'Backplane';

  @override
  String get settingsChatGroup => 'Chat';

  @override
  String get settingsAgentMenu => 'Agent';

  @override
  String get backplaneServiceUrl => 'Service URL';

  @override
  String get backplaneAccount => 'Service account token';

  @override
  String get backplaneSelectAccount => 'Select an account';

  @override
  String get backplaneMissingAccount =>
      'The selected account is unavailable. Manage Service Accounts.';

  @override
  String get backplaneManageAccounts => 'Manage Service Accounts';

  @override
  String get backplaneProtocol => 'LLM protocol';

  @override
  String get backplaneResponses => 'OpenAI Responses';

  @override
  String get backplaneCompletions => 'Chat Completions';

  @override
  String get backplaneMcpEnabled => 'Enable MCP tools';

  @override
  String get backplaneSave => 'Save';

  @override
  String get backplaneLoadModels => 'Load Models';

  @override
  String get backplaneRefreshTools => 'Refresh Tools';

  @override
  String get backplaneModels => 'Discovered models';

  @override
  String get backplaneTools => 'Discovered tools';

  @override
  String get backplaneNoModels => 'No models discovered';

  @override
  String get backplaneNoTools => 'No tools discovered';

  @override
  String get backplaneSaveBeforeDiscovery => 'Save changes before discovery.';

  @override
  String get backplaneInvalidUrl =>
      'Enter an HTTP or HTTPS service URL without credentials, query, or fragment.';

  @override
  String get backplaneManagedConnection => 'Managed Backplane connection';

  @override
  String get backplaneManagedTools => 'Managed Backplane tools';

  @override
  String get backplaneManagedBy => 'Managed by Backplane';

  @override
  String get backplaneEnabled => 'Enabled';

  @override
  String get backplaneDisabled => 'Disabled';

  @override
  String get backplaneModelsLoadFailed => 'Could not load Backplane models';

  @override
  String get backplaneToolsRefreshFailed => 'Could not refresh Backplane tools';

  @override
  String get compassTitle => '指南针';

  @override
  String get compassMagneticNorth => '磁北';

  @override
  String get compassWaitingForSensor => '正在等待指南针读数…';

  @override
  String get compassUnavailable => '此设备没有指南针所需的传感器。';

  @override
  String get compassUnsupportedPlatform => '指南针仅在 Android 和 iOS 上可用。';

  @override
  String get compassSensorError => '无法读取指南针，请重试。';

  @override
  String get compassCalibrationNeeded => '建议校准';

  @override
  String get compassHelpTitle => '指南针使用与校准';

  @override
  String get compassHelpBody => '请将手机平放，并远离金属和磁性配件。提示校准时，缓慢移动手机画“8”字。读数以磁北为基准。';

  @override
  String get compassDirectionNorth => '北';

  @override
  String get compassDirectionNorthEast => '东北';

  @override
  String get compassDirectionEast => '东';

  @override
  String get compassDirectionSouthEast => '东南';

  @override
  String get compassDirectionSouth => '南';

  @override
  String get compassDirectionSouthWest => '西南';

  @override
  String get compassDirectionWest => '西';

  @override
  String get compassDirectionNorthWest => '西北';

  @override
  String compassHeadingReadout(int degrees, String direction) {
    return '$degrees° · $direction';
  }

  @override
  String get audioServiceTitle => 'Audio';

  @override
  String get audioServiceDescription =>
      'ASR speech recognition and TTS speech synthesis';

  @override
  String get audioTtsTab => 'Text to Speech (TTS)';

  @override
  String get audioAsrTab => 'Speech to Text (ASR)';

  @override
  String get audioTextInputHint => 'Enter text to convert to speech…';

  @override
  String get audioSynthesizeButton => 'Synthesize';

  @override
  String get audioSynthesizing => 'Synthesizing audio…';

  @override
  String get audioVoiceLabel => 'Voice';

  @override
  String get audioModelLabel => 'Model';

  @override
  String get audioPlayButton => 'Play';

  @override
  String get audioPauseButton => 'Pause';

  @override
  String get audioStopButton => 'Stop';

  @override
  String get audioSaveButton => 'Export Audio';

  @override
  String get audioRecordButton => 'Record';

  @override
  String get audioStopRecordButton => 'Stop & Transcribe';

  @override
  String get audioUploadButton => 'Pick Audio File';

  @override
  String get audioTranscribing => 'Transcribing audio…';

  @override
  String get audioTranscriptionResult => 'Transcription Result';

  @override
  String get audioCopySuccess => 'Copied to clipboard';

  @override
  String get audioClear => 'Clear';

  @override
  String get audioSettingsTitle => 'Audio Settings';

  @override
  String get audioSettingsProvider => 'Provider';

  @override
  String get audioSettingsBackplanePreset => 'Backplane (Default)';

  @override
  String get audioSettingsCustomOpenAi => 'Custom OpenAI-Compatible';

  @override
  String get audioSettingsBaseUrl => 'Base URL';

  @override
  String get audioSettingsAccount => 'Service Account';

  @override
  String get audioSettingsUseDummyToken =>
      'Use dummy token (for unauthenticated local APIs)';

  @override
  String get audioSettingsTtsModel => 'Default TTS Model';

  @override
  String get audioSettingsTtsVoice => 'Default TTS Voice';

  @override
  String get audioSettingsTtsSpeed => 'Speech Speed';

  @override
  String get audioSettingsTtsFormat => 'Audio Format';

  @override
  String get audioSettingsAsrModel => 'Default ASR Model';

  @override
  String get audioSettingsAsrLanguage => 'Language Code (e.g. en, zh)';

  @override
  String get audioSettingsResetButton => 'Reset to Backplane Defaults';

  @override
  String get audioSettingsSaveButton => 'Save Settings';

  @override
  String get cameraTitle => '相机';

  @override
  String get cameraNoHardwareTitle => '没有可用相机';

  @override
  String get cameraNoHardwareDescription => '当前设备未检测到相机硬件，或相机暂时不可用。';

  @override
  String get cameraBackToToolbox => '返回工具箱';

  @override
  String get cameraErrorTitle => '相机错误';

  @override
  String get editorTitle => '编辑器';

  @override
  String get editorNew => '新建';

  @override
  String get editorOpen => '打开';

  @override
  String get editorSave => '保存';

  @override
  String get editorSaveAs => '另存为';

  @override
  String get editorUndo => '撤销';

  @override
  String get editorRedo => '重做';

  @override
  String get editorUnsaved => '未保存的修改';

  @override
  String get editorConfirmTitle => '保存修改？';

  @override
  String get editorConfirmMessage => '继续而不保存将丢失当前修改。';

  @override
  String get editorDiscard => '放弃';

  @override
  String get editorCancel => '取消';

  @override
  String get editorUnsupportedEncoding => '此文件不是有效的 UTF-8 文本。';

  @override
  String get editorBinaryFile => '此文件包含二进制数据，无法编辑。';

  @override
  String get editorTooLarge => '文件过大。请选择小于 16 MiB 的文件。';

  @override
  String get editorReadFailed => '无法打开文件，已保留当前文档。';

  @override
  String get editorWriteFailed => '无法保存文件，已保留当前修改。';

  @override
  String get activityMonitorTitle => '活动监视器';

  @override
  String get activityMonitorUnsupported =>
      '活动监视器目前支持 Intel 和 Apple Silicon 的 macOS 设备，以及 x86_64 和 ARM64 的 Linux 设备。';

  @override
  String get activityMonitorLoading => '正在采集设备活动…';

  @override
  String get activityMonitorFailed => '无法读取设备活动，请重试。';

  @override
  String get activityMonitorSampling => '实时 · 每秒刷新';

  @override
  String get activityMonitorPaused => '采样已暂停';

  @override
  String get activityMonitorUnavailable => '不可用';

  @override
  String get activityMonitorWaiting => '等待下一次采样';

  @override
  String get activityMonitorCpu => 'CPU';

  @override
  String get activityMonitorMemory => '内存';

  @override
  String get activityMonitorDisk => '磁盘活动';

  @override
  String get activityMonitorNetwork => '网络活动';

  @override
  String get activityMonitorGpu => 'GPU';

  @override
  String get activityMonitorProcesses => '进程与线程';

  @override
  String get activityMonitorUsed => '已用';

  @override
  String get activityMonitorTotal => '物理内存';

  @override
  String get activityMonitorWired => '不可分页内存';

  @override
  String get activityMonitorCompressed => '压缩内存';

  @override
  String get activityMonitorSwap => '交换空间 已用 / 总量';

  @override
  String get activityMonitorPressure => '内存压力';

  @override
  String get activityMonitorPressureNormal => '正常';

  @override
  String get activityMonitorPressureWarning => '警告';

  @override
  String get activityMonitorPressureCritical => '严重';

  @override
  String get activityMonitorRead => '读取';

  @override
  String get activityMonitorWrite => '写入';

  @override
  String get activityMonitorReceived => '接收';

  @override
  String get activityMonitorSent => '发送';

  @override
  String get activityMonitorProcessCount => '进程数';

  @override
  String get activityMonitorThreadCount => '线程数';

  @override
  String get activityMonitorPartialThreads => '线程数仅包含可读取的进程。';

  @override
  String activityMonitorPerformanceCore(int id) {
    return '性能核心 P$id';
  }

  @override
  String activityMonitorEfficiencyCore(int id) {
    return '能效核心 E$id';
  }

  @override
  String activityMonitorCore(int id) {
    return '核心 $id';
  }

  @override
  String get activityMonitorHistory => '最近采样';

  @override
  String activityMonitorUpdated(String time) {
    return '更新于 $time';
  }

  @override
  String get activityMonitorGpuUnavailable => '此设备未提供 GPU 活动数据。';

  @override
  String get activityMonitorTelemetry => '系统遥测';

  @override
  String get activityMonitorThisDevice => '当前设备';

  @override
  String get activityMonitorLogicalCores => '逻辑核心';

  @override
  String get activityMonitorSamples => '采样数';

  @override
  String get activityMonitorCpuHistory => 'CPU 历史';

  @override
  String get activityMonitorCoreLoad => '核心负载';

  @override
  String get activityMonitorGpuHistory => 'GPU 历史';

  @override
  String get activityMonitorUser => '用户';

  @override
  String get activityMonitorSystem => '系统';

  @override
  String get activityMonitorIdle => '空闲';

  @override
  String get activityMonitorAppMemory => '应用内存';

  @override
  String get activityMonitorCachedFiles => '缓存文件';

  @override
  String get activityMonitorSwapUsed => '已用交换空间';

  @override
  String get activityMonitorSwapTotal => '交换空间总量';

  @override
  String get activityMonitorBytes => '字节';

  @override
  String get activityMonitorOperations => '次数';

  @override
  String get activityMonitorPackets => '数据包';

  @override
  String get activityMonitorEarlier => '较早';

  @override
  String get activityMonitorNow => '现在';

  @override
  String get activityMonitorPause => '暂停';

  @override
  String get activityMonitorResume => '继续';

  @override
  String get activityMonitorDataSources => '数据来源与统计口径';

  @override
  String get activityMonitorDataNotes =>
      '数据来自操作系统原生计数器。CPU 使用率与 I/O 速率根据相邻采样差值和单调时钟计算。首个样本仅建立基线，未知值保持不可用。曲线保留最近 60 个样本，缺失数据或计数器重置后重新开始。核心类型仅在系统提供时显示。暂停或离开此页面会停止采样。';

  @override
  String get activityMonitorMemoryNotes =>
      '应用内存与缓存文件按原生 VM 计数估算，可能与其他监视器存在差异。内存压力展示系统报告的等级，并非百分比。';

  @override
  String get activityMonitorCumulative => '累计';

  @override
  String get activityMonitorRate => '速率';

  @override
  String activityMonitorHistoryWindow(int count) {
    return '最近 $count / 60 个样本 · 每秒采样';
  }
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

  @override
  String get cameraTitle => '相机';

  @override
  String get cameraNoHardwareTitle => '没有可用相机';

  @override
  String get cameraNoHardwareDescription => '当前设备未检测到相机硬件，或相机暂时不可用。';

  @override
  String get cameraBackToToolbox => '返回工具箱';

  @override
  String get cameraErrorTitle => '相机错误';

  @override
  String get editorTitle => '编辑器';

  @override
  String get editorNew => '新建';

  @override
  String get editorOpen => '打开';

  @override
  String get editorSave => '保存';

  @override
  String get editorSaveAs => '另存为';

  @override
  String get editorUndo => '撤销';

  @override
  String get editorRedo => '重做';

  @override
  String get editorUnsaved => '未保存的修改';

  @override
  String get editorConfirmTitle => '保存修改？';

  @override
  String get editorConfirmMessage => '继续而不保存将丢失当前修改。';

  @override
  String get editorDiscard => '放弃';

  @override
  String get editorCancel => '取消';

  @override
  String get editorUnsupportedEncoding => '此文件不是有效的 UTF-8 文本。';

  @override
  String get editorBinaryFile => '此文件包含二进制数据，无法编辑。';

  @override
  String get editorTooLarge => '文件过大。请选择小于 16 MiB 的文件。';

  @override
  String get editorReadFailed => '无法打开文件，已保留当前文档。';

  @override
  String get editorWriteFailed => '无法保存文件，已保留当前修改。';

  @override
  String get activityMonitorTitle => '活动监视器';

  @override
  String get activityMonitorUnsupported =>
      '活动监视器目前支持 Intel 和 Apple Silicon 的 macOS 设备，以及 x86_64 和 ARM64 的 Linux 设备。';

  @override
  String get activityMonitorLoading => '正在采集设备活动…';

  @override
  String get activityMonitorFailed => '无法读取设备活动，请重试。';

  @override
  String get activityMonitorSampling => '实时 · 每秒刷新';

  @override
  String get activityMonitorPaused => '采样已暂停';

  @override
  String get activityMonitorUnavailable => '不可用';

  @override
  String get activityMonitorWaiting => '等待下一次采样';

  @override
  String get activityMonitorCpu => 'CPU';

  @override
  String get activityMonitorMemory => '内存';

  @override
  String get activityMonitorDisk => '磁盘活动';

  @override
  String get activityMonitorNetwork => '网络活动';

  @override
  String get activityMonitorGpu => 'GPU';

  @override
  String get activityMonitorProcesses => '进程与线程';

  @override
  String get activityMonitorUsed => '已用';

  @override
  String get activityMonitorTotal => '物理内存';

  @override
  String get activityMonitorWired => '不可分页内存';

  @override
  String get activityMonitorCompressed => '压缩内存';

  @override
  String get activityMonitorSwap => '交换空间 已用 / 总量';

  @override
  String get activityMonitorPressure => '内存压力';

  @override
  String get activityMonitorPressureNormal => '正常';

  @override
  String get activityMonitorPressureWarning => '警告';

  @override
  String get activityMonitorPressureCritical => '严重';

  @override
  String get activityMonitorRead => '读取';

  @override
  String get activityMonitorWrite => '写入';

  @override
  String get activityMonitorReceived => '接收';

  @override
  String get activityMonitorSent => '发送';

  @override
  String get activityMonitorProcessCount => '进程数';

  @override
  String get activityMonitorThreadCount => '线程数';

  @override
  String get activityMonitorPartialThreads => '线程数仅包含可读取的进程。';

  @override
  String activityMonitorPerformanceCore(int id) {
    return '性能核心 P$id';
  }

  @override
  String activityMonitorEfficiencyCore(int id) {
    return '能效核心 E$id';
  }

  @override
  String activityMonitorCore(int id) {
    return '核心 $id';
  }

  @override
  String get activityMonitorHistory => '最近采样';

  @override
  String activityMonitorUpdated(String time) {
    return '更新于 $time';
  }

  @override
  String get activityMonitorGpuUnavailable => '此设备未提供 GPU 活动数据。';

  @override
  String get activityMonitorTelemetry => '系统遥测';

  @override
  String get activityMonitorThisDevice => '当前设备';

  @override
  String get activityMonitorLogicalCores => '逻辑核心';

  @override
  String get activityMonitorSamples => '采样数';

  @override
  String get activityMonitorCpuHistory => 'CPU 历史';

  @override
  String get activityMonitorCoreLoad => '核心负载';

  @override
  String get activityMonitorGpuHistory => 'GPU 历史';

  @override
  String get activityMonitorUser => '用户';

  @override
  String get activityMonitorSystem => '系统';

  @override
  String get activityMonitorIdle => '空闲';

  @override
  String get activityMonitorAppMemory => '应用内存';

  @override
  String get activityMonitorCachedFiles => '缓存文件';

  @override
  String get activityMonitorSwapUsed => '已用交换空间';

  @override
  String get activityMonitorSwapTotal => '交换空间总量';

  @override
  String get activityMonitorBytes => '字节';

  @override
  String get activityMonitorOperations => '次数';

  @override
  String get activityMonitorPackets => '数据包';

  @override
  String get activityMonitorEarlier => '较早';

  @override
  String get activityMonitorNow => '现在';

  @override
  String get activityMonitorPause => '暂停';

  @override
  String get activityMonitorResume => '继续';

  @override
  String get activityMonitorDataSources => '数据来源与统计口径';

  @override
  String get activityMonitorDataNotes =>
      '数据来自操作系统原生计数器。CPU 使用率与 I/O 速率根据相邻采样差值和单调时钟计算。首个样本仅建立基线，未知值保持不可用。曲线保留最近 60 个样本，缺失数据或计数器重置后重新开始。核心类型仅在系统提供时显示。暂停或离开此页面会停止采样。';

  @override
  String get activityMonitorMemoryNotes =>
      '应用内存与缓存文件按原生 VM 计数估算，可能与其他监视器存在差异。内存压力展示系统报告的等级，并非百分比。';

  @override
  String get activityMonitorCumulative => '累计';

  @override
  String get activityMonitorRate => '速率';

  @override
  String activityMonitorHistoryWindow(int count) {
    return '最近 $count / 60 个样本 · 每秒采样';
  }
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

  @override
  String get cameraTitle => '相機';

  @override
  String get cameraNoHardwareTitle => '沒有可用相機';

  @override
  String get cameraNoHardwareDescription => '目前裝置未偵測到相機硬體，或相機暫時無法使用。';

  @override
  String get cameraBackToToolbox => '返回工具箱';

  @override
  String get cameraErrorTitle => '相機錯誤';

  @override
  String get activityMonitorTelemetry => '系統遙測';

  @override
  String get activityMonitorThisDevice => '目前裝置';

  @override
  String get activityMonitorLogicalCores => '邏輯核心';

  @override
  String get activityMonitorSamples => '取樣數';

  @override
  String get activityMonitorCpuHistory => 'CPU 歷史';

  @override
  String get activityMonitorCoreLoad => '核心負載';

  @override
  String get activityMonitorGpuHistory => 'GPU 歷史';

  @override
  String get activityMonitorUser => '使用者';

  @override
  String get activityMonitorSystem => '系統';

  @override
  String get activityMonitorIdle => '閒置';

  @override
  String get activityMonitorAppMemory => '應用程式記憶體';

  @override
  String get activityMonitorCachedFiles => '快取檔案';

  @override
  String get activityMonitorSwapUsed => '已用交換空間';

  @override
  String get activityMonitorSwapTotal => '交換空間總量';

  @override
  String get activityMonitorBytes => '位元組';

  @override
  String get activityMonitorOperations => '次數';

  @override
  String get activityMonitorPackets => '封包';

  @override
  String get activityMonitorEarlier => '較早';

  @override
  String get activityMonitorNow => '現在';

  @override
  String get activityMonitorPause => '暫停';

  @override
  String get activityMonitorResume => '繼續';

  @override
  String get activityMonitorDataSources => '資料來源與統計方式';

  @override
  String get activityMonitorDataNotes =>
      '資料來自作業系統原生計數器。CPU 使用率與 I/O 速率根據相鄰取樣差值和單調時鐘計算。首個樣本僅建立基準，未知值維持無法使用。曲線保留最近 60 個樣本，資料缺失或計數器重設後重新開始。核心類型僅在系統提供時顯示。暫停或離開此頁面會停止取樣。';

  @override
  String get activityMonitorMemoryNotes =>
      '應用程式記憶體與快取檔案按原生 VM 計數估算，可能與其他監視器存在差異。記憶體壓力顯示系統回報的等級，並非百分比。';

  @override
  String get activityMonitorCumulative => '累計';

  @override
  String get activityMonitorRate => '速率';

  @override
  String activityMonitorHistoryWindow(int count) {
    return '最近 $count / 60 個樣本 · 每秒取樣';
  }
}
