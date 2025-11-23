import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tklab_ec_v2/components/webview/tk_webview.dart';
import 'package:tklab_ec_v2/services/api/api_endpoints.dart';

import '../../../constants.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              // TabBar Header
              SliverAppBar(
                pinned: false,
                toolbarHeight: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        isScrollable: false,
                        // tabAlignment: TabAlignment.start,
                        labelColor: Theme.of(context).brightness == Brightness.light
                            ? blackColor
                            : whiteColor,
                        unselectedLabelColor: blackColor40,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        indicatorColor: errorColor,
                        indicatorWeight: 2,
                        tabs: const [
                          // Tab(text: "首頁"),
                          Tab(text: "優惠"),
                          Tab(text: "保養"),
                          Tab(text: "保健"),
                          Tab(text: "彩妝"),
                          Tab(text: "面膜"),
                          // Tab(text: "限時優惠"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTestWebViewContent(),
              _buildTestWebViewContent(),
              _buildTestWebViewContent(),
              _buildTestWebViewContent(),
              _buildTestWebViewContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestWebViewContent() {
    return FutureBuilder<String>(
      future: rootBundle.loadString('assets/html/example_webview.html'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '載入 HTML 時發生錯誤: ${snapshot.error}',
              style: const TextStyle(color: errorColor),
            ),
          );
        }

        final htmlContent = snapshot.data ?? '';

        return TkWebView(
          htmlContent: htmlContent,
          htmlBaseUrl: ApiEndpoints.baseUrl,
          showLoading: true,
          loadingMessage: '載入中...',
          enableJavaScript: true,
        );
      },
    );
  }
}
