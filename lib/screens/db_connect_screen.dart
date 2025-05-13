import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:xxgkamiexe/models/database_connection.dart';

class DBConnectScreen extends StatefulWidget {
  const DBConnectScreen({super.key});

  @override
  State<DBConnectScreen> createState() => _DBConnectScreenState();
}

class _DBConnectScreenState extends State<DBConnectScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  final _db = DatabaseConnection();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  
  @override
  void initState() {
    super.initState();
    // 初始化动画
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    
    _checkSavedConnection();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _checkSavedConnection() async {
    final hasSettings = await _db.loadConnectionSettings();
    if (hasSettings) {
      setState(() => _isLoading = true);
      
      final success = await _db.connect();
      setState(() => _isLoading = false);
      
      if (success) {
        Get.toNamed('/login');
      }
    }
  }
  
  Future<void> _tryConnect() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = _formKey.currentState!.value;
      
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });
      
      try {
        await _db.saveConnectionSettings(
          data['host'] as String,
          int.parse(data['port'] as String),
          data['user'] as String,
          data['password'] as String,
          data['database'] as String,
        );
        
        final success = await _db.connect();
        
        if (success) {
          Get.toNamed('/login');
        } else {
          setState(() {
            _hasError = true;
            _errorMessage = '连接数据库失败，请检查连接信息';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _hasError = true;
          _errorMessage = '错误: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: Card(
              elevation: 8,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.all(32),
                child: _isLoading
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '连接数据库中...',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.storage, size: 32, color: Colors.blue.shade600),
                              const SizedBox(width: 16),
                              Text(
                                '数据库连接',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '请填写MySQL/MariaDB数据库连接信息',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          if (_hasError)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade700),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage,
                                      style: TextStyle(color: Colors.red.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          FormBuilder(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildTextField(
                                  name: 'host',
                                  labelText: '数据库主机',
                                  hintText: 'localhost',
                                  prefixIcon: Icons.computer,
                                  initialValue: 'localhost',
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  name: 'port',
                                  labelText: '数据库端口',
                                  hintText: '3306',
                                  prefixIcon: Icons.settings_ethernet,
                                  initialValue: '3306',
                                  isNumeric: true,
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  name: 'user',
                                  labelText: '用户名',
                                  hintText: 'root',
                                  prefixIcon: Icons.person,
                                  initialValue: 'root',
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  name: 'password',
                                  labelText: '密码',
                                  prefixIcon: Icons.password,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  name: 'database',
                                  labelText: '数据库名',
                                  hintText: 'kami',
                                  prefixIcon: Icons.storage,
                                  initialValue: 'kami',
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton(
                                  onPressed: _tryConnect,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(56),
                                    backgroundColor: Colors.blue.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    '连接数据库',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // 测试环境连接按钮
                                TextButton.icon(
                                  icon: const Icon(Icons.settings_suggest),
                                  label: const Text('使用测试环境连接'),
                                  onPressed: () {
                                    _formKey.currentState?.patchValue({
                                      'host': 'localhost',
                                      'port': '3306',
                                      'user': 'root',
                                      'password': '',
                                      'database': 'kami',
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // 构建统一风格的输入框
  Widget _buildTextField({
    required String name,
    required String labelText,
    String? hintText,
    required IconData prefixIcon,
    String? initialValue,
    bool isPassword = false,
    bool isNumeric = false,
  }) {
    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: Colors.blue.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      initialValue: initialValue,
      obscureText: isPassword,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: FormBuilderValidators.compose([
        if (name != 'password') FormBuilderValidators.required(errorText: '${labelText}不能为空'),
        if (isNumeric) FormBuilderValidators.numeric(errorText: '请输入有效的数字'),
      ]),
    );
  }
} 