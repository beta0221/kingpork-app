import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/viewmodels/order_confirmation_view_model.dart';

class InvoiceTypeSection extends StatelessWidget {
  const InvoiceTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderConfirmationViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題
            const Text(
              '發票類型',
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
                  // 左側資訊
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewModel.invoiceType,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          viewModel.invoiceCarrierType,
                          style: TextStyle(
                            fontSize: 13,
                            color: blackColor60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 右側「變更」按鈕
                  GestureDetector(
                    onTap: () {
                      // 顯示發票類型選擇 modal
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('顯示發票類型選擇')),
                      );
                    },
                    child: Row(
                      children: [
                        const Text(
                          '變更',
                          style: TextStyle(
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
