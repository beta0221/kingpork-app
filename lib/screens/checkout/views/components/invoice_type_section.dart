import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/models/checkout_options.dart';
import '/viewmodels/order_confirmation_view_model.dart';
import 'invoice_type_selection_bottom_sheet.dart';

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
                        // 根據發票類型顯示額外資訊
                        if (viewModel.selectedInvoiceType == InvoiceType.cloud)
                          Text(
                            viewModel.invoiceCarrierType,
                            style: TextStyle(
                              fontSize: 13,
                              color: blackColor60,
                            ),
                          )
                        else if (viewModel.selectedInvoiceType == InvoiceType.donation &&
                                 viewModel.invoiceDonationCode != null)
                          Text(
                            '捐贈碼：${viewModel.invoiceDonationCode}',
                            style: TextStyle(
                              fontSize: 13,
                              color: blackColor60,
                            ),
                          )
                        else if (viewModel.selectedInvoiceType == InvoiceType.triplicate)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (viewModel.invoiceCompanyId != null)
                                Text(
                                  '統編：${viewModel.invoiceCompanyId}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: blackColor60,
                                  ),
                                ),
                              if (viewModel.invoiceCompanyTitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  viewModel.invoiceCompanyTitle!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: blackColor60,
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 右側「變更」按鈕
                  GestureDetector(
                    onTap: () {
                      // 顯示發票類型選擇底部彈窗
                      showInvoiceTypeSelectionBottomSheet(context);
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
