import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/route/screen_export.dart';
import 'package:tklab_ec_v2/screens/product/views/product_list_screen.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  // 移除 BookmarkScreen，改為 4 個頁面
  final List _pages = const [
    ProductListScreen(),
    DiscoverScreen(),
    CartScreen(),
    ProfileScreen(),
  ];
  int _currentIndex = 0;

  void _openCustomerService() {
    Navigator.pushNamed(
      context,
      webViewScreenRoute,
      arguments: {
        'url': '/customer-service',
        'title': '客服中心',
        'showRefreshButton': false,
        'actions': <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                '服務時間\n平日09:30 ~ 20:30\n假日13:00 ~ 17:00',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // pinned: true,
        // floating: true,
        // snap: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SizedBox(),
        leadingWidth: 0,
        centerTitle: false,
        title: Image.asset(
          "assets/logo/tklab_logo.png",
          height: 32,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, searchScreenRoute);
            },
            icon: SvgPicture.asset(
              "assets/icons/Search.svg",
              height: 24,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).textTheme.bodyLarge!.color!,
                  BlendMode.srcIn),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, notificationsScreenRoute);
            },
            icon: SvgPicture.asset(
              "assets/icons/Notification.svg",
              height: 24,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).textTheme.bodyLarge!.color!,
                  BlendMode.srcIn),
            ),
          ),
        ],
      ),
      // body: _pages[_currentIndex],
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, animation, secondAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: _openCustomerService,
          backgroundColor: primaryColor,
          elevation: 4,
          shape: const CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/icons/Chat.svg",
                height: 20,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(height: 2),
              const Text(
                '客服',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        height: 60,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF101015),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 左邊兩個按鈕
            _buildNavItem(0, "assets/icons/Stores.svg", "首頁"),
            _buildNavItem(1, "assets/icons/Category.svg", "分類"),
            // 中間空間給 FAB
            const SizedBox(width: 56),
            // 右邊兩個按鈕
            _buildNavItem(2, "assets/icons/Bag.svg", "購物車"),
            _buildNavItem(3, "assets/icons/Profile.svg", "我的"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? primaryColor : Colors.grey;

    return InkWell(
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
