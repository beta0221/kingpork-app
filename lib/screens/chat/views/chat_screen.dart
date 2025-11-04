import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tklab_ec_v2/constants.dart';
import 'package:tklab_ec_v2/theme/input_decoration_theme.dart';

import 'components/support_person_info.dart';
import 'components/text_message.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("客服聊天"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              "assets/icons/info.svg",
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color!,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SupportPersonInfo(
            image: "https://i.imgur.com/IXnwbLk.png",
            name: "Mr.alidoost",
            isConnected: true,
            isActive: true,
            // isTyping: true,
          ),

          // For Better perfromance use [ListView.builder]
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding),
              child: ListView(
                children: const [
                  TextMessage(
                    message: "Hi 你好!",
                    time: "15:37",
                    isSender: true,
                    isSent: true,
                    isRead: true,
                  ),
                  TextMessage(
                    message:
                        "你好，很高興為您服務，有什麼我能幫你的嗎?",
                    time: "15:38",
                    isSender: false,
                    isSent: false,
                  ),
                  TextMessage(
                    message: "我需要一些幫助.",
                    time: "15:43",
                    isSender: true,
                    isSent: true,
                    isRead: true,
                    isShowTime: false,
                  ),
                  TextMessage(
                    message: "無法做決定.",
                    time: "15:43",
                    isSender: true,
                    isSent: true,
                    isRead: true,
                  ),
                ],
              ),
            ),
          ),
          // Text Field
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding / 2),
              child: Form(
                child: TextFormField(
                  decoration: InputDecoration(
                    filled: false,
                    hintText: "輸入訊息...",
                    border: secodaryOutlineInputBorder(context),
                    enabledBorder: secodaryOutlineInputBorder(context),
                    focusedBorder: focusedOutlineInputBorder,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
