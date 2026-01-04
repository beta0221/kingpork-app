import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/models/coupon_models.dart';
import '/viewmodels/order_confirmation_view_model.dart';

/// 顯示現金券選擇底部彈窗
Future<void> showVoucherSelectionBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const VoucherSelectionBottomSheet(),
  );
}

class VoucherSelectionBottomSheet extends StatefulWidget {
  const VoucherSelectionBottomSheet({super.key});

  @override
  State<VoucherSelectionBottomSheet> createState() =>
      _VoucherSelectionBottomSheetState();
}

class _VoucherSelectionBottomSheetState
    extends State<VoucherSelectionBottomSheet> {
  final TextEditingController _codeController = TextEditingController();
  bool _isClaimingCode = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _claimCouponByCode() async {
    if (!mounted) return;

    final viewModel = context.read<OrderConfirmationViewModel>();

    setState(() => _isClaimingCode = true);

    final success = await viewModel.claimCouponByCode(_codeController.text);

    if (!mounted) return;

    setState(() => _isClaimingCode = false);

    if (success) {
      // 領取成功，關閉彈窗
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('現金券領取成功並已套用')),
      );
    } else {
      // 顯示錯誤訊息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? '領取失敗')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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
                        '選擇現金券',
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

                // 序號輸入區塊
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '輸入現金券序號',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _codeController,
                              decoration: InputDecoration(
                                hintText: '請輸入序號',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              enabled: !_isClaimingCode,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isClaimingCode ? null : _claimCouponByCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: whiteColor,
                              minimumSize: const Size(80, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                            ),
                            child: _isClaimingCode
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        whiteColor,
                                      ),
                                    ),
                                  )
                                : const Text('領取'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 32),

                // 可用現金券列表標題
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Row(
                    children: [
                      const Text(
                        '可用現金券',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${viewModel.availableCoupons.length})',
                        style: TextStyle(
                          fontSize: 14,
                          color: blackColor60,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 現金券列表
                Expanded(
                  child: viewModel.isCouponsLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        )
                      : viewModel.availableCoupons.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_offer_outlined,
                                    size: 64,
                                    color: blackColor20,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '暫無可用現金券',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: blackColor60,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding,
                              ),
                              itemCount: viewModel.availableCoupons.length + 1,
                              itemBuilder: (context, index) {
                                // 第一項：不使用現金券選項
                                if (index == 0) {
                                  return _CouponListTile(
                                    isSelected: viewModel.selectedCoupon == null,
                                    onTap: () {
                                      viewModel.selectCoupon(null);
                                      Navigator.pop(context);
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: blackColor5,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.block,
                                            color: blackColor60,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            '不使用現金券',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                final coupon = viewModel.availableCoupons[index - 1];
                                return _CouponListTile(
                                  isSelected: viewModel.selectedCoupon?.redemptionId ==
                                      coupon.redemptionId,
                                  onTap: () {
                                    viewModel.selectCoupon(coupon);
                                    Navigator.pop(context);
                                  },
                                  child: _CouponCard(coupon: coupon),
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

/// 現金券列表項目
class _CouponListTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const _CouponListTile({
    required this.isSelected,
    required this.onTap,
    required this.child,
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(child: child),
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

/// 現金券卡片
class _CouponCard extends StatelessWidget {
  final MyCoupon coupon;

  const _CouponCard({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左側面額區塊
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                coupon.displayValue,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              if (coupon.type == CouponType.discount)
                Text(
                  '折扣',
                  style: TextStyle(
                    fontSize: 10,
                    color: blackColor60,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // 右側資訊
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coupon.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (coupon.conditionType == CouponConditionType.threshold &&
                  coupon.conditionThreshold != null)
                Text(
                  '滿 \$${coupon.conditionThreshold} 可用',
                  style: TextStyle(
                    fontSize: 12,
                    color: blackColor60,
                  ),
                ),
              Text(
                '有效期至 ${_formatDate(coupon.activityEndsAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: blackColor60,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
