import 'package:flutter/material.dart';

/// 送貨方式
enum DeliveryMethod {
  sevenEleven, // 7-11
  familyMart, // 全家
  homeDelivery, // 宅配
  overseasShipping; // 海外郵寄

  String get displayText {
    switch (this) {
      case DeliveryMethod.sevenEleven:
        return '7-11';
      case DeliveryMethod.familyMart:
        return '全家';
      case DeliveryMethod.homeDelivery:
        return '宅配';
      case DeliveryMethod.overseasShipping:
        return '海外郵寄';
    }
  }

  IconData get displayIcon {
    switch (this) {
      case DeliveryMethod.sevenEleven:
      case DeliveryMethod.familyMart:
        return Icons.store;
      case DeliveryMethod.homeDelivery:
        return Icons.local_shipping;
      case DeliveryMethod.overseasShipping:
        return Icons.flight;
    }
  }
}

/// 付款方式
enum PaymentMethod {
  creditCard, // 信用卡一次付清
  unionPay, // 銀聯卡
  applePay, // ApplePay
  cashOnDelivery, // 7-11取貨付款
  atmTransfer; // ATM付款

  String get displayText {
    switch (this) {
      case PaymentMethod.creditCard:
        return '信用卡一次付清';
      case PaymentMethod.unionPay:
        return '銀聯卡';
      case PaymentMethod.applePay:
        return 'ApplePay';
      case PaymentMethod.cashOnDelivery:
        return '7-11取貨付款';
      case PaymentMethod.atmTransfer:
        return 'ATM付款';
    }
  }

  IconData get displayIcon {
    switch (this) {
      case PaymentMethod.creditCard:
      case PaymentMethod.unionPay:
        return Icons.credit_card;
      case PaymentMethod.applePay:
        return Icons.apple;
      case PaymentMethod.cashOnDelivery:
        return Icons.store;
      case PaymentMethod.atmTransfer:
        return Icons.account_balance;
    }
  }
}

/// 發票類型
enum InvoiceType {
  cloud, // 雲端發票
  donation, // 發票捐贈
  triplicate; // 三聯式發票

  String get displayText {
    switch (this) {
      case InvoiceType.cloud:
        return '雲端發票';
      case InvoiceType.donation:
        return '發票捐贈';
      case InvoiceType.triplicate:
        return '三聯式發票';
    }
  }

  IconData get displayIcon {
    switch (this) {
      case InvoiceType.cloud:
        return Icons.cloud;
      case InvoiceType.donation:
        return Icons.volunteer_activism;
      case InvoiceType.triplicate:
        return Icons.receipt_long;
    }
  }

  /// 是否需要額外輸入欄位
  bool get requiresAdditionalInput {
    return this == InvoiceType.donation || this == InvoiceType.triplicate;
  }
}
