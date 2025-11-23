import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/viewmodels/order_confirmation_view_model.dart';

/// TK幣折抵區塊
class TkCoinSection extends StatefulWidget {
  const TkCoinSection({super.key});

  @override
  State<TkCoinSection> createState() => _TkCoinSectionState();
}

class _TkCoinSectionState extends State<TkCoinSection> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderConfirmationViewModel>(
      builder: (context, viewModel, child) {
        // 同步 controller 與 viewModel
        if (viewModel.useTkCoins && _controller.text != viewModel.usedTkCoins.toString()) {
          _controller.text = viewModel.usedTkCoins.toString();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題
            const Text(
              'TK幣折抵',
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
              child: Column(
                children: [
                  // 可用 TK幣 資訊
                  Row(
                    children: [
                      // TK幣圖示
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.monetization_on,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 可用餘額
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '可用 TK幣',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${viewModel.availableTkCoins} 點 (可折抵 NT\$${viewModel.availableTkCoins})',
                              style: TextStyle(
                                fontSize: 13,
                                color: blackColor60,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 使用開關
                      Switch(
                        value: viewModel.useTkCoins,
                        onChanged: viewModel.availableTkCoins > 0
                            ? (value) {
                                viewModel.toggleUseTkCoins(value);
                                if (value) {
                                  _controller.text = viewModel.usedTkCoins.toString();
                                } else {
                                  _controller.clear();
                                }
                              }
                            : null,
                        activeTrackColor: primaryColor.withValues(alpha: 0.5),
                        activeThumbColor: primaryColor,
                      ),
                    ],
                  ),

                  // 使用中顯示輸入區塊
                  if (viewModel.useTkCoins) ...[
                    const Divider(height: 24),

                    // 輸入數量區塊
                    Row(
                      children: [
                        const Text(
                          '使用數量',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),

                        // 減少按鈕
                        _buildAdjustButton(
                          icon: Icons.remove,
                          onPressed: viewModel.usedTkCoins > 0
                              ? () => viewModel.updateUsedTkCoins(viewModel.usedTkCoins - 10)
                              : null,
                        ),

                        // 輸入框
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: blackColor20),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: blackColor20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: primaryColor),
                              ),
                            ),
                            onChanged: (value) {
                              final coins = int.tryParse(value) ?? 0;
                              viewModel.updateUsedTkCoins(coins);
                            },
                            onSubmitted: (value) {
                              final coins = int.tryParse(value) ?? 0;
                              viewModel.updateUsedTkCoins(coins);
                              // 更新顯示值（因為可能被調整）
                              _controller.text = viewModel.usedTkCoins.toString();
                            },
                          ),
                        ),

                        // 增加按鈕
                        _buildAdjustButton(
                          icon: Icons.add,
                          onPressed: viewModel.usedTkCoins < viewModel.availableTkCoins
                              ? () => viewModel.updateUsedTkCoins(viewModel.usedTkCoins + 10)
                              : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 快速選擇按鈕
                    Row(
                      children: [
                        _buildQuickSelectButton(
                          label: '全部使用',
                          onPressed: () {
                            viewModel.updateUsedTkCoins(viewModel.availableTkCoins);
                            _controller.text = viewModel.usedTkCoins.toString();
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildQuickSelectButton(
                          label: '使用 100',
                          onPressed: viewModel.availableTkCoins >= 100
                              ? () {
                                  viewModel.updateUsedTkCoins(100);
                                  _controller.text = viewModel.usedTkCoins.toString();
                                }
                              : null,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickSelectButton(
                          label: '清除',
                          onPressed: () {
                            viewModel.updateUsedTkCoins(0);
                            _controller.text = '0';
                          },
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // 折抵金額
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '本次折抵',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '-NT\$${viewModel.usedTkCoins}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: viewModel.usedTkCoins > 0 ? successColor : blackColor60,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // 提示文字
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '1 TK幣 = NT\$1，可於結帳時折抵使用',
                style: TextStyle(
                  fontSize: 12,
                  color: blackColor60,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 建立調整按鈕（+/-）
  Widget _buildAdjustButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: onPressed != null ? blackColor5 : blackColor10,
          foregroundColor: onPressed != null ? blackColor : blackColor40,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// 建立快速選擇按鈕
  Widget _buildQuickSelectButton({
    required String label,
    VoidCallback? onPressed,
  }) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          side: BorderSide(
            color: onPressed != null ? primaryColor : blackColor20,
          ),
          foregroundColor: onPressed != null ? primaryColor : blackColor40,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
