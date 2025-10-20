import 'config/flavor_config.dart';
import 'main.dart';

/// UAT 測試環境入口點
void main() {
  // 初始化 UAT 環境配置
  FlavorConfig.initialize(flavor: Flavor.uat);

  // 啟動應用程式
  runMainApp();
}
