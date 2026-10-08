// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Flutter 앱 템플릿';

  @override
  String get errorOccurred => '오류가 발생했습니다';

  @override
  String get backToHome => '홈으로 돌아가기';

  @override
  String get welcomeHome => '내 앱에 오신 것을 환영합니다';

  @override
  String get ok => '확인';

  @override
  String get cancel => '취소';

  @override
  String get loading => '로드 중';

  @override
  String get success => '성공';

  @override
  String get error => '오류';

  @override
  String get undo => '실행 취소';

  @override
  String get navHome => '홈';

  @override
  String get navService => 'Service';

  @override
  String get navToolbox => 'Toolbox';

  @override
  String get navShowcase => '쇼케이스';

  @override
  String get navSetting => '설정';

  @override
  String get settingsTitle => 'YellowDog 설정';

  @override
  String get smenuTheme => '테마';

  @override
  String get appearance => '모양';

  @override
  String get accentColor => '강조 색상';

  @override
  String get language => '언어';

  @override
  String get retry => '재시도';

  @override
  String get lightTheme => '라이트';

  @override
  String get darkTheme => '다크';

  @override
  String get systemTheme => '시스템';

  @override
  String get nslookupTitle => 'YellowDog NS 조회';

  @override
  String get bmenuNSLookup => 'NS 조회';

  @override
  String get bmenuBenchmark => '벤치마크';

  @override
  String get bmenuDns => '서버';

  @override
  String get bmenuMDns => 'mDNS';

  @override
  String get bmenuSettings => '설정';

  @override
  String get textLabelRRName => '이름';

  @override
  String get textHintRRName => 'DNS 리소스 레코드 이름';

  @override
  String get textLabelRRType => '유형';

  @override
  String get textHintRRType => 'DNS 리소스 레코드 유형';

  @override
  String get textLabelRRClass => '클래스';

  @override
  String get textHintRRClass => 'DNS 클래스';

  @override
  String get textLabelRRData => '데이터';

  @override
  String get textLabelRRTimeToLive => 'TTL';

  @override
  String get textLabelProtocol => '프로토콜';

  @override
  String get textHintProtocol => 'DNS 질의 프로토콜';

  @override
  String get textLabelServer => '네임 서버';

  @override
  String get textHintServer =>
      'DNS 서버, 예: 8.8.8.8#53 또는 2001:4860:4860::8888#53';

  @override
  String get textLabelECS => 'ECS';

  @override
  String get textHintECS => 'EDNS 클라이언트 서브넷';

  @override
  String get textLabelDNSSEC => 'DNSSEC';

  @override
  String get buttonLookup => '조회';

  @override
  String get labelAnswer => '응답';

  @override
  String get buttonClearResult => '결과 지우기';

  @override
  String get benchmarkTitle => 'YellowDog 벤치마크';

  @override
  String get textLabelSourceFile => '소스 파일';

  @override
  String get buttonManageSourceFile => '파일 관리';

  @override
  String get textLabelConcurrencyClients => '동시성 클라이언트';

  @override
  String get textHintConcurrencyClients => '예: 10';

  @override
  String get textLabelNTimes => 'N 회';

  @override
  String get textHintNTimes => '예: 10';

  @override
  String get buttonBenchmark => '벤치마크 실행';

  @override
  String get labelBenchmarkResult => '벤치마크 결과';

  @override
  String get labelError => '오류';

  @override
  String get buttonAtRunning => '실행 중';

  @override
  String get nameServerTitle => 'YellowDog 네임 서버';

  @override
  String get nameServerSecondaryTitle => '실시간 로그';

  @override
  String get textLabelServerPort => '서버 포트';

  @override
  String get textHintServerPort => '예: 53';

  @override
  String get textLabelForwarderAddress => '포워더 주소';

  @override
  String get textHintForwarderAddress => '예: 8.8.8.8';

  @override
  String get textLabelForwarderPort => '포워더 포트';

  @override
  String get textHintForwarderPort => '예: 53';

  @override
  String get buttonStartServer => '서버 시작';

  @override
  String get buttonStopServer => '서버 중지';

  @override
  String get smenuAppearance => '모양';

  @override
  String get smenuColorTheme => '색상 테마';

  @override
  String get smenuBenchmark => '벤치마크';

  @override
  String get smenuSourceFile => '소스 파일';

  @override
  String get titleSelectAppearance => '모양 선택';

  @override
  String get titleSelectColorTheme => '색상 테마 선택';

  @override
  String get benchmarkSourceTitle => '벤치마크 소스';

  @override
  String get smenuAddFile => '파일 추가';

  @override
  String get labelLoading => '로드 중';

  @override
  String get addBenchmarkSourceTitle => '벤치마크 소스 추가';

  @override
  String get editBenchmarkSourceTitle => '벤치마크 소스 편집';

  @override
  String get showBenchmarkSourceTitle => '벤치마크 소스 보기';

  @override
  String get textLabelSourceFileName => '이름';

  @override
  String get textHintSourceFileName => '예: 상위 10개 레코드';

  @override
  String get textLabelSourceFileContent => '내용';

  @override
  String get textHintSourceFileContent =>
      '예:\nwww.example.com A\nexample.com CNAME';

  @override
  String get buttonAddSourceFile => '추가';

  @override
  String get buttonEditSourceFile => '편집';

  @override
  String get buttonUpdateSourceFile => '업데이트';

  @override
  String get buttonDeleteSourceFile => '삭제';

  @override
  String get mdnsTitle => '멀티캐스트 DNS';

  @override
  String get mdnsTitleSecondary => 'mDNS 결과';

  @override
  String get mdnsTabTitleQuery => '질의';

  @override
  String get mdnsTabTitleListen => '수신';

  @override
  String get mdnsQueryForm => '질의 양식';

  @override
  String get mdnsListenForm => 'MDNS 메시지 수신';

  @override
  String get required => '필수';

  @override
  String get invalidAddress => '유효하지 않은 주소';

  @override
  String get invalidPort => '유효하지 않은 포트';

  @override
  String get start => '시작';

  @override
  String get stop => '중지';

  @override
  String get pause => '일시 중지';

  @override
  String get resume => '재개';

  @override
  String get clear => '지우기';

  @override
  String get noData => '데이터 없음';

  @override
  String get smenuYellowDog => 'YellowDog';

  @override
  String get smenuSmenuYellowDog => 'YellowDog 정보';

  @override
  String get titleAboutYellowDog => 'YellowDog 정보';

  @override
  String get aboutYellowDog => 'YellowDog, 1988 - 1990';

  @override
  String get aboutYellowDog2 => '당신은 강하고 똑똑하며 충성스러운 개입니다.';

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
}
