import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/theme/input_decoration_theme.dart';

import 'components/support_person_info.dart';
import 'components/text_message.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support chat"),
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
                    message: "Hi there!",
                    time: "15:37",
                    isSender: true,
                    isSent: true,
                    isRead: true,
                  ),
                  TextMessage(
                    message:
                        "Howdy, is there something we can help you with today?",
                    time: "15:38",
                    isSender: false,
                    isSent: false,
                  ),
                  TextMessage(
                    message: "I need some assistance.",
                    time: "15:43",
                    isSender: true,
                    isSent: true,
                    isRead: true,
                    isShowTime: false,
                  ),
                  TextMessage(
                    message: "Help me choose the best plan.",
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
                    hintText: "Write a message...",
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
