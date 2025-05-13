import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xxgkamiexe/models/database_connection.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();
  
  final _storage = const FlutterSecureStorage();
  final _db = DatabaseConnection();
  
  final Rx<bool> isLoggedIn = false.obs;
  final Rx<String> username = ''.obs;
  final Rx<int> userId = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    checkLoggedIn();
  }
  
  Future<void> checkLoggedIn() async {
    final savedUserId = await _storage.read(key: 'user_id');
    final savedUsername = await _storage.read(key: 'username');
    
    if (savedUserId != null && savedUsername != null) {
      userId.value = int.parse(savedUserId);
      username.value = savedUsername;
      isLoggedIn.value = true;
    }
  }
  
  Future<bool> login(String username, String password) async {
    try {
      final user = await _db.validateAdminLogin(username, password);
      
      if (user != null) {
        this.username.value = user['username'] as String;
        userId.value = user['id'] as int;
        isLoggedIn.value = true;
        
        // 保存登录信息
        await _storage.write(key: 'user_id', value: userId.value.toString());
        await _storage.write(key: 'username', value: this.username.value);
        
        // 更新最后登录时间
        await _db.updateAdminLastLogin(userId.value);
        
        return true;
      }
      return false;
    } catch (e) {
      print('登录失败: $e');
      return false;
    }
  }
  
  Future<void> logout() async {
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'username');
    
    isLoggedIn.value = false;
    username.value = '';
    userId.value = 0;
    
    // 断开数据库连接
    // 注意：如果你希望在返回登录页面或数据库连接页面后仍然保持数据库连接
    // 则可以注释掉这一行
    // await _db.close();
    
    Get.offAllNamed('/login');
  }
} 