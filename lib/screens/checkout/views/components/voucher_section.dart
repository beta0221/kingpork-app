import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/viewmodels/order_confirmation_view_model.dart';

class VoucherSection extends StatelessWidget {
  const VoucherSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderConfirmationViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題
            const Text(
              '現金券',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: defaultPadding),

            // 內容區塊
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                border: Border.all(color: blackColor10),
                borderRadius: BorderRadius.circular(defaultBorderRadious),
              ),
              child: Row(
                children: [
                  // 左側圖示 (可選)
                  if (viewModel.voucherCode != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_offer,
                        color: successColor,
                        size: 20,
                      ),
                    ),
                  if (viewModel.voucherCode != null) const SizedBox(width: 12),

                  // 左側資訊
                  Expanded(
                    child: viewModel.voucherCode != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                viewModel.voucherCode!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '折扣 NT\$${viewModel.voucherDiscount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: successColor,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  // 右側按鈕/文字
                  GestureDetector(
                    onTap: () {
                      // 前往現金券選擇或輸入頁面
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('前往現金券選擇頁面')),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          viewModel.voucherCode != null ? '變更' : '選擇現金券或輸入折扣碼',
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          color: primaryColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
