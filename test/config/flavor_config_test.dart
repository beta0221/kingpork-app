import 'package:flutter_test/flutter_test.dart';
import 'package:tklab_ec_v2/config/flavor_config.dart';

void main() {
  group('FlavorConfig Tests', () {
    test('DEV flavor configuration', () {
      FlavorConfig.initialize(flavor: Flavor.dev);
      final config = FlavorConfig.instance;

      expect(config.flavor, Flavor.dev);
      expect(config.name, 'DEV');
      expect(config.baseUrl, 'https://rd.tklab.com.tw');
      expect(config.apiUrl, 'https://rd.tklab.com.tw/api/next');
      expect(config.wssUrl, 'wss://rd.tklab.com.tw/wss');
      expect(config.isDev, true);
      expect(config.isUat, false);
      expect(config.isProd, false);
    });

    test('UAT flavor configuration', () {
      FlavorConfig.initialize(flavor: Flavor.uat);
      final config = FlavorConfig.instance;

      expect(config.flavor, Flavor.uat);
      expect(config.name, 'UAT');
      expect(config.baseUrl, 'https://test.tklab.com.tw');
      expect(config.apiUrl, 'https://test.tklab.com.tw/api/next');
      expect(config.wssUrl, 'wss://test.tklab.com.tw/wss');
      expect(config.isDev, false);
      expect(config.isUat, true);
      expect(config.isProd, false);
    });

    test('PROD flavor configuration', () {
      FlavorConfig.initialize(flavor: Flavor.prod);
      final config = FlavorConfig.instance;

      expect(config.flavor, Flavor.prod);
      expect(config.name, 'PROD');
      expect(config.baseUrl, 'https://www.tklab.com.tw');
      expect(config.apiUrl, 'https://www.tklab.com.tw/api/next');
      expect(config.wssUrl, 'wss://www.tklab.com.tw/wss');
      expect(config.isDev, false);
      expect(config.isUat, false);
      expect(config.isProd, true);
    });

    test('OneSignal App IDs are configured correctly', () {
      FlavorConfig.initialize(flavor: Flavor.dev);
      expect(FlavorConfig.instance.oneSignalAppId, '2780fb32-fc29-41be-9c0b-b43131b71b65');

      FlavorConfig.initialize(flavor: Flavor.uat);
      expect(FlavorConfig.instance.oneSignalAppId, '3685eb59-ed9a-45a2-8979-b9122a9f0e92');

      FlavorConfig.initialize(flavor: Flavor.prod);
      expect(FlavorConfig.instance.oneSignalAppId, '94fe3582-4d7e-40e6-8b03-127de7cacff7');
    });

    test('Firebase App Links are configured correctly', () {
      FlavorConfig.initialize(flavor: Flavor.dev);
      expect(FlavorConfig.instance.firebaseAppLink, 'https://tklab.page.link');

      FlavorConfig.initialize(flavor: Flavor.uat);
      expect(FlavorConfig.instance.firebaseAppLink, 'https://tktest.page.link');

      FlavorConfig.initialize(flavor: Flavor.prod);
      expect(FlavorConfig.instance.firebaseAppLink, 'https://tkapp.page.link');
    });

    test('Matomo URLs are configured correctly', () {
      FlavorConfig.initialize(flavor: Flavor.dev);
      expect(FlavorConfig.instance.matomoUrl, 'https://rd.tklab.com.tw/matomo/matomo.php');

      FlavorConfig.initialize(flavor: Flavor.uat);
      expect(FlavorConfig.instance.matomoUrl, ''); // UAT 沒有 Matomo

      FlavorConfig.initialize(flavor: Flavor.prod);
      expect(FlavorConfig.instance.matomoUrl, 'https://ga.tklab.com.tw/matomo.php');
    });
  });
}
