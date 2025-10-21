import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tklab_ec_v2/route/route_constants.dart';
import 'package:tklab_ec_v2/route/router.dart' as router;
import 'package:tklab_ec_v2/theme/app_theme.dart';
import 'package:tklab_ec_v2/config/flavor_config.dart';
import 'package:tklab_ec_v2/viewmodels/home_view_model.dart';
import 'package:tklab_ec_v2/viewmodels/member_view_model.dart';

/// 預設入口點（用於開發時快速測試）
/// 正式使用時應該使用 main_dev.dart, main_uat.dart, main_prod.dart
void main() {
  // 預設使用開發環境
  if (!FlavorConfig.isInitialized) {
    FlavorConfig.initialize(flavor: Flavor.dev);
  }
  runMainApp();
}

/// 主應用程式啟動函式
/// 由各個 Flavor 入口點呼叫
void runMainApp() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => MemberViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 取得當前環境配置
    final flavorConfig = FlavorConfig.instance;

    return MaterialApp(
      title: 'TKLab EC V2 - ${flavorConfig.name}',

      // Debug Banner（只在 dev/uat 環境顯示）
      debugShowCheckedModeBanner: !flavorConfig.isProd,

      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.system,
      onGenerateRoute: router.generateRoute,
      initialRoute: entryPointScreenRoute,

      // 在非正式環境顯示環境標識
      builder: (context, child) {
        if (flavorConfig.isProd) {
          return child!;
        }

        // 開發/測試環境顯示環境標識
        return Banner(
          message: flavorConfig.displayName,
          location: BannerLocation.topEnd,
          color: _getBannerColor(flavorConfig.flavor),
          child: child!,
        );
      },
    );
  }

  Color _getBannerColor(Flavor flavor) {
    switch (flavor) {
      case Flavor.dev:
        return Colors.red;
      case Flavor.uat:
        return Colors.orange;
      case Flavor.prod:
        return Colors.green;
    }
  }
}
