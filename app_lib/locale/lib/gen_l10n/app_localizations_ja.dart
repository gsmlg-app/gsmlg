// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Flutter アプリテンプレート';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get backToHome => 'ホームに戻る';

  @override
  String get welcomeHome => '私のアプリへようこそ';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'キャンセル';

  @override
  String get loading => '読み込み中';

  @override
  String get success => '成功';

  @override
  String get error => 'エラー';

  @override
  String get undo => '元に戻す';

  @override
  String get navHome => 'ホーム';

  @override
  String get navService => 'Service';

  @override
  String get navToolbox => 'Toolbox';

  @override
  String get navShowcase => 'ショーケース';

  @override
  String get navSetting => '設定';

  @override
  String get settingsTitle => 'YellowDog 設定';

  @override
  String get smenuTheme => 'テーマ';

  @override
  String get appearance => '外観';

  @override
  String get accentColor => 'アクセントカラー';

  @override
  String get language => '言語';

  @override
  String get retry => '再試行';

  @override
  String get lightTheme => 'ライト';

  @override
  String get darkTheme => 'ダーク';

  @override
  String get systemTheme => 'システム';

  @override
  String get nslookupTitle => 'YellowDog NS ルックアップ';

  @override
  String get bmenuNSLookup => 'NS ルックアップ';

  @override
  String get bmenuBenchmark => 'ベンチマーク';

  @override
  String get bmenuDns => 'サーバー';

  @override
  String get bmenuMDns => 'mDNS';

  @override
  String get bmenuSettings => '設定';

  @override
  String get textLabelRRName => '名前';

  @override
  String get textHintRRName => 'DNS リソースレコード名';

  @override
  String get textLabelRRType => 'タイプ';

  @override
  String get textHintRRType => 'DNS リソースレコードタイプ';

  @override
  String get textLabelRRClass => 'クラス';

  @override
  String get textHintRRClass => 'DNS クラス';

  @override
  String get textLabelRRData => 'データ';

  @override
  String get textLabelRRTimeToLive => 'TTL';

  @override
  String get textLabelProtocol => 'プロトコル';

  @override
  String get textHintProtocol => 'DNS クエリプロトコル';

  @override
  String get textLabelServer => 'ネームサーバー';

  @override
  String get textHintServer =>
      'DNS サーバー (例: 8.8.8.8#53 または 2001:4860:4860::8888#53)';

  @override
  String get textLabelECS => 'ECS';

  @override
  String get textHintECS => 'EDNS クライアントサブネット';

  @override
  String get textLabelDNSSEC => 'DNSSEC';

  @override
  String get buttonLookup => 'ルックアップ';

  @override
  String get labelAnswer => '回答';

  @override
  String get buttonClearResult => '結果をクリア';

  @override
  String get benchmarkTitle => 'YellowDog ベンチマーク';

  @override
  String get textLabelSourceFile => 'ソースファイル';

  @override
  String get buttonManageSourceFile => 'ファイルの管理';

  @override
  String get textLabelConcurrencyClients => '同時実行クライアント';

  @override
  String get textHintConcurrencyClients => '例: 10';

  @override
  String get textLabelNTimes => 'N 回';

  @override
  String get textHintNTimes => '例: 10';

  @override
  String get buttonBenchmark => 'ベンチマークの実行';

  @override
  String get labelBenchmarkResult => 'ベンチマーク結果';

  @override
  String get labelError => 'エラー';

  @override
  String get buttonAtRunning => '実行中';

  @override
  String get nameServerTitle => 'YellowDog ネームサーバー';

  @override
  String get nameServerSecondaryTitle => 'リアルタイムログ';

  @override
  String get textLabelServerPort => 'サーバーポート';

  @override
  String get textHintServerPort => '例: 53';

  @override
  String get textLabelForwarderAddress => 'フォワーダアドレス';

  @override
  String get textHintForwarderAddress => '例: 8.8.8.8';

  @override
  String get textLabelForwarderPort => 'フォワーダポート';

  @override
  String get textHintForwarderPort => '例: 53';

  @override
  String get buttonStartServer => 'サーバー起動';

  @override
  String get buttonStopServer => 'サーバー停止';

  @override
  String get smenuAppearance => '外観';

  @override
  String get smenuColorTheme => 'カラーテーマ';

  @override
  String get smenuBenchmark => 'ベンチマーク';

  @override
  String get smenuSourceFile => 'ソースファイル';

  @override
  String get titleSelectAppearance => '外観を選択';

  @override
  String get titleSelectColorTheme => 'カラーテーマを選択';

  @override
  String get benchmarkSourceTitle => 'ベンチマークソース';

  @override
  String get smenuAddFile => 'ファイルを追加';

  @override
  String get labelLoading => '読み込み中';

  @override
  String get addBenchmarkSourceTitle => 'ベンチマークソースを追加';

  @override
  String get editBenchmarkSourceTitle => 'ベンチマークソースを編集';

  @override
  String get showBenchmarkSourceTitle => 'ベンチマークソースを表示';

  @override
  String get textLabelSourceFileName => '名前';

  @override
  String get textHintSourceFileName => '例: 上位 10 件のレコード';

  @override
  String get textLabelSourceFileContent => '内容';

  @override
  String get textHintSourceFileContent =>
      '例:\nwww.example.com A\nexample.com CNAME';

  @override
  String get buttonAddSourceFile => '追加';

  @override
  String get buttonEditSourceFile => '編集';

  @override
  String get buttonUpdateSourceFile => '更新';

  @override
  String get buttonDeleteSourceFile => '削除';

  @override
  String get mdnsTitle => 'マルチキャスト DNS';

  @override
  String get mdnsTitleSecondary => 'mDNS 結果';

  @override
  String get mdnsTabTitleQuery => 'クエリ';

  @override
  String get mdnsTabTitleListen => 'リッスン';

  @override
  String get mdnsQueryForm => 'クエリフォーム';

  @override
  String get mdnsListenForm => 'mDNS メッセージをリッスン';

  @override
  String get required => '必須';

  @override
  String get invalidAddress => '無効なアドレス';

  @override
  String get invalidPort => '無効なポート';

  @override
  String get start => '開始';

  @override
  String get stop => '停止';

  @override
  String get pause => '一時停止';

  @override
  String get resume => '再開';

  @override
  String get clear => 'クリア';

  @override
  String get noData => 'データがありません';

  @override
  String get smenuYellowDog => 'YellowDog';

  @override
  String get smenuSmenuYellowDog => 'YellowDog について';

  @override
  String get titleAboutYellowDog => 'YellowDog について';

  @override
  String get aboutYellowDog => 'YellowDog を偲んで、1988-1990';

  @override
  String get aboutYellowDog2 => 'あなたは強く、賢く、忠実な犬です';

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
