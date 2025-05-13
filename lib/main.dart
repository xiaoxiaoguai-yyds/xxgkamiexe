import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xxgkamiexe/screens/db_connect_screen.dart';
import 'package:xxgkamiexe/screens/login_screen.dart';
import 'package:xxgkamiexe/screens/home_screen.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 根据平台选择适合中文显示的字体
    final String fontFamily = _getSystemChineseFont();
    
    return GetMaterialApp(
      title: '卡密管理系统',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: fontFamily, // 使用系统中文字体
        textTheme: TextTheme(
          // 继承默认样式但应用字体
          displayLarge: TextStyle(fontFamily: fontFamily, fontSize: 96, fontWeight: FontWeight.w300, letterSpacing: -1.5),
          displayMedium: TextStyle(fontFamily: fontFamily, fontSize: 60, fontWeight: FontWeight.w300, letterSpacing: -0.5),
          displaySmall: TextStyle(fontFamily: fontFamily, fontSize: 48, fontWeight: FontWeight.w400),
          headlineLarge: TextStyle(fontFamily: fontFamily, fontSize: 40, fontWeight: FontWeight.w400, letterSpacing: 0.25),
          headlineMedium: TextStyle(fontFamily: fontFamily, fontSize: 34, fontWeight: FontWeight.w400),
          headlineSmall: TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w400),
          titleLarge: TextStyle(fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.15),
          titleMedium: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15),
          titleSmall: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
          bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
          bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
          bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
          labelLarge: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
          labelMedium: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
          labelSmall: TextStyle(fontFamily: fontFamily, fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/db_connect',
      getPages: [
        GetPage(name: '/db_connect', page: () => const DBConnectScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
      ],
    );
  }
  
  // 根据不同平台返回合适的中文字体
  String _getSystemChineseFont() {
    if (Platform.isWindows) {
      return 'Microsoft YaHei UI'; // Windows默认中文UI字体
    } else if (Platform.isMacOS) {
      return 'PingFang SC'; // macOS默认中文字体
    } else if (Platform.isIOS) {
      return 'PingFang SC'; // iOS默认中文字体
    } else if (Platform.isAndroid) {
      return 'Noto Sans SC'; // Android上广泛支持的中文字体
    } else {
      return 'Sans-serif'; // 默认无衬线字体
    }
  }
}
