import 'package:flutter/material.dart';
import '../../../../constants.dart';

/// 購物車頁面功能特色區塊
/// 顯示會員優惠、送貨、退貨、付款方式等資訊
class CartFeaturesSection extends StatelessWidget {
  const CartFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      child: Column(
        children: [
          // 會員TK幣及生日禮
          _FeatureItem(
            icon: Icons.card_giftcard_outlined,
            title: '會員TK幣及生日禮',
            description: '當年度累積消費達門檻可獲得升級禮（TK幣/現金券/實體商品兌換券）\n金卡會員（含）以上，生日當月1日再送專屬生日TK幣。',
          ),
          const SizedBox(height: defaultPadding),

          // 快速送貨
          _FeatureItem(
            icon: Icons.local_shipping_outlined,
            title: '快速送貨',
            description: '訂單成立且付款，1-4個工作天(不含假日)出貨。',
          ),
          const SizedBox(height: defaultPadding),

          // 免費退貨
          _FeatureItem(
            icon: Icons.replay_outlined,
            title: '免費退貨',
            description: '7日無條件退貨服務。',
          ),
          const SizedBox(height: defaultPadding),

          // 安全結帳
          _FeatureItem(
            icon: Icons.account_balance_wallet_outlined,
            title: '安全結帳',
            description: '安全無虞的結帳功能，簡單快速。',
            paymentIcons: true,
          ),
        ],
      ),
    );
  }
}

/// 單一功能項目元件
class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    this.paymentIcons = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool paymentIcons;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 圖示
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).iconTheme.color,
        ),
        const SizedBox(width: defaultPadding / 2),

        // 內容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: blackColor60,
                      height: 1.4,
                    ),
              ),

              // 付款方式圖示（僅安全結帳顯示）
              if (paymentIcons) ...[
                const SizedBox(height: defaultPadding / 2),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PaymentIcon(text: 'Apple Pay'),
                    _PaymentIcon(text: 'VISA'),
                    _PaymentIcon(text: 'Mastercard'),
                    _PaymentIcon(text: 'JCB'),
                    _PaymentIcon(text: 'UnionPay'),
                    _PaymentIcon(text: 'ATM'),
                    _PaymentIcon(text: '貨到付款'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 付款方式圖示元件
class _PaymentIcon extends StatelessWidget {
  const _PaymentIcon({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
