import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/viewmodels/order_confirmation_view_model.dart';

class RecipientInfoSection extends StatelessWidget {
  const RecipientInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderConfirmationViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            // 標題
            const Text(
              '收件人資料',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: defaultPadding),

            // 同會員資料選項
            GestureDetector(
              onTap: () {
                viewModel.toggleUseMemberInfo(!viewModel.useMemberInfo);
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Radio<bool>(
                      value: true,
                      groupValue: viewModel.useMemberInfo,
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.toggleUseMemberInfo(value);
                        }
                      },
                      activeColor: primaryColor,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('同會員資料'),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),

            // 姓名欄位
            TextFormField(
              initialValue: viewModel.recipientName,
              onChanged: viewModel.updateRecipientName,
              decoration: InputDecoration(
                hintText: '請填寫姓名',
                hintStyle: TextStyle(color: blackColor40),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: BorderSide(color: blackColor10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: BorderSide(color: blackColor10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: const BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '請填寫與證件相同姓名，以確保順利收件',
              style: TextStyle(
                fontSize: 12,
                color: blackColor40,
              ),
            ),
            const SizedBox(height: defaultPadding),

            // 手機欄位
            TextFormField(
              initialValue: viewModel.recipientPhone,
              onChanged: viewModel.updateRecipientPhone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '請填寫手機號碼',
                hintStyle: TextStyle(color: blackColor40),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: BorderSide(color: blackColor10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: BorderSide(color: blackColor10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: const BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),

            // Email 欄位
            TextFormField(
              initialValue: viewModel.recipientEmail,
              onChanged: viewModel.updateRecipientEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: '請填寫 Email',
                hintStyle: TextStyle(color: blackColor40),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: BorderSide(color: blackColor10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: BorderSide(color: blackColor10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: const BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '請填入訂單通知Email (訂單資訊將以此E-mail通知您)',
              style: TextStyle(
                fontSize: 12,
                color: blackColor40,
              ),
            ),
            const SizedBox(height: defaultPadding),

            // 訂單備註欄位
            TextFormField(
              onChanged: viewModel.updateOrderNote,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '訂單備註，有什麼想告訴我們嗎？',
                hintStyle: TextStyle(color: blackColor40),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: BorderSide(color: blackColor10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: BorderSide(color: blackColor10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: const BorderSide(color: primaryColor),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
