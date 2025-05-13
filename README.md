# 小小怪卡密系统桌面管理端

![版本](https://img.shields.io/badge/版本-1.0.0-blue)
![开源协议](https://img.shields.io/badge/协议-MIT-green)
![平台](https://img.shields.io/badge/平台-Windows)

小小怪卡密系统桌面管理端是基于Flutter开发的跨平台桌面应用，为[小小怪卡密系统](https://xiaoxiaoguai-yyds.github.io/xxgkami.github.io/)提供强大的本地管理体验，支持多种卡密类型管理、批量操作和高级数据分析。

## 🌟 主要特性

- **跨平台支持**：适用于Windows系统
- **现代化UI设计**：精美的界面设计和流畅的动画效果
- **批量卡密管理**：支持批量生成、编辑和删除卡密
- **多选操作功能**：轻松选择多个卡密进行批量操作
- **双卡密类型**：支持时间卡密和次数卡密两种类型
- **API密钥管理**：集中管理API访问权限，可一键启用/禁用所有接口
- **数据统计分析**：直观的图表展示卡密使用情况和趋势
- **自定义数据库连接**：灵活配置MySQL/MariaDB数据库连接
- **数据导出功能**：支持多种条件筛选导出卡密数据为CSV格式

## 💻 系统要求

- **操作系统**: Windows 10/11,
- **数据库**: MySQL 5.7+ 或 MariaDB 10.3+
- **存储空间**: 100MB以上
- **内存**: 4GB以上

## 📥 安装方法

### Windows
1. 从[Releases](https://github.com/xiaoxiaoguai-yyds/xxgkamiexe/releases)页面下载最新的Windows安装包(.exe)
2. 双击安装包运行安装向导
3. 按照提示完成安装

## 🚀 快速开始

### 数据库配置

首次启动时，您需要配置数据库连接:

1. 输入MySQL/MariaDB数据库主机地址、端口、用户名、密码和数据库名
2. 点击"连接数据库"按钮测试连接
3. 成功连接后进入登录界面

### 登录系统

- 使用自己的账号密码进行登录

## 🔍 主要功能介绍

### 卡密管理
- 创建单个或批量生成卡密
- 支持时间卡密和次数卡密两种类型
- 管理卡密状态(未使用/已使用/已禁用)
- 多条件筛选和排序
- 导出卡密数据到CSV文件

### 批量操作
- 支持多选卡密进行批量管理
- 批量修改状态、删除
- 全选功能，快速选择所有卡密

### API管理
- 创建和管理API密钥
- 启用/禁用单个API密钥
- 批量启用/禁用所有API接口
- 查看API使用记录和统计

### 数据统计
- 卡密状态分布统计
- 卡密类型分布统计
- 最近30天卡密创建趋势
- 最近创建的卡密列表

### 系统设置
- 数据库连接配置
- 系统信息查看
- 版本历史记录

## 📝 版本历史

### v1.0.0 (2024-05-13)
- 发布桌面端卡密管理软件正式版
- 支持跨平台：Windows/macOS/Linux
- 实现完整的卡密管理功能
- 添加数据库连接配置功能
- 支持卡密批量生成和管理
- 支持API密钥管理
- 添加数据统计功能
- 实现批量操作功能

## 📚 文档资源

详细的使用文档，请访问我们的[官方文档站点](https://xiaoxiaoguai-yyds.github.io/xxgkami.github.io/docx.html)

## 🔗 相关链接

- [小小怪卡密系统网页版](https://xiaoxiaoguai-yyds.github.io/xxgkami.github.io/)
- [GitHub项目主页](https://github.com/xiaoxiaoguai-yyds/xxgkami)

## 📄 开源协议

本项目基于MIT协议开源，详细内容请查看[LICENSE](LICENSE)文件。

## 👥 贡献指南

欢迎贡献代码，提交问题和改进建议。请遵循以下步骤：

1. Fork本项目
2. 创建您的特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开Pull Request

## 📮 联系我们

- 邮箱: xxgyyds@vip.qq.com
- GitHub: [https://github.com/xiaoxiaoguai-yyds](https://github.com/xiaoxiaoguai-yyds)
