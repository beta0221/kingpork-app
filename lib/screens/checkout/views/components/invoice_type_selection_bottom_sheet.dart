import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/models/checkout_options.dart';
import '/viewmodels/order_confirmation_view_model.dart';

/// 顯示發票類型選擇底部彈窗
Future<void> showInvoiceTypeSelectionBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const InvoiceTypeSelectionBottomSheet(),
  );
}

class InvoiceTypeSelectionBottomSheet extends StatefulWidget {
  const InvoiceTypeSelectionBottomSheet({super.key});

  @override
  State<InvoiceTypeSelectionBottomSheet> createState() =>
      _InvoiceTypeSelectionBottomSheetState();
}

class _InvoiceTypeSelectionBottomSheetState
    extends State<InvoiceTypeSelectionBottomSheet> {
  late InvoiceType _selectedType;
  final TextEditingController _donationCodeController = TextEditingController();
  final TextEditingController _companyIdController = TextEditingController();
  final TextEditingController _companyTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<OrderConfirmationViewModel>();
    _selectedType = viewModel.selectedInvoiceType;

    // 載入已存在的數據
    if (viewModel.invoiceDonationCode != null) {
      _donationCodeController.text = viewModel.invoiceDonationCode!;
    }
    if (viewModel.invoiceCompanyId != null) {
      _companyIdController.text = viewModel.invoiceCompanyId!;
    }
    if (viewModel.invoiceCompanyTitle != null) {
      _companyTitleController.text = viewModel.invoiceCompanyTitle!;
    }
  }

  @override
  void dispose() {
    _donationCodeController.dispose();
    _companyIdController.dispose();
    _companyTitleController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (!mounted) return;

    // 驗證輸入
    if (_selectedType == InvoiceType.donation) {
      final code = _donationCodeController.text.trim();
      if (code.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('請輸入捐贈碼')),
        );
        return;
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(code)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('捐贈碼必須為純數字')),
        );
        return;
      }
    } else if (_selectedType == InvoiceType.triplicate) {
      final companyId = _companyIdController.text.trim();
      final companyTitle = _companyTitleController.text.trim();

      if (companyId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('請輸入統一編號')),
        );
        return;
      }
      if (!RegExp(r'^[0-9]{8}$').hasMatch(companyId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('統一編號必須為8位數字')),
        );
        return;
      }
      if (companyTitle.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('請輸入公司抬頭')),
        );
        return;
      }
      if (companyTitle.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('公司抬頭至少需要2個字元')),
        );
        return;
      }
    }

    // 更新 ViewModel
    final viewModel = context.read<OrderConfirmationViewModel>();
    viewModel.updateInvoiceTypeEnum(
      _selectedType,
      donationCode: _selectedType == InvoiceType.donation
          ? _donationCodeController.text.trim()
          : null,
      companyId: _selectedType == InvoiceType.triplicate
          ? _companyIdController.text.trim()
          : null,
      companyTitle: _selectedType == InvoiceType.triplicate
          ? _companyTitleController.text.trim()
          : null,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 標題列
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Row(
                children: [
                  const Text(
                    '選擇發票類型',
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

            // 內容區域
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(defaultPadding),
                children: [
                  // 發票類型選項列表
                  ...InvoiceType.values.map((type) {
                    return _OptionListTile(
                      icon: type.displayIcon,
                      text: type.displayText,
                      isSelected: _selectedType == type,
                      onTap: () {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                    );
                  }),

                  const SizedBox(height: 16),

                  // 條件式輸入欄位
                  if (_selectedType == InvoiceType.donation) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      '捐贈碼',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _donationCodeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: '請輸入捐贈碼（例：123456）',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ] else if (_selectedType == InvoiceType.triplicate) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      '統一編號',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _companyIdController,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: '請輸入8位數統一編號',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '公司抬頭',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _companyTitleController,
                      decoration: InputDecoration(
                        hintText: '請輸入公司抬頭',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 底部確認按鈕
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: blackColor.withValues(alpha: 0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: whiteColor,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    '確認',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
