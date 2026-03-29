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
}
