class CardModel {
  final int id;
  final String cardKey;
  final String encryptedKey;
  final int status;
  final DateTime createTime;
  final DateTime? useTime;
  final DateTime? expireTime;
  final int duration;
  final String? verifyMethod;
  final bool allowReverify;
  final String? deviceId;
  final String encryptionType;
  final String cardType;
  final int totalCount;
  final int remainingCount;

  CardModel({
    required this.id,
    required this.cardKey,
    required this.encryptedKey,
    required this.status,
    required this.createTime,
    this.useTime,
    this.expireTime,
    required this.duration,
    this.verifyMethod,
    required this.allowReverify,
    this.deviceId,
    required this.encryptionType,
    required this.cardType,
    required this.totalCount,
    required this.remainingCount,
  });

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] as int,
      cardKey: map['card_key'] as String,
      encryptedKey: map['encrypted_key'] as String,
      status: map['status'] as int,
      createTime: map['create_time'] is DateTime 
          ? map['create_time'] as DateTime 
          : DateTime.parse(map['create_time'] as String),
      useTime: map['use_time'] != null 
          ? (map['use_time'] is DateTime 
              ? map['use_time'] as DateTime 
              : DateTime.parse(map['use_time'] as String))
          : null,
      expireTime: map['expire_time'] != null 
          ? (map['expire_time'] is DateTime 
              ? map['expire_time'] as DateTime 
              : DateTime.parse(map['expire_time'] as String))
          : null,
      duration: map['duration'] as int,
      verifyMethod: map['verify_method'] as String?,
      allowReverify: (map['allow_reverify'] as int) == 1,
      deviceId: map['device_id'] as String?,
      encryptionType: map['encryption_type'] as String,
      cardType: map['card_type'] as String,
      totalCount: map['total_count'] as int,
      remainingCount: map['remaining_count'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_key': cardKey,
      'encrypted_key': encryptedKey,
      'status': status,
      'create_time': createTime.toIso8601String(),
      'use_time': useTime?.toIso8601String(),
      'expire_time': expireTime?.toIso8601String(),
      'duration': duration,
      'verify_method': verifyMethod,
      'allow_reverify': allowReverify ? 1 : 0,
      'device_id': deviceId,
      'encryption_type': encryptionType,
      'card_type': cardType,
      'total_count': totalCount,
      'remaining_count': remainingCount,
    };
  }

  String get statusText {
    switch (status) {
      case 0:
        return '未使用';
      case 1:
        return '已使用';
      case 2:
        return '已停用';
      default:
        return '未知';
    }
  }

  String get cardTypeText {
    return cardType == 'time' ? '时间卡密' : '次数卡密';
  }
  
  // 格式化日期时间显示
  String get createTimeFormatted {
    return '${createTime.year}-${createTime.month.toString().padLeft(2, '0')}-${createTime.day.toString().padLeft(2, '0')} ${createTime.hour.toString().padLeft(2, '0')}:${createTime.minute.toString().padLeft(2, '0')}:${createTime.second.toString().padLeft(2, '0')}';
  }
  
  String? get useTimeFormatted {
    if (useTime == null) return null;
    return '${useTime!.year}-${useTime!.month.toString().padLeft(2, '0')}-${useTime!.day.toString().padLeft(2, '0')} ${useTime!.hour.toString().padLeft(2, '0')}:${useTime!.minute.toString().padLeft(2, '0')}:${useTime!.second.toString().padLeft(2, '0')}';
  }
  
  String? get expireTimeFormatted {
    if (expireTime == null) return null;
    return '${expireTime!.year}-${expireTime!.month.toString().padLeft(2, '0')}-${expireTime!.day.toString().padLeft(2, '0')} ${expireTime!.hour.toString().padLeft(2, '0')}:${expireTime!.minute.toString().padLeft(2, '0')}:${expireTime!.second.toString().padLeft(2, '0')}';
  }
} 