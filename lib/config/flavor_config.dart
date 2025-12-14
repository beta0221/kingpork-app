/// Flutter Flavors 配置
/// 用於管理 dev/uat/prod 三個環境的配置
enum Flavor {
  dev,
  uat,
  prod,
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final String baseUrl;
  final String oneSignalAppId;
  final String wssUrl;
  final String firebaseAppLink;
  final String matomoUrl;
  final int matomoSiteId;

  static FlavorConfig? _instance;

  FlavorConfig._({
    required this.flavor,
    required this.name,
    required this.baseUrl,
    required this.oneSignalAppId,
    required this.wssUrl,
    required this.firebaseAppLink,
    required this.matomoUrl,
    required this.matomoSiteId,
  });

  /// 取得當前 Flavor 配置實例
  static FlavorConfig get instance {
    if (_instance == null) {
      throw Exception('FlavorConfig 尚未初始化，請先呼叫 FlavorConfig.initialize()');
    }
    return _instance!;
  }

  /// 檢查是否已初始化
  static bool get isInitialized => _instance != null;

  /// 初始化 Flavor 配置
  static void initialize({required Flavor flavor}) {
    switch (flavor) {
      case Flavor.dev:
        _instance = FlavorConfig._(
          flavor: Flavor.dev,
          name: 'DEV',
          baseUrl: 'https://www.stage.daf-shoes.com:8081',
          oneSignalAppId: '2780fb32-fc29-41be-9c0b-b43131b71b65', // DEV OneSignal App ID
          wssUrl: 'wss://www.stage.daf-shoes.com:8081/wss',
          firebaseAppLink: 'https://tklab.page.link',
          matomoUrl: 'https://www.stage.daf-shoes.com:8081/matomo/matomo.php',
          matomoSiteId: 1,
        );
        break;

      case Flavor.uat:
        _instance = FlavorConfig._(
          flavor: Flavor.uat,
          name: 'UAT',
          baseUrl: 'https://test.tklab.com.tw',
          oneSignalAppId: '3685eb59-ed9a-45a2-8979-b9122a9f0e92', // UAT OneSignal App ID
          wssUrl: 'wss://test.tklab.com.tw/wss',
          firebaseAppLink: 'https://tktest.page.link',
          matomoUrl: '', // UAT 環境無 Matomo
          matomoSiteId: 1,
        );
        break;

      case Flavor.prod:
        _instance = FlavorConfig._(
          flavor: Flavor.prod,
          name: 'PROD',
          baseUrl: 'https://www.tklab.com.tw',
          oneSignalAppId: '94fe3582-4d7e-40e6-8b03-127de7cacff7', // PROD OneSignal App ID
          wssUrl: 'wss://www.tklab.com.tw/wss',
          firebaseAppLink: 'https://tkapp.page.link',
          matomoUrl: 'https://ga.tklab.com.tw/matomo.php',
          matomoSiteId: 1,
        );
        break;
    }
  }

  /// 判斷是否為開發環境
  bool get isDev => flavor == Flavor.dev;

  /// 判斷是否為測試環境
  bool get isUat => flavor == Flavor.uat;

  /// 判斷是否為正式環境
  bool get isProd => flavor == Flavor.prod;

  /// 取得環境顯示名稱（含 emoji）
  String get displayName {
    switch (flavor) {
      case Flavor.dev:
        return '🔧 開發環境';
      case Flavor.uat:
        return '🧪 測試環境';
      case Flavor.prod:
        return '🚀 正式環境';
    }
  }

  /// 取得 API 服務 URL
  String get apiUrl => '$baseUrl/api';

  /// 取得 APP API 服務 URL（相容舊版 API）
  String get appApiUrl => '$baseUrl/api';

  @override
  String toString() {
    return 'FlavorConfig(name: $name, baseUrl: $baseUrl)';
  }
}
