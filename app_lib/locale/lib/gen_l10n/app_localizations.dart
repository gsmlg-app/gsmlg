import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uk.dart';
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
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('uk'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Flutter App Template'**
  String get appName;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error Occurred'**
  String get errorOccurred;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @welcomeHome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to my app'**
  String get welcomeHome;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get navService;

  /// No description provided for @navToolbox.
  ///
  /// In en, this message translates to:
  /// **'Toolbox'**
  String get navToolbox;

  /// No description provided for @navShowcase.
  ///
  /// In en, this message translates to:
  /// **'Showcase'**
  String get navShowcase;

  /// No description provided for @navSetting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get navSetting;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get settingsTitle;

  /// No description provided for @smenuTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get smenuTheme;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColor;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @nslookupTitle.
  ///
  /// In en, this message translates to:
  /// **'YellowDog NS Lookup'**
  String get nslookupTitle;

  /// No description provided for @bmenuNSLookup.
  ///
  /// In en, this message translates to:
  /// **'NS Lookup'**
  String get bmenuNSLookup;

  /// No description provided for @bmenuBenchmark.
  ///
  /// In en, this message translates to:
  /// **'Benchmark'**
  String get bmenuBenchmark;

  /// No description provided for @bmenuDns.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get bmenuDns;

  /// No description provided for @bmenuMDns.
  ///
  /// In en, this message translates to:
  /// **'mDNS'**
  String get bmenuMDns;

  /// No description provided for @bmenuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get bmenuSettings;

  /// No description provided for @textLabelRRName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get textLabelRRName;

  /// No description provided for @textHintRRName.
  ///
  /// In en, this message translates to:
  /// **'DNS Resource Record Name'**
  String get textHintRRName;

  /// No description provided for @textLabelRRType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get textLabelRRType;

  /// No description provided for @textHintRRType.
  ///
  /// In en, this message translates to:
  /// **'DNS Resource Record Type'**
  String get textHintRRType;

  /// No description provided for @textLabelRRClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get textLabelRRClass;

  /// No description provided for @textHintRRClass.
  ///
  /// In en, this message translates to:
  /// **'DNS Class'**
  String get textHintRRClass;

  /// No description provided for @textLabelRRData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get textLabelRRData;

  /// No description provided for @textLabelRRTimeToLive.
  ///
  /// In en, this message translates to:
  /// **'TTL'**
  String get textLabelRRTimeToLive;

  /// No description provided for @textLabelProtocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get textLabelProtocol;

  /// No description provided for @textHintProtocol.
  ///
  /// In en, this message translates to:
  /// **'DNS Query Protocol'**
  String get textHintProtocol;

  /// No description provided for @textLabelServer.
  ///
  /// In en, this message translates to:
  /// **'Name Server'**
  String get textLabelServer;

  /// No description provided for @textHintServer.
  ///
  /// In en, this message translates to:
  /// **'DNS Server, e.g. 8.8.8.8#53 or 2001:4860:4860::8888#53'**
  String get textHintServer;

  /// No description provided for @textLabelECS.
  ///
  /// In en, this message translates to:
  /// **'ECS'**
  String get textLabelECS;

  /// No description provided for @textHintECS.
  ///
  /// In en, this message translates to:
  /// **'EDNS Client Subnet'**
  String get textHintECS;

  /// No description provided for @textLabelDNSSEC.
  ///
  /// In en, this message translates to:
  /// **'DNSSEC'**
  String get textLabelDNSSEC;

  /// No description provided for @buttonLookup.
  ///
  /// In en, this message translates to:
  /// **'Lookup'**
  String get buttonLookup;

  /// No description provided for @labelAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get labelAnswer;

  /// No description provided for @buttonClearResult.
  ///
  /// In en, this message translates to:
  /// **'Clear Result'**
  String get buttonClearResult;

  /// No description provided for @benchmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'YellowDog Benchmark'**
  String get benchmarkTitle;

  /// No description provided for @textLabelSourceFile.
  ///
  /// In en, this message translates to:
  /// **'SourceFile'**
  String get textLabelSourceFile;

  /// No description provided for @buttonManageSourceFile.
  ///
  /// In en, this message translates to:
  /// **'Manage File'**
  String get buttonManageSourceFile;

  /// No description provided for @textLabelConcurrencyClients.
  ///
  /// In en, this message translates to:
  /// **'Concurrency Clients'**
  String get textLabelConcurrencyClients;

  /// No description provided for @textHintConcurrencyClients.
  ///
  /// In en, this message translates to:
  /// **'eg. 10'**
  String get textHintConcurrencyClients;

  /// No description provided for @textLabelNTimes.
  ///
  /// In en, this message translates to:
  /// **'N Times'**
  String get textLabelNTimes;

  /// No description provided for @textHintNTimes.
  ///
  /// In en, this message translates to:
  /// **'eg. 10'**
  String get textHintNTimes;

  /// No description provided for @buttonBenchmark.
  ///
  /// In en, this message translates to:
  /// **'Run Benchmark'**
  String get buttonBenchmark;

  /// No description provided for @labelBenchmarkResult.
  ///
  /// In en, this message translates to:
  /// **'Benchmark Result'**
  String get labelBenchmarkResult;

  /// No description provided for @labelError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get labelError;

  /// No description provided for @buttonAtRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get buttonAtRunning;

  /// No description provided for @nameServerTitle.
  ///
  /// In en, this message translates to:
  /// **'YellowDog Name Server'**
  String get nameServerTitle;

  /// No description provided for @nameServerSecondaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Realtime Log'**
  String get nameServerSecondaryTitle;

  /// No description provided for @textLabelServerPort.
  ///
  /// In en, this message translates to:
  /// **'Server Port'**
  String get textLabelServerPort;

  /// No description provided for @textHintServerPort.
  ///
  /// In en, this message translates to:
  /// **'eg. 53'**
  String get textHintServerPort;

  /// No description provided for @textLabelForwarderAddress.
  ///
  /// In en, this message translates to:
  /// **'Forwarder Address'**
  String get textLabelForwarderAddress;

  /// No description provided for @textHintForwarderAddress.
  ///
  /// In en, this message translates to:
  /// **'eg. 8.8.8.8'**
  String get textHintForwarderAddress;

  /// No description provided for @textLabelForwarderPort.
  ///
  /// In en, this message translates to:
  /// **'Forwarder Port'**
  String get textLabelForwarderPort;

  /// No description provided for @textHintForwarderPort.
  ///
  /// In en, this message translates to:
  /// **'eg. 53'**
  String get textHintForwarderPort;

  /// No description provided for @buttonStartServer.
  ///
  /// In en, this message translates to:
  /// **'Start Server'**
  String get buttonStartServer;

  /// No description provided for @buttonStopServer.
  ///
  /// In en, this message translates to:
  /// **'Stop Server'**
  String get buttonStopServer;

  /// No description provided for @smenuAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get smenuAppearance;

  /// No description provided for @smenuColorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get smenuColorTheme;

  /// No description provided for @smenuBenchmark.
  ///
  /// In en, this message translates to:
  /// **'Benchmark'**
  String get smenuBenchmark;

  /// No description provided for @smenuSourceFile.
  ///
  /// In en, this message translates to:
  /// **'Source File'**
  String get smenuSourceFile;

  /// No description provided for @titleSelectAppearance.
  ///
  /// In en, this message translates to:
  /// **'Select Appearance'**
  String get titleSelectAppearance;

  /// No description provided for @titleSelectColorTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Color Theme'**
  String get titleSelectColorTheme;

  /// No description provided for @benchmarkSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Benchmark Source'**
  String get benchmarkSourceTitle;

  /// No description provided for @smenuAddFile.
  ///
  /// In en, this message translates to:
  /// **'Add File'**
  String get smenuAddFile;

  /// No description provided for @labelLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get labelLoading;

  /// No description provided for @addBenchmarkSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Benchmark Source'**
  String get addBenchmarkSourceTitle;

  /// No description provided for @editBenchmarkSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Benchmark Source'**
  String get editBenchmarkSourceTitle;

  /// No description provided for @showBenchmarkSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Show Benchmark Source'**
  String get showBenchmarkSourceTitle;

  /// No description provided for @textLabelSourceFileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get textLabelSourceFileName;

  /// No description provided for @textHintSourceFileName.
  ///
  /// In en, this message translates to:
  /// **'eg. Top 10 Records'**
  String get textHintSourceFileName;

  /// No description provided for @textLabelSourceFileContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get textLabelSourceFileContent;

  /// No description provided for @textHintSourceFileContent.
  ///
  /// In en, this message translates to:
  /// **'e.g.:\nwww.example.com A\nexample.com CNAME'**
  String get textHintSourceFileContent;

  /// No description provided for @buttonAddSourceFile.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAddSourceFile;

  /// No description provided for @buttonEditSourceFile.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEditSourceFile;

  /// No description provided for @buttonUpdateSourceFile.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get buttonUpdateSourceFile;

  /// No description provided for @buttonDeleteSourceFile.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDeleteSourceFile;

  /// No description provided for @mdnsTitle.
  ///
  /// In en, this message translates to:
  /// **'multicast DNS'**
  String get mdnsTitle;

  /// No description provided for @mdnsTitleSecondary.
  ///
  /// In en, this message translates to:
  /// **'mDNS Result'**
  String get mdnsTitleSecondary;

  /// No description provided for @mdnsTabTitleQuery.
  ///
  /// In en, this message translates to:
  /// **'Query'**
  String get mdnsTabTitleQuery;

  /// No description provided for @mdnsTabTitleListen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get mdnsTabTitleListen;

  /// No description provided for @mdnsQueryForm.
  ///
  /// In en, this message translates to:
  /// **'Query Form'**
  String get mdnsQueryForm;

  /// No description provided for @mdnsListenForm.
  ///
  /// In en, this message translates to:
  /// **'Listen MDNS Message'**
  String get mdnsListenForm;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @invalidAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid Address'**
  String get invalidAddress;

  /// No description provided for @invalidPort.
  ///
  /// In en, this message translates to:
  /// **'Invalid Port'**
  String get invalidPort;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @smenuYellowDog.
  ///
  /// In en, this message translates to:
  /// **'YellowDog'**
  String get smenuYellowDog;

  /// No description provided for @smenuSmenuYellowDog.
  ///
  /// In en, this message translates to:
  /// **'About YellowDog'**
  String get smenuSmenuYellowDog;

  /// No description provided for @titleAboutYellowDog.
  ///
  /// In en, this message translates to:
  /// **'About YellowDog'**
  String get titleAboutYellowDog;

  /// No description provided for @aboutYellowDog.
  ///
  /// In en, this message translates to:
  /// **'In memory of YellowDog, 1988 - 1990'**
  String get aboutYellowDog;

  /// No description provided for @aboutYellowDog2.
  ///
  /// In en, this message translates to:
  /// **'Your are a Strong, Clever and Loyal Dog'**
  String get aboutYellowDog2;

  /// No description provided for @deviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Device Info'**
  String get deviceInfo;

  /// No description provided for @wifiInfo.
  ///
  /// In en, this message translates to:
  /// **'Wifi Info'**
  String get wifiInfo;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'cs',
        'de',
        'en',
        'es',
        'fr',
        'it',
        'ja',
        'ko',
        'ru',
        'uk',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'uk':
      return AppLocalizationsUk();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
