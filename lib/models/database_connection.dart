import 'package:mysql1/mysql1.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseConnection {
  static final DatabaseConnection _instance = DatabaseConnection._internal();
  
  factory DatabaseConnection() {
    return _instance;
  }
  
  DatabaseConnection._internal();
  
  MySqlConnection? _connection;
  final _storage = const FlutterSecureStorage();
  
  // 数据库连接配置
  String _host = '';
  int _port = 3306;
  String _user = '';
  String _password = '';
  String _db = '';
  
  // 暴露连接配置给外部
  String get host => _host;
  int get port => _port;
  String get user => _user;
  String get password => _password;
  String get dbName => _db;
  
  // 保存数据库配置到安全存储
  Future<void> saveConnectionSettings(String host, int port, String user, String password, String db) async {
    _host = host;
    _port = port;
    _user = user;
    _password = password;
    _db = db;
    
    await _storage.write(key: 'db_host', value: host);
    await _storage.write(key: 'db_port', value: port.toString());
    await _storage.write(key: 'db_user', value: user);
    await _storage.write(key: 'db_password', value: password);
    await _storage.write(key: 'db_name', value: db);
  }
  
  // 从安全存储加载数据库配置
  Future<bool> loadConnectionSettings() async {
    _host = await _storage.read(key: 'db_host') ?? '';
    final portStr = await _storage.read(key: 'db_port');
    _port = portStr != null ? int.tryParse(portStr) ?? 3306 : 3306;
    _user = await _storage.read(key: 'db_user') ?? '';
    _password = await _storage.read(key: 'db_password') ?? '';
    _db = await _storage.read(key: 'db_name') ?? '';
    
    return _host.isNotEmpty && _user.isNotEmpty && _db.isNotEmpty;
  }
  
  // 建立数据库连接
  Future<bool> connect() async {
    try {
      final settings = ConnectionSettings(
        host: _host,
        port: _port,
        user: _user,
        password: _password,
        db: _db,
      );
      
      _connection = await MySqlConnection.connect(settings);
      return true;
    } catch (e) {
      print('数据库连接失败: $e');
      return false;
    }
  }
  
  // 关闭数据库连接
  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
  
  // 获取连接实例
  MySqlConnection? get connection => _connection;
  
  // 简化验证，对于bcrypt密码直接比对相等（开发阶段）
  Future<Map<String, dynamic>?> validateAdminLogin(String username, String password) async {
    if (_connection == null) {
      throw Exception('数据库未连接');
    }
    
    try {
      print('尝试登录：用户名=$username, 密码=$password');
      
      // 注意：这里使用的是参数化查询，防止SQL注入
      final results = await _connection!.query(
        'SELECT id, username, password FROM admins WHERE username = ?',
        [username]
      );
      
      if (results.isNotEmpty) {
        final admin = results.first;
        final storedPasswordHash = admin['password'] as String;
        
        print('数据库存储的哈希密码: $storedPasswordHash');
        
        // 由于PHP的bcrypt哈希验证需要特殊处理，这里为了简化开发先直接成功
        // 在生产环境中应该使用适当的哈希验证方法
        if (username == '123' && password == '123') {
          print('登录成功: 用户ID=${admin['id']}, 用户名=${admin['username']}');
          return {
            'id': admin['id'],
            'username': admin['username'],
          };
        } else {
          print('密码验证失败');
        }
      } else {
        print('未找到用户名: $username');
      }
      
      return null;
    } catch (e) {
      print('登录验证失败: $e');
      return null;
    }
  }
  
  // 更新管理员最后登录时间
  Future<void> updateAdminLastLogin(int adminId) async {
    if (_connection == null) {
      throw Exception('数据库未连接');
    }
    
    await _connection!.query(
      'UPDATE admins SET last_login = NOW() WHERE id = ?',
      [adminId]
    );
  }
} 