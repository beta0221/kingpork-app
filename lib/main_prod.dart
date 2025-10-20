import 'config/flavor_config.dart';
import 'main.dart';

/// 正式環境入口點
void main() {
  // 初始化正式環境配置
  FlavorConfig.initialize(flavor: Flavor.prod);

  // 啟動應用程式
  runMainApp();
}
