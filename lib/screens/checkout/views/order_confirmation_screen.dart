import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/viewmodels/order_confirmation_view_model.dart';
import '/viewmodels/base_view_model.dart';
import 'components/recipient_info_section.dart';
import 'components/delivery_method_section.dart';
import 'components/payment_method_section.dart';
import 'components/invoice_type_section.dart';
import 'components/voucher_section.dart';
import 'components/order_confirmation_bottom_bar.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化 ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderConfirmationViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('訂單確認'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // 重新整理頁面
              context.read<OrderConfirmationViewModel>().initialize();
            },
          ),
        ],
      ),
      body: Consumer<OrderConfirmationViewModel>(
        builder: (context, viewModel, child) {
          // 載入中狀態
          if (viewModel.isLoading && viewModel.state == ViewState.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          // 錯誤狀態
          if (viewModel.isError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage ?? '載入失敗',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: blackColor60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.initialize();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: whiteColor,
                      ),
                      child: const Text('重試'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 主要內容
          return SingleChildScrollView(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 收件人資料區塊
                const RecipientInfoSection(),
                const SizedBox(height: 24),

                // 送貨方式區塊
                const DeliveryMethodSection(),
                const SizedBox(height: 24),

                // 付款方式區塊
                const PaymentMethodSection(),
                const SizedBox(height: 24),

                // 發票類型區塊
                const InvoiceTypeSection(),
                const SizedBox(height: 24),

                // 現金券區塊
                const VoucherSection(),
                const SizedBox(height: 100), // 底部空間，避免被 bottom bar 遮擋
              ],
            ),
          );
        },
      ),
      // 底部操作列
      bottomNavigationBar: const OrderConfirmationBottomBar(),
    );
  }
}
