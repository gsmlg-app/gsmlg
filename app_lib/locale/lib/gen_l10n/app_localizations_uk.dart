// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'Шаблон додатку Flutter';

  @override
  String get errorOccurred => 'Виникла помилка';

  @override
  String get backToHome => 'Повернутися на головну';

  @override
  String get welcomeHome => 'Ласкаво просимо до мого додатку';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Скасувати';

  @override
  String get loading => 'Завантаження';

  @override
  String get success => 'Успіх';

  @override
  String get error => 'Помилка';

  @override
  String get undo => 'Скасувати';

  @override
  String get navHome => 'Головна';

  @override
  String get navService => 'Service';

  @override
  String get navToolbox => 'Toolbox';

  @override
  String get navShowcase => 'Вітрина';

  @override
  String get navSetting => 'Налаштування';

  @override
  String get settingsTitle => 'Налаштування YellowDog';

  @override
  String get smenuTheme => 'Тема';

  @override
  String get appearance => 'Зовнішній вигляд';

  @override
  String get accentColor => 'Колір акценту';

  @override
  String get language => 'Мова';

  @override
  String get retry => 'Повторити';

  @override
  String get lightTheme => 'Світла';

  @override
  String get darkTheme => 'Темна';

  @override
  String get systemTheme => 'Системна';

  @override
  String get nslookupTitle => 'Пошук NS YellowDog';

  @override
  String get bmenuNSLookup => 'Пошук NS';

  @override
  String get bmenuBenchmark => 'Тестування';

  @override
  String get bmenuDns => 'Сервер';

  @override
  String get bmenuMDns => 'mDNS';

  @override
  String get bmenuSettings => 'Налаштування';

  @override
  String get textLabelRRName => 'Ім\'я';

  @override
  String get textHintRRName => 'Ім\'я запису DNS';

  @override
  String get textLabelRRType => 'Тип';

  @override
  String get textHintRRType => 'Тип запису DNS';

  @override
  String get textLabelRRClass => 'Клас';

  @override
  String get textHintRRClass => 'Клас DNS';

  @override
  String get textLabelRRData => 'Дані';

  @override
  String get textLabelRRTimeToLive => 'TTL';

  @override
  String get textLabelProtocol => 'Протокол';

  @override
  String get textHintProtocol => 'Протокол запиту DNS';

  @override
  String get textLabelServer => 'Сервер імен';

  @override
  String get textHintServer =>
      'DNS-сервер, наприклад, 8.8.8.8#53 або 2001:4860:4860::8888#53';

  @override
  String get textLabelECS => 'ECS';

  @override
  String get textHintECS => 'EDNS Client Subnet';

  @override
  String get textLabelDNSSEC => 'DNSSEC';

  @override
  String get buttonLookup => 'Пошук';

  @override
  String get labelAnswer => 'Відповідь';

  @override
  String get buttonClearResult => 'Очистити результат';

  @override
  String get benchmarkTitle => 'Тестування YellowDog';

  @override
  String get textLabelSourceFile => 'Вихідний файл';

  @override
  String get buttonManageSourceFile => 'Керування файлом';

  @override
  String get textLabelConcurrencyClients => 'Клієнти';

  @override
  String get textHintConcurrencyClients => 'наприклад, 10';

  @override
  String get textLabelNTimes => 'Кількість повторів';

  @override
  String get textHintNTimes => 'наприклад, 10';

  @override
  String get buttonBenchmark => 'Запустити тест';

  @override
  String get labelBenchmarkResult => 'Результат тесту';

  @override
  String get labelError => 'Помилка';

  @override
  String get buttonAtRunning => 'Виконується';

  @override
  String get nameServerTitle => 'Сервер імен YellowDog';

  @override
  String get nameServerSecondaryTitle => 'Журнал у режимі реального часу';

  @override
  String get textLabelServerPort => 'Порт сервера';

  @override
  String get textHintServerPort => 'наприклад, 53';

  @override
  String get textLabelForwarderAddress => 'Адреса пересилання';

  @override
  String get textHintForwarderAddress => 'наприклад, 8.8.8.8';

  @override
  String get textLabelForwarderPort => 'Порт пересилання';

  @override
  String get textHintForwarderPort => 'наприклад, 53';

  @override
  String get buttonStartServer => 'Запустити сервер';

  @override
  String get buttonStopServer => 'Зупинити сервер';

  @override
  String get smenuAppearance => 'Зовнішній вигляд';

  @override
  String get smenuColorTheme => 'Кольорова тема';

  @override
  String get smenuBenchmark => 'Тестування';

  @override
  String get smenuSourceFile => 'Вихідний файл';

  @override
  String get titleSelectAppearance => 'Виберіть зовнішній вигляд';

  @override
  String get titleSelectColorTheme => 'Виберіть кольорову тему';

  @override
  String get benchmarkSourceTitle => 'Джерело даних для тестування';

  @override
  String get smenuAddFile => 'Додати файл';

  @override
  String get labelLoading => 'Завантаження';

  @override
  String get addBenchmarkSourceTitle => 'Додати джерело даних';

  @override
  String get editBenchmarkSourceTitle => 'Редагувати джерело даних';

  @override
  String get showBenchmarkSourceTitle => 'Показати джерело даних';

  @override
  String get textLabelSourceFileName => 'Ім\'я';

  @override
  String get textHintSourceFileName => 'наприклад, Топ 10 записів';

  @override
  String get textLabelSourceFileContent => 'Вміст';

  @override
  String get textHintSourceFileContent =>
      'наприклад:\nwww.example.com A\nexample.com CNAME';

  @override
  String get buttonAddSourceFile => 'Додати';

  @override
  String get buttonEditSourceFile => 'Редагувати';

  @override
  String get buttonUpdateSourceFile => 'Оновити';

  @override
  String get buttonDeleteSourceFile => 'Видалити';

  @override
  String get mdnsTitle => 'Multicast DNS';

  @override
  String get mdnsTitleSecondary => 'Результат mDNS';

  @override
  String get mdnsTabTitleQuery => 'Запит';

  @override
  String get mdnsTabTitleListen => 'Прослуховування';

  @override
  String get mdnsQueryForm => 'Форма запиту';

  @override
  String get mdnsListenForm => 'Прослуховування повідомлень MDNS';

  @override
  String get required => 'Обов\'язково';

  @override
  String get invalidAddress => 'Недійсна адреса';

  @override
  String get invalidPort => 'Недійсний порт';

  @override
  String get start => 'Старт';

  @override
  String get stop => 'Стоп';

  @override
  String get pause => 'Пауза';

  @override
  String get resume => 'Продовжити';

  @override
  String get clear => 'Очистити';

  @override
  String get noData => 'Немає даних';

  @override
  String get smenuYellowDog => 'YellowDog';

  @override
  String get smenuSmenuYellowDog => 'Про YellowDog';

  @override
  String get titleAboutYellowDog => 'Про YellowDog';

  @override
  String get aboutYellowDog => 'В пам\'ять про YellowDog, 1988 - 1990';

  @override
  String get aboutYellowDog2 => 'Ти сильний, розумний та вірний пес';

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
  String get compassTitle => 'Compass';

  @override
  String get compassMagneticNorth => 'Magnetic north';

  @override
  String get compassWaitingForSensor => 'Waiting for compass readings…';

  @override
  String get compassUnavailable =>
      'This device does not have the required compass sensors.';

  @override
  String get compassUnsupportedPlatform =>
      'Compass is available on Android and iOS.';

  @override
  String get compassSensorError => 'Unable to read the compass. Try again.';

  @override
  String get compassCalibrationNeeded => 'Calibration recommended';

  @override
  String get compassHelpTitle => 'Using and calibrating the compass';

  @override
  String get compassHelpBody =>
      'Hold your phone flat and keep it away from metal and magnetic accessories. If calibration is recommended, slowly move your phone in a figure-eight pattern. Readings use magnetic north.';

  @override
  String get compassDirectionNorth => 'North';

  @override
  String get compassDirectionNorthEast => 'Northeast';

  @override
  String get compassDirectionEast => 'East';

  @override
  String get compassDirectionSouthEast => 'Southeast';

  @override
  String get compassDirectionSouth => 'South';

  @override
  String get compassDirectionSouthWest => 'Southwest';

  @override
  String get compassDirectionWest => 'West';

  @override
  String get compassDirectionNorthWest => 'Northwest';

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
  String get cameraTitle => 'Camera';

  @override
  String get cameraNoHardwareTitle => 'No Camera Available';

  @override
  String get cameraNoHardwareDescription =>
      'No camera hardware was detected on this device or the camera is currently unavailable.';

  @override
  String get cameraBackToToolbox => 'Back to Toolbox';

  @override
  String get cameraErrorTitle => 'Camera Error';

  @override
  String get editorTitle => 'Editor';

  @override
  String get editorNew => 'New';

  @override
  String get editorOpen => 'Open';

  @override
  String get editorSave => 'Save';

  @override
  String get editorSaveAs => 'Save As';

  @override
  String get editorUndo => 'Undo';

  @override
  String get editorRedo => 'Redo';

  @override
  String get editorUnsaved => 'Unsaved changes';

  @override
  String get editorConfirmTitle => 'Save changes?';

  @override
  String get editorConfirmMessage =>
      'Your changes will be lost if you continue without saving.';

  @override
  String get editorDiscard => 'Discard';

  @override
  String get editorCancel => 'Cancel';

  @override
  String get editorUnsupportedEncoding => 'This file is not valid UTF-8 text.';

  @override
  String get editorBinaryFile =>
      'This file contains binary data and cannot be edited.';

  @override
  String get editorTooLarge =>
      'This file is too large. Open a file smaller than 16 MiB.';

  @override
  String get editorReadFailed =>
      'The file could not be opened. Your document has been kept.';

  @override
  String get editorWriteFailed =>
      'The file could not be saved. Your changes have been kept.';

  @override
  String get activityMonitorTitle => 'Activity Monitor';

  @override
  String get activityMonitorUnsupported =>
      'Activity Monitor currently supports macOS on Intel and Apple Silicon, and Linux on x86_64 and ARM64.';

  @override
  String get activityMonitorLoading => 'Collecting device activity…';

  @override
  String get activityMonitorFailed =>
      'Could not read device activity. Try again.';

  @override
  String get activityMonitorSampling => 'Live · refreshes every second';

  @override
  String get activityMonitorPaused => 'Sampling paused';

  @override
  String get activityMonitorUnavailable => 'Unavailable';

  @override
  String get activityMonitorWaiting => 'Waiting for next sample';

  @override
  String get activityMonitorCpu => 'CPU';

  @override
  String get activityMonitorMemory => 'Memory';

  @override
  String get activityMonitorDisk => 'Disk Activity';

  @override
  String get activityMonitorNetwork => 'Network Activity';

  @override
  String get activityMonitorGpu => 'GPU';

  @override
  String get activityMonitorProcesses => 'Processes & Threads';

  @override
  String get activityMonitorUsed => 'Used';

  @override
  String get activityMonitorTotal => 'Physical memory';

  @override
  String get activityMonitorWired => 'Wired';

  @override
  String get activityMonitorCompressed => 'Compressed';

  @override
  String get activityMonitorSwap => 'Swap used / total';

  @override
  String get activityMonitorPressure => 'Memory pressure';

  @override
  String get activityMonitorPressureNormal => 'Normal';

  @override
  String get activityMonitorPressureWarning => 'Warning';

  @override
  String get activityMonitorPressureCritical => 'Critical';

  @override
  String get activityMonitorRead => 'Read';

  @override
  String get activityMonitorWrite => 'Write';

  @override
  String get activityMonitorReceived => 'Received';

  @override
  String get activityMonitorSent => 'Sent';

  @override
  String get activityMonitorProcessCount => 'Processes';

  @override
  String get activityMonitorThreadCount => 'Threads';

  @override
  String get activityMonitorPartialThreads =>
      'Thread count includes readable processes only.';

  @override
  String activityMonitorPerformanceCore(int id) {
    return 'Performance P$id';
  }

  @override
  String activityMonitorEfficiencyCore(int id) {
    return 'Efficiency E$id';
  }

  @override
  String activityMonitorCore(int id) {
    return 'Core $id';
  }

  @override
  String get activityMonitorHistory => 'Recent samples';

  @override
  String activityMonitorUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get activityMonitorGpuUnavailable =>
      'GPU activity is not exposed by this device.';

  @override
  String get activityMonitorTelemetry => 'System telemetry';

  @override
  String get activityMonitorThisDevice => 'This device';

  @override
  String get activityMonitorLogicalCores => 'Logical cores';

  @override
  String get activityMonitorSamples => 'Samples';

  @override
  String get activityMonitorCpuHistory => 'CPU history';

  @override
  String get activityMonitorCoreLoad => 'Core load';

  @override
  String get activityMonitorGpuHistory => 'GPU history';

  @override
  String get activityMonitorUser => 'User';

  @override
  String get activityMonitorSystem => 'System';

  @override
  String get activityMonitorIdle => 'Idle';

  @override
  String get activityMonitorAppMemory => 'Application memory';

  @override
  String get activityMonitorCachedFiles => 'Cached files';

  @override
  String get activityMonitorSwapUsed => 'Swap used';

  @override
  String get activityMonitorSwapTotal => 'Swap total';

  @override
  String get activityMonitorBytes => 'Bytes';

  @override
  String get activityMonitorOperations => 'Operations';

  @override
  String get activityMonitorPackets => 'Packets';

  @override
  String get activityMonitorEarlier => 'Earlier';

  @override
  String get activityMonitorNow => 'Now';

  @override
  String get activityMonitorPause => 'Pause';

  @override
  String get activityMonitorResume => 'Resume';

  @override
  String get activityMonitorDataSources => 'Data sources and measurement notes';

  @override
  String get activityMonitorDataNotes =>
      'Metrics come from native OS counters. CPU and I/O rates use differences between consecutive samples and a monotonic clock. The first sample establishes a baseline; unavailable readings remain unavailable. Histories keep the latest 60 samples and restart after missing data or counter resets. Core types are shown only when reported by the OS. Pausing or leaving this page stops sampling.';

  @override
  String get activityMonitorMemoryNotes =>
      'Application and cached memory use native VM counters and may differ from other monitors. Memory pressure shows an OS-reported level, not a percentage.';

  @override
  String get activityMonitorCumulative => 'Cumulative';

  @override
  String get activityMonitorRate => 'Rate';

  @override
  String activityMonitorHistoryWindow(int count) {
    return '$count / 60 samples · 1 s cadence';
  }

  @override
  String get show => 'Показати';

  @override
  String get hide => 'Приховати';

  @override
  String get exit => 'Вийти';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Редагувати';

  @override
  String get delete => 'Видалити';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get reload => 'Reload';

  @override
  String get copy => 'Copy';

  @override
  String get destinationTerminal => 'Terminal';

  @override
  String get destinationWebTerminal => 'Web Terminal';

  @override
  String get destinationSetting => 'Налаштування';

  @override
  String get smenuSSH => 'SSH';

  @override
  String get sshHost => 'Host';

  @override
  String get titleSSHHost => 'SSH Host';

  @override
  String get addSshHost => 'Add SSH Host';

  @override
  String get editSshHost => 'Edit SSH Host';

  @override
  String get sshKey => 'SSH Key';

  @override
  String get titleSSHKey => 'SSH Key';

  @override
  String get addSshKey => 'Add SSH Key';

  @override
  String get showPublicKey => 'Show Public Key';

  @override
  String get sshKeyNameLabel => 'Name';

  @override
  String get sshKeyNameHint => 'Name of your SSH Key';

  @override
  String get sshKeyContentLabel => 'Key Content';

  @override
  String get sshKeyGenerate => 'Generate SSH Key';

  @override
  String get sshKeyImport => 'Імпортувати з файлу';

  @override
  String get sshKeyImportError =>
      'Не вдалося прочитати файл приватного ключа. Виберіть непорожній текстовий файл у кодуванні UTF-8.';

  @override
  String get deleteSshKeyMessage =>
      'Are you sure you want to delete this SSH Key?';

  @override
  String get publicKey => 'Public Key';

  @override
  String get sshHostHostLabel => 'Host';

  @override
  String get sshHostHostnameLabel => 'Hostname';

  @override
  String get sshHostPortLabel => 'Port';

  @override
  String get sshHostUsernameLabel => 'Username';

  @override
  String get sshHostIdentifyTypeLabel => 'Identify Type';

  @override
  String get sshHostIdentityTypePassword => 'Password';

  @override
  String get sshHostIdentityTypePrivateKey => 'Private Key';

  @override
  String get sshHostPasswordLabel => 'Password';

  @override
  String get sshHostPrivateKeyLabel => 'Private Key';

  @override
  String get deleteSshHostMessage =>
      'Are you sure you want to delete this SSH Host?';

  @override
  String get sshHostKeyTitle => 'Trust SSH host key?';

  @override
  String get sshHostKeyTrust => 'Trust and connect';

  @override
  String sshHostKeyPrompt(
      String hostname, int port, String type, String fingerprint) {
    return 'The identity of $hostname:$port is not yet trusted.\n\n$type\n$fingerprint\n\nCompare this fingerprint with the server administrator before trusting it.';
  }

  @override
  String get terminalTitle => 'Terminal';

  @override
  String get terminalConfigurationTitle => 'Terminal Configuration';

  @override
  String get terminalPreferencesTitle => 'Terminal Preferences';

  @override
  String get terminalEnvironmentTitle => 'Environment Variables';

  @override
  String get shellProfilesTitle => 'Shell Profiles';

  @override
  String get terminalBrowserUnsupported =>
      'Terminal is available in the Android, iOS, macOS, Linux, and Windows apps.';
}
