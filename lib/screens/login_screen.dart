import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:xxgkamiexe/models/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    ));
    
    _animationController.forward();
    Get.put(AuthController());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final data = _formKey.currentState!.value;
      final username = data['username'] as String;
      final password = data['password'] as String;

      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      try {
        final success = await AuthController.to.login(username, password);

        if (success) {
          Get.offAllNamed('/home');
        } else {
          setState(() {
            _hasError = true;
            _errorMessage = '用户名或密码错误';
            _isLoading = false;
          });
          
          // 错误时轻微震动动画
          _shakeError();
        }
      } catch (e) {
        setState(() {
          _hasError = true;
          _errorMessage = '登录失败: $e';
          _isLoading = false;
        });
        
        // 错误时轻微震动动画
        _shakeError();
      }
    }
  }
  
  // 错误时的震动动画
  void _shakeError() {
    const double shakeOffset = 5.0;
    final controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 500),
    );
    
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticIn,
      ));
    
    controller.addListener(() {
      if (controller.isCompleted) {
        controller.dispose();
      }
    });
    
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.indigo.shade50,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Card(
                elevation: 8,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.all(32),
                  child: _isLoading
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              '登录中...',
                              style: TextStyle(
                                fontSize: 20,
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
                            // Logo区域
                            Container(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.vpn_key_rounded,
                                      size: 40,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    '小小怪卡密管理系统',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '请登录继续使用',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),
                            if (_hasError)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
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
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 16),
                                      color: Colors.red.shade700,
                                      onPressed: () {
                                        setState(() {
                                          _hasError = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            FormBuilder(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // 用户名输入框
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: FormBuilderTextField(
                                      name: 'username',
                                      decoration: InputDecoration(
                                        labelText: '用户名',
                                        hintText: '请输入管理员用户名',
                                        prefixIcon: Icon(Icons.person, color: Colors.blue.shade600),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                      ),
                                      validator: FormBuilderValidators.required(errorText: '请输入用户名'),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // 密码输入框
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: FormBuilderTextField(
                                      name: 'password',
                                      decoration: InputDecoration(
                                        labelText: '密码',
                                        hintText: '请输入管理员密码',
                                        prefixIcon: Icon(Icons.lock, color: Colors.blue.shade600),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                            color: Colors.grey.shade600,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                      ),
                                      obscureText: _obscurePassword,
                                      validator: FormBuilderValidators.required(errorText: '请输入密码'),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // 记住我选项
                                  FormBuilderCheckbox(
                                    name: 'remember_me',
                                    initialValue: false,
                                    title: Text(
                                      '记住我',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    activeColor: Colors.blue.shade600,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // 登录按钮
                                  SizedBox(
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade600,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.login),
                                          SizedBox(width: 10),
                                          Text(
                                            '登 录',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // 返回数据库连接页面链接
                                  TextButton.icon(
                                    icon: const Icon(Icons.arrow_back),
                                    label: const Text('返回数据库配置'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey.shade700,
                                    ),
                                    onPressed: () {
                                      Get.offAllNamed('/db_connect');
                                    },
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
      ),
    );
  }
} 