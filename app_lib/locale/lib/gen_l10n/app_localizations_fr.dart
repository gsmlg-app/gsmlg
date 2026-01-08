// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Modèle d\'application Flutter';

  @override
  String get errorOccurred => 'Une erreur s\'est produite';

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get welcomeHome => 'Bienvenue dans mon application';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get loading => 'Chargement';

  @override
  String get success => 'Succès';

  @override
  String get error => 'Erreur';

  @override
  String get undo => 'Annuler';

  @override
  String get navHome => 'Accueil';

  @override
  String get navService => 'Service';

  @override
  String get navToolbox => 'Toolbox';

  @override
  String get navShowcase => 'Vitrine';

  @override
  String get navSetting => 'Paramètres';

  @override
  String get settingsTitle => 'Paramètres YellowDog';

  @override
  String get smenuTheme => 'Thème';

  @override
  String get appearance => 'Apparence';

  @override
  String get accentColor => 'Couleur d\'accentuation';

  @override
  String get language => 'Langue';

  @override
  String get retry => 'Réessayer';

  @override
  String get lightTheme => 'Clair';

  @override
  String get darkTheme => 'Sombre';

  @override
  String get systemTheme => 'Système';

  @override
  String get nslookupTitle => 'Recherche NS YellowDog';

  @override
  String get bmenuNSLookup => 'Recherche NS';

  @override
  String get bmenuBenchmark => 'Benchmark';

  @override
  String get bmenuDns => 'Serveur';

  @override
  String get bmenuMDns => 'mDNS';

  @override
  String get bmenuSettings => 'Paramètres';

  @override
  String get textLabelRRName => 'Nom';

  @override
  String get textHintRRName => 'Nom d\'enregistrement de ressource DNS';

  @override
  String get textLabelRRType => 'Type';

  @override
  String get textHintRRType => 'Type d\'enregistrement de ressource DNS';

  @override
  String get textLabelRRClass => 'Classe';

  @override
  String get textHintRRClass => 'Classe DNS';

  @override
  String get textLabelRRData => 'Données';

  @override
  String get textLabelRRTimeToLive => 'TTL';

  @override
  String get textLabelProtocol => 'Protocole';

  @override
  String get textHintProtocol => 'Protocole de requête DNS';

  @override
  String get textLabelServer => 'Serveur de noms';

  @override
  String get textHintServer =>
      'Serveur DNS, par ex. 8.8.8.8#53 ou 2001:4860:4860::8888#53';

  @override
  String get textLabelECS => 'ECS';

  @override
  String get textHintECS => 'Sous-réseau client EDNS';

  @override
  String get textLabelDNSSEC => 'DNSSEC';

  @override
  String get buttonLookup => 'Rechercher';

  @override
  String get labelAnswer => 'Réponse';

  @override
  String get buttonClearResult => 'Effacer le résultat';

  @override
  String get benchmarkTitle => 'Benchmark YellowDog';

  @override
  String get textLabelSourceFile => 'Fichier source';

  @override
  String get buttonManageSourceFile => 'Gérer le fichier';

  @override
  String get textLabelConcurrencyClients => 'Clients simultanés';

  @override
  String get textHintConcurrencyClients => 'par ex. 10';

  @override
  String get textLabelNTimes => 'N fois';

  @override
  String get textHintNTimes => 'par ex. 10';

  @override
  String get buttonBenchmark => 'Lancer le benchmark';

  @override
  String get labelBenchmarkResult => 'Résultat du benchmark';

  @override
  String get labelError => 'Erreur';

  @override
  String get buttonAtRunning => 'En cours d\'exécution';

  @override
  String get nameServerTitle => 'Serveur de noms YellowDog';

  @override
  String get nameServerSecondaryTitle => 'Journal en temps réel';

  @override
  String get textLabelServerPort => 'Port du serveur';

  @override
  String get textHintServerPort => 'par ex. 53';

  @override
  String get textLabelForwarderAddress => 'Adresse du transitaire';

  @override
  String get textHintForwarderAddress => 'par ex. 8.8.8.8';

  @override
  String get textLabelForwarderPort => 'Port du transitaire';

  @override
  String get textHintForwarderPort => 'par ex. 53';

  @override
  String get buttonStartServer => 'Démarrer le serveur';

  @override
  String get buttonStopServer => 'Arrêter le serveur';

  @override
  String get smenuAppearance => 'Apparence';

  @override
  String get smenuColorTheme => 'Thème de couleur';

  @override
  String get smenuBenchmark => 'Benchmark';

  @override
  String get smenuSourceFile => 'Fichier source';

  @override
  String get titleSelectAppearance => 'Sélectionner l\'apparence';

  @override
  String get titleSelectColorTheme => 'Sélectionner le thème de couleur';

  @override
  String get benchmarkSourceTitle => 'Source du benchmark';

  @override
  String get smenuAddFile => 'Ajouter un fichier';

  @override
  String get labelLoading => 'Chargement';

  @override
  String get addBenchmarkSourceTitle => 'Ajouter une source de benchmark';

  @override
  String get editBenchmarkSourceTitle => 'Modifier la source de benchmark';

  @override
  String get showBenchmarkSourceTitle => 'Afficher la source de benchmark';

  @override
  String get textLabelSourceFileName => 'Nom';

  @override
  String get textHintSourceFileName => 'par ex. 10 enregistrements principaux';

  @override
  String get textLabelSourceFileContent => 'Contenu';

  @override
  String get textHintSourceFileContent =>
      'par ex.:\nwww.exemple.com A\nexemple.com CNAME';

  @override
  String get buttonAddSourceFile => 'Ajouter';

  @override
  String get buttonEditSourceFile => 'Modifier';

  @override
  String get buttonUpdateSourceFile => 'Mettre à jour';

  @override
  String get buttonDeleteSourceFile => 'Supprimer';

  @override
  String get mdnsTitle => 'DNS multidiffusion';

  @override
  String get mdnsTitleSecondary => 'Résultat mDNS';

  @override
  String get mdnsTabTitleQuery => 'Requête';

  @override
  String get mdnsTabTitleListen => 'Écouter';

  @override
  String get mdnsQueryForm => 'Formulaire de requête';

  @override
  String get mdnsListenForm => 'Écouter le message mDNS';

  @override
  String get required => 'Obligatoire';

  @override
  String get invalidAddress => 'Adresse invalide';

  @override
  String get invalidPort => 'Port invalide';

  @override
  String get start => 'Démarrer';

  @override
  String get stop => 'Arrêter';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Reprendre';

  @override
  String get clear => 'Effacer';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get smenuYellowDog => 'YellowDog';

  @override
  String get smenuSmenuYellowDog => 'À propos de YellowDog';

  @override
  String get titleAboutYellowDog => 'À propos de YellowDog';

  @override
  String get aboutYellowDog => 'À la mémoire de YellowDog, 1988 - 1990';

  @override
  String get aboutYellowDog2 => 'Vous êtes un chien fort, intelligent et loyal';

  @override
  String get deviceInfo => 'Device Info';

  @override
  String get wifiInfo => 'Wifi Info';

  @override
  String get account => 'Account';
}
