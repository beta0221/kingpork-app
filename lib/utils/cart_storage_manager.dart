import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tklab_ec_v2/models/cart_models.dart';

/// 購物車本地儲存管理器
/// 使用 SharedPreferences 儲存購物車資料
class CartStorageManager {
  static const String _cartItemsKey = 'cart_items';

  /// 保存購物車到 localStorage
  ///
  /// 將購物車項目列表序列化為 JSON 並保存到 SharedPreferences
  Future<void> saveCart(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_cartItemsKey, jsonString);
    } catch (e) {
      // 儲存失敗時拋出異常，讓上層處理
      throw Exception('儲存購物車失敗: ${e.toString()}');
    }
  }

  /// 從 localStorage 讀取購物車
  ///
  /// 從 SharedPreferences 讀取並反序列化購物車資料
  /// 如果沒有資料或讀取失敗，返回空列表
  Future<List<CartItem>> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cartItemsKey);

      // 如果沒有儲存的資料，返回空列表
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      // 反序列化 JSON
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => CartItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 讀取失敗時返回空列表，避免應用崩潰
      // ignore: avoid_print
      print('讀取購物車失敗: ${e.toString()}');
      return [];
    }
  }

  /// 清空 localStorage 中的購物車資料
  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartItemsKey);
    } catch (e) {
      throw Exception('清空購物車失敗: ${e.toString()}');
    }
  }

  /// 檢查 localStorage 中是否有購物車資料
  Future<bool> hasCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_cartItemsKey);
    } catch (e) {
      return false;
    }
  }
}
