import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/models/checkout_options.dart';
import '/viewmodels/order_confirmation_view_model.dart';

/// 顯示付款方式選擇底部彈窗
Future<void> showPaymentMethodSelectionBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const PaymentMethodSelectionBottomSheet(),
  );
}

class PaymentMethodSelectionBottomSheet extends StatelessWidget {
  const PaymentMethodSelectionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Consumer<OrderConfirmationViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // 標題列
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Row(
                    children: [
                      const Text(
                        '選擇付款方式',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // 選項列表
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(defaultPadding),
                    itemCount: PaymentMethod.values.length,
                    itemBuilder: (context, index) {
                      final method = PaymentMethod.values[index];
                      return _OptionListTile(
                        icon: method.displayIcon,
                        text: method.displayText,
                        isSelected: viewModel.selectedPaymentMethod == method,
                        onTap: () {
                          viewModel.updatePaymentMethodEnum(method);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// 選項列表項目
class _OptionListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionListTile({
    required this.icon,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? primaryColor : blackColor10,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? primaryColor.withValues(alpha: 0.05) : Colors.transparent,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 圖示
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.1)
                      : blackColor5,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? primaryColor : blackColor60,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // 文字
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // 選中圖示
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: primaryColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
