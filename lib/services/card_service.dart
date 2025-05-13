import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:xxgkamiexe/models/card_model.dart';
import 'package:xxgkamiexe/models/database_connection.dart';

class CardService {
  final _db = DatabaseConnection();
  
  // 获取卡密列表
  Future<List<CardModel>> getCards({int limit = 20, int offset = 0, String? searchTerm}) async {
    if (_db.connection == null) {
      throw Exception('数据库未连接');
    }

    String query = 'SELECT * FROM cards';
    List<Object> params = [];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      query += ' WHERE card_key LIKE ? OR encrypted_key LIKE ?';
      params.add('%$searchTerm%');
      params.add('%$searchTerm%');
    }

    query += ' ORDER BY id DESC LIMIT ? OFFSET ?';
    params.add(limit);
    params.add(offset);

    final results = await _db.connection!.query(query, params);
    return results.map((row) => CardModel.fromMap(row.fields)).toList();
  }

  // 获取卡密总数
  Future<int> getCardCount({String? searchTerm}) async {
    if (_db.connection == null) {
      throw Exception('数据库未连接');
    }

    String query = 'SELECT COUNT(*) as count FROM cards';
    List<Object> params = [];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      query += ' WHERE card_key LIKE ? OR encrypted_key LIKE ?';
      params.add('%$searchTerm%');
      params.add('%$searchTerm%');
    }

    final result = await _db.connection!.query(query, params);
    return result.first['count'] as int;
  }

  // 根据ID获取卡密
  Future<CardModel?> getCardById(int id) async {
    if (_db.connection == null) {
      throw Exception('数据库未连接');
    }

    final results = await _db.connection!.query(
      'SELECT * FROM cards WHERE id = ?',
      [id]
    );

    if (results.isNotEmpty) {
      return CardModel.fromMap(results.first.fields);
    }
    return null;
  }

  // 生成随机卡密
  String generateCardKey(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join('');
  }

  // 加密卡密
  String encryptCardKey(String cardKey, String method) {
    if (method == 'sha1') {
      return sha1.convert(utf8.encode(cardKey)).toString();
    } else if (method == 'rc4') {
      // 简化处理，实际应该实现RC4加密
      return sha1.convert(utf8.encode('rc4_' + cardKey)).toString();
    }
    return sha1.convert(utf8.encode(cardKey)).toString();
  }

  // 添加卡密
  Future<bool> addCard({
    String? cardKey,
    required int duration,
    required String verifyMethod,
    required bool allowReverify,
    required String encryptionType,
    required String cardType,
    required int totalCount
  }) async {
    if (_db.connection == null) {
      throw Exception('数据库未连接');
    }
    
    // 自动生成卡密如果没有提供
    final key = cardKey ?? generateCardKey(20);
    final encryptedKey = encryptCardKey(key, encryptionType);

    try {
      await _db.connection!.query(
        '''
        INSERT INTO cards (
          card_key, encrypted_key, status, create_time, duration, 
          verify_method, allow_reverify, encryption_type, card_type, 
          total_count, remaining_count
        ) VALUES (?, ?, 0, NOW(), ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          key, encryptedKey, duration, verifyMethod, allowReverify ? 1 : 0,
          encryptionType, cardType, totalCount, totalCount
        ]
      );
      return true;
    } catch (e) {
      print('添加卡密失败: $e');
      return false;
    }
  }

  // 批量生成卡密
  Future<int> generateCards({
    required int count,
    required int duration,
    required String verifyMethod,
    required bool allowReverify,
    required String encryptionType,
    required String cardType,
    required int totalCount
  }) async {
    if (_db.connection == null) {
      throw Exception('数据库未连接');
    }

    int successCount = 0;
    for (int i = 0; i < count; i++) {
      final key = generateCardKey(20);
      final encryptedKey = encryptCardKey(key, encryptionType);

      try {
        await _db.connection!.query(
          '''
          INSERT INTO cards (
            card_key, encrypted_key, status, create_time, duration, 
            verify_method, allow_reverify, encryption_type, card_type, 
            total_count, remaining_count
          ) VALUES (?, ?, 0, NOW(), ?, ?, ?, ?, ?, ?, ?)
          ''',
          [
            key, encryptedKey, duration, verifyMethod, allowReverify ? 1 : 0,
            encryptionType, cardType, totalCount, totalCount
          ]
        );
        successCount++;
      } catch (e) {
        print('生成卡密失败: $e');
      }
    }
    return successCount;
  }

  // 更新卡密状态
  Future<bool> updateCardStatus(int id, int status) async {
    if (_db.connection == null) {
      throw Exception('数据库未连接');
    }

    try {
      await _db.connection!.query(
        'UPDATE cards SET status = ? WHERE id = ?',
        [status, id]
      );
      return true;
    } catch (e) {
      print('更新卡密状态失败: $e');
      return false;
    }
  }

  // 删除卡密
  Future<bool> deleteCard(int id) async {
    if (_db.connection == null) {
      throw Exception('数据库未连接');
    }

    try {
      await _db.connection!.query(
        'DELETE FROM cards WHERE id = ?',
        [id]
      );
      return true;
    } catch (e) {
      print('删除卡密失败: $e');
      return false;
    }
  }
  
  // 更新卡密设备绑定
  Future<bool> updateCardDeviceBinding(int id, String? deviceId) async {
    if (_db.connection == null) {
      throw Exception('数据库未连接');
    }
    
    try {
      await _db.connection!.query(
        'UPDATE cards SET device_id = ? WHERE id = ?',
        [deviceId, id]
      );
      return true;
    } catch (e) {
      print('更新卡密设备绑定失败: $e');
      return false;
    }
  }
  
  // 延长卡密到期时间
  Future<bool> extendCardExpiration(int id, int daysToAdd) async {
    if (_db.connection == null) {
      throw Exception('数据库未连接');
    }
    
    if (daysToAdd <= 0) {
      return false;
    }
    
    try {
      // 首先获取卡密信息
      final results = await _db.connection!.query(
        'SELECT * FROM cards WHERE id = ?',
        [id]
      );
      
      if (results.isEmpty) {
        return false;
      }
      
      final card = CardModel.fromMap(results.first.fields);
      
      // 如果卡密已经有到期时间，则延长
      if (card.expireTime != null) {
        await _db.connection!.query(
          'UPDATE cards SET expire_time = DATE_ADD(expire_time, INTERVAL ? DAY) WHERE id = ?',
          [daysToAdd, id]
        );
      } 
      // 如果卡密没有到期时间，但有使用时间，则从使用时间开始计算
      else if (card.useTime != null) {
        await _db.connection!.query(
          'UPDATE cards SET expire_time = DATE_ADD(use_time, INTERVAL ? DAY) WHERE id = ?',
          [card.duration + daysToAdd, id]
        );
      }
      // 如果既没有到期时间也没有使用时间，则更新duration值
      else {
        await _db.connection!.query(
          'UPDATE cards SET duration = duration + ? WHERE id = ?',
          [daysToAdd, id]
        );
      }
      
      return true;
    } catch (e) {
      print('延长卡密到期时间失败: $e');
      return false;
    }
  }
  
  // 更新卡密剩余次数
  Future<bool> updateCardRemainingCount(int id, int newRemainingCount) async {
    if (_db.connection == null) {
      throw Exception('数据库未连接');
    }
    
    if (newRemainingCount < 0) {
      return false;
    }
    
    try {
      // 首先检查卡密是否存在且是次数类型
      final results = await _db.connection!.query(
        'SELECT * FROM cards WHERE id = ? AND card_type = "count"',
        [id]
      );
      
      if (results.isEmpty) {
        return false;
      }
      
      final card = CardModel.fromMap(results.first.fields);
      
      // 确保新的剩余次数不超过总次数
      final safeRemainingCount = newRemainingCount > card.totalCount ? card.totalCount : newRemainingCount;
      
      await _db.connection!.query(
        'UPDATE cards SET remaining_count = ? WHERE id = ?',
        [safeRemainingCount, id]
      );
      
      return true;
    } catch (e) {
      print('更新卡密剩余次数失败: $e');
      return false;
    }
  }
} 