import 'package:flutter_test/flutter_test.dart';
import 'package:tklab_ec_v2/config/flavor_config.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';

void main() {
  group('ApiEndpoints Tests', () {
    test('API endpoints use correct base URL for DEV', () {
      FlavorConfig.initialize(flavor: Flavor.dev);

      expect(ApiEndpoints.baseUrl, 'https://rd.tklab.com.tw');
      expect(ApiEndpoints.apiBaseUrl, 'https://rd.tklab.com.tw/api/next');
    });

    test('API endpoints use correct base URL for UAT', () {
      FlavorConfig.initialize(flavor: Flavor.uat);

      expect(ApiEndpoints.baseUrl, 'https://test.tklab.com.tw');
      expect(ApiEndpoints.apiBaseUrl, 'https://test.tklab.com.tw/api/next');
    });

    test('API endpoints use correct base URL for PROD', () {
      FlavorConfig.initialize(flavor: Flavor.prod);

      expect(ApiEndpoints.baseUrl, 'https://www.tklab.com.tw');
      expect(ApiEndpoints.apiBaseUrl, 'https://www.tklab.com.tw/api/next');
    });

    test('buildUrl constructs correct full URLs', () {
      FlavorConfig.initialize(flavor: Flavor.dev);

      final loginUrl = ApiEndpoints.buildUrl(ApiEndpoints.login);
      expect(loginUrl, 'https://rd.tklab.com.tw/api/next/auth/login');

      final categoriesUrl = ApiEndpoints.buildUrl(ApiEndpoints.categories);
      expect(categoriesUrl, 'https://rd.tklab.com.tw/api/next/landing/categories');
    });

    test('dynamic endpoint builders work correctly', () {
      FlavorConfig.initialize(flavor: Flavor.prod);

      final categoryUrl = ApiEndpoints.shopCategory('electronics');
      expect(categoryUrl, '/shop/electronics');

      final removeUrl = ApiEndpoints.kartRemove(123);
      expect(removeUrl, '/kart/remove/123');

      final billDetailUrl = ApiEndpoints.billDetail(456);
      expect(billDetailUrl, '/bill/detail/456');
    });
  });
}
