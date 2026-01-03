import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '/components/webview/tk_webview.dart';
import '/viewmodels/product_list_view_model.dart';
import '/constants.dart';
import 'components/product_line_tab_bar.dart';

/// 产品线屏幕
/// 包含上方的水平滚动标签栏和下方的 WebView
class ProductLineScreen extends StatefulWidget {
  const ProductLineScreen({super.key});

  @override
  State<ProductLineScreen> createState() => _ProductLineScreenState();
}

class _ProductLineScreenState extends State<ProductLineScreen> {
  /// 当前选中的产品线索引
  int _selectedProductLineIndex = 0;

  /// WebView 控制器，用于重新加载 URL
  WebViewController? _webViewController;

  /// 标签栏滚动控制器
  late ScrollController _tabScrollController;

  @override
  void initState() {
    super.initState();
    _tabScrollController = ScrollController();

    // 初始化 ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductListViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    super.dispose();
  }

  /// 处理产品线选择
  void _onProductLineSelected(int index) {
    if (_selectedProductLineIndex == index) return; // 避免重复点击

    final viewModel = context.read<ProductListViewModel>();
    if (viewModel.productLines.isEmpty) return;

    setState(() {
      _selectedProductLineIndex = index;
    });

    // 使用 controller 重新加载新 URL（更高效，不需要重新创建 widget）
    final newUrl = viewModel.productLines[index].devUrl();
    _webViewController?.loadRequest(Uri.parse(newUrl));
  }

  /// 构建加载状态 UI
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// 构建错误状态 UI
  Widget _buildErrorState(ProductListViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            viewModel.errorMessage ?? '加载失败',
            style: const TextStyle(
              color: errorColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: viewModel.refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: whiteColor,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建空数据状态 UI
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        '暂无产品线数据',
        style: TextStyle(
          color: blackColor40,
          fontSize: 16,
        ),
      ),
    );
  }

  /// 构建成功状态 UI（标签栏 + WebView）
  Widget _buildSuccessState(ProductListViewModel viewModel) {
    if (viewModel.productLines.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // 产品线标签栏
        ProductLineTabBar(
          productLines: viewModel.productLines,
          selectedIndex: _selectedProductLineIndex,
          onTabSelected: _onProductLineSelected,
          scrollController: _tabScrollController,
        ),
        // WebView 内容区域
        Expanded(
          child: TkWebView(
            url: viewModel.productLines[_selectedProductLineIndex].devUrl(),
            showLoading: true,
            loadingMessage: '载入中...',
            enableJavaScript: true,
            onControllerCreated: (controller) {
              _webViewController = controller;
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ProductListViewModel>(
          builder: (context, viewModel, child) {
            // 加载状态
            if (viewModel.isLoading) {
              return _buildLoadingState();
            }

            // 错误状态
            if (viewModel.isError) {
              return _buildErrorState(viewModel);
            }

            // 成功状态
            return _buildSuccessState(viewModel);
          },
        ),
      ),
    );
  }
}
