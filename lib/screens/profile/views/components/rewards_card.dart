import 'package:flutter/material.dart';
import 'package:tklab_ec_v2/constants.dart';

class RewardsCard extends StatelessWidget {
  const RewardsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding * 1.5,
        vertical: defaultPadding,
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(253, 241, 217, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // TK幣 section
          Expanded(
            child: _RewardItem(
              icon: Icons.monetization_on_outlined,
              iconColor: const Color.fromRGBO(238, 155, 53, 1.0),
              title: 'TK幣',
              value: '0',
              hasNotification: false,
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 40,
            color: Colors.black.withValues(alpha: 0.1),
            margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
          ),
          // 現金券 section
          Expanded(
            child: _RewardItem(
              icon: Icons.confirmation_num_outlined,
              iconColor: const Color.fromRGBO(238, 155, 53, 1.0),
              title: '現金券',
              value: '3',
              hasNotification: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final bool hasNotification;

  const _RewardItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.hasNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon with notification badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            if (hasNotification)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Title
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        // Value
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color.fromRGBO(238, 155, 53, 1.0),
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
