// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Шаблон приложения Flutter';

  @override
  String get errorOccurred => 'Произошла ошибка';

  @override
  String get backToHome => 'Вернуться на главную';

  @override
  String get welcomeHome => 'Добро пожаловать в мое приложение';

  @override
  String get ok => 'ОК';

  @override
  String get cancel => 'Отмена';

  @override
  String get loading => 'Загрузка';

  @override
  String get success => 'Успех';

  @override
  String get error => 'Ошибка';

  @override
  String get undo => 'Отменить';

  @override
  String get navHome => 'Главная';

  @override
  String get navService => 'Service';

  @override
  String get navToolbox => 'Toolbox';

  @override
  String get navShowcase => 'Витрина';

  @override
  String get navSetting => 'Настройки';

  @override
  String get settingsTitle => 'Настройки YellowDog';

  @override
  String get smenuTheme => 'Тема';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get accentColor => 'Цвет акцента';

  @override
  String get language => 'Язык';

  @override
  String get retry => 'Повторить';

  @override
  String get lightTheme => 'Светлая';

  @override
  String get darkTheme => 'Темная';

  @override
  String get systemTheme => 'Системная';

  @override
  String get nslookupTitle => 'Поиск NS YellowDog';

  @override
  String get bmenuNSLookup => 'Поиск NS';

  @override
  String get bmenuBenchmark => 'Тестирование';

  @override
  String get bmenuDns => 'Сервер';

  @override
  String get bmenuMDns => 'mDNS';

  @override
  String get bmenuSettings => 'Настройки';

  @override
  String get textLabelRRName => 'Имя';

  @override
  String get textHintRRName => 'Имя записи DNS';

  @override
  String get textLabelRRType => 'Тип';

  @override
  String get textHintRRType => 'Тип записи DNS';

  @override
  String get textLabelRRClass => 'Класс';

  @override
  String get textHintRRClass => 'Класс DNS';

  @override
  String get textLabelRRData => 'Данные';

  @override
  String get textLabelRRTimeToLive => 'TTL';

  @override
  String get textLabelProtocol => 'Протокол';

  @override
  String get textHintProtocol => 'Протокол запроса DNS';

  @override
  String get textLabelServer => 'Сервер имён';

  @override
  String get textHintServer =>
      'DNS-сервер, например, 8.8.8.8#53 или 2001:4860:4860::8888#53';

  @override
  String get textLabelECS => 'ECS';

  @override
  String get textHintECS => 'EDNS Client Subnet';

  @override
  String get textLabelDNSSEC => 'DNSSEC';

  @override
  String get buttonLookup => 'Поиск';

  @override
  String get labelAnswer => 'Ответ';

  @override
  String get buttonClearResult => 'Очистить результат';

  @override
  String get benchmarkTitle => 'Тестирование YellowDog';

  @override
  String get textLabelSourceFile => 'Исходный файл';

  @override
  String get buttonManageSourceFile => 'Управление файлом';

  @override
  String get textLabelConcurrencyClients => 'Клиенты';

  @override
  String get textHintConcurrencyClients => 'например, 10';

  @override
  String get textLabelNTimes => 'Количество повторений';

  @override
  String get textHintNTimes => 'например, 10';

  @override
  String get buttonBenchmark => 'Запустить тест';

  @override
  String get labelBenchmarkResult => 'Результат теста';

  @override
  String get labelError => 'Ошибка';

  @override
  String get buttonAtRunning => 'Выполняется';

  @override
  String get nameServerTitle => 'Сервер имён YellowDog';

  @override
  String get nameServerSecondaryTitle => 'Журнал в реальном времени';

  @override
  String get textLabelServerPort => 'Порт сервера';

  @override
  String get textHintServerPort => 'например, 53';

  @override
  String get textLabelForwarderAddress => 'Адрес пересылки';

  @override
  String get textHintForwarderAddress => 'например, 8.8.8.8';

  @override
  String get textLabelForwarderPort => 'Порт пересылки';

  @override
  String get textHintForwarderPort => 'например, 53';

  @override
  String get buttonStartServer => 'Запустить сервер';

  @override
  String get buttonStopServer => 'Остановить сервер';

  @override
  String get smenuAppearance => 'Внешний вид';

  @override
  String get smenuColorTheme => 'Цветовая тема';

  @override
  String get smenuBenchmark => 'Тестирование';

  @override
  String get smenuSourceFile => 'Исходный файл';

  @override
  String get titleSelectAppearance => 'Выберите внешний вид';

  @override
  String get titleSelectColorTheme => 'Выберите цветовую тему';

  @override
  String get benchmarkSourceTitle => 'Источник данных для тестирования';

  @override
  String get smenuAddFile => 'Добавить файл';

  @override
  String get labelLoading => 'Загрузка';

  @override
  String get addBenchmarkSourceTitle => 'Добавить источник данных';

  @override
  String get editBenchmarkSourceTitle => 'Редактировать источник данных';

  @override
  String get showBenchmarkSourceTitle => 'Показать источник данных';

  @override
  String get textLabelSourceFileName => 'Имя';

  @override
  String get textHintSourceFileName => 'например, Топ 10 записей';

  @override
  String get textLabelSourceFileContent => 'Содержание';

  @override
  String get textHintSourceFileContent =>
      'например:\nwww.example.com A\nexample.com CNAME';

  @override
  String get buttonAddSourceFile => 'Добавить';

  @override
  String get buttonEditSourceFile => 'Редактировать';

  @override
  String get buttonUpdateSourceFile => 'Обновить';

  @override
  String get buttonDeleteSourceFile => 'Удалить';

  @override
  String get mdnsTitle => 'Multicast DNS';

  @override
  String get mdnsTitleSecondary => 'Результат mDNS';

  @override
  String get mdnsTabTitleQuery => 'Запрос';

  @override
  String get mdnsTabTitleListen => 'Прослушивание';

  @override
  String get mdnsQueryForm => 'Форма запроса';

  @override
  String get mdnsListenForm => 'Прослушивание сообщений MDNS';

  @override
  String get required => 'Обязательно';

  @override
  String get invalidAddress => 'Неверный адрес';

  @override
  String get invalidPort => 'Неверный порт';

  @override
  String get start => 'Старт';

  @override
  String get stop => 'Стоп';

  @override
  String get pause => 'Пауза';

  @override
  String get resume => 'Продолжить';

  @override
  String get clear => 'Очистить';

  @override
  String get noData => 'Нет данных';

  @override
  String get smenuYellowDog => 'YellowDog';

  @override
  String get smenuSmenuYellowDog => 'О YellowDog';

  @override
  String get titleAboutYellowDog => 'О YellowDog';

  @override
  String get aboutYellowDog => 'В память о YellowDog, 1988 - 1990';

  @override
  String get aboutYellowDog2 => 'Ты сильная, умная и верная собака';

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
