import 'config/flavor_config.dart';
import 'main.dart';

/// 開發環境入口點
void main() {
  // 初始化開發環境配置
  FlavorConfig.initialize(flavor: Flavor.dev);

  // 啟動應用程式
  runMainApp();
}
