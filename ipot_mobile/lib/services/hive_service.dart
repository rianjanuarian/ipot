import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _menuBoxName = 'menu_cache';
  static const String _orderBoxName = 'order_queue';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_menuBoxName);
    await Hive.openBox(_orderBoxName);
  }

  // menu caching
  static Future<void> cacheMenu(
      String tableId, Map<String, dynamic> data) async {
    final box = Hive.box(_menuBoxName);
    await box.put(tableId, jsonEncode(data));
  }

  static Map<String, dynamic>? getCachedMenu(String tableId) {
    final box = Hive.box(_menuBoxName);
    final data = box.get(tableId);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  //order queue
  static Future<void> addToQueue(Map<String, dynamic> orderRequest) async {
    final box = Hive.box(_orderBoxName);
    await box.add(jsonEncode(orderRequest));
  }

  static List<Map<String, dynamic>> getQueue() {
    final box = Hive.box(_orderBoxName);
    return box.values
        .map((e) => jsonDecode(e as String) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> clearQueue() async {
    final box = Hive.box(_orderBoxName);
    await box.clear();
  }

  static Future<void> removeFromQueue(int index) async {
    final box = Hive.box(_orderBoxName);
    await box.deleteAt(index);
  }
}
