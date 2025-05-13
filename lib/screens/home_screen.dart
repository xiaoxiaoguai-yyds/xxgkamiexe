import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:xxgkamiexe/controllers/card_controller.dart';
import 'package:xxgkamiexe/models/auth_controller.dart';
import 'package:xxgkamiexe/models/card_model.dart';
import 'package:xxgkamiexe/models/database_connection.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:file_saver/file_saver.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late CardController _cardController;
  late AuthController _authController;
  int _selectedIndex = 0; // 控制当前选中的页面
  bool _isExpanded = true; // 控制侧边栏展开/收缩状态
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  // 添加多选相关的状态变量
  final Set<int> _selectedCardIds = <int>{};
  
  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _cardController = Get.put(CardController());
    
    // 初始化动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // 默认展开
    _animationController.value = 1.0;
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('卡密管理系统'),
        leading: IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animation,
          ),
          onPressed: _toggleSidebar,
          tooltip: _isExpanded ? '收起侧边栏' : '展开侧边栏',
        ),
        actions: [
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '当前用户: ${_authController.username.value}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          )),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '退出登录',
            onPressed: () => _authController.logout(),
          ),
        ],
      ),
      body: Row(
        children: [
          // 动画侧边栏导航
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final width = 72 + 128 * _animation.value;
              return Container(
                width: width,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(2, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildNavItem(
                              index: 0,
                              title: '卡密管理',
                              icon: Icons.key,
                              activeIcon: Icons.key,
                            ),
                            _buildNavItem(
                              index: 4,
                              title: '数据统计',
                              icon: Icons.bar_chart_outlined,
                              activeIcon: Icons.bar_chart,
                            ),
                            _buildNavItem(
                              index: 3,
                              title: 'API管理',
                              icon: Icons.api_outlined,
                              activeIcon: Icons.api,
                            ),
                            _buildNavItem(
                              index: 1,
                              title: '系统设置',
                              icon: Icons.settings_outlined,
                              activeIcon: Icons.settings,
                            ),
                            _buildNavItem(
                              index: 2,
                              title: '版本信息',
                              icon: Icons.info_outline,
                              activeIcon: Icons.info,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 底部收缩/展开按钮
                    _buildExpandButton(),
                  ],
                ),
              );
            },
          ),
          
          // 主内容区域
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _buildCurrentPage(),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建当前选中的页面
  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildCardManagementPage();
      case 1:
        return _buildSettingsPage();
      case 2:
        return _buildVersionInfoPage();
      case 3:
        return _buildApiManagementPage();
      case 4:
        return _buildDataStatisticsPage();
      default:
        return _buildCardManagementPage();
    }
  }
  
  // 切换侧边栏展开/收缩
  void _toggleSidebar() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  // 构建导航项
  Widget _buildNavItem({
    required int index,
    required String title,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = _selectedIndex == index;
    final iconColor = isSelected ? Colors.blue : Colors.grey.shade600;
    final textColor = isSelected ? Colors.blue : Colors.grey.shade600;
    final backgroundColor = isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          splashColor: Colors.blue.withOpacity(0.1),
          highlightColor: Colors.blue.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey<bool>(isSelected),
                    color: iconColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: _animation.value * 16),
                if (_animation.value > 0.1)
                  Opacity(
                    opacity: _animation.value,
                    child: SizedBox(
                      width: _animation.value * 100,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 构建底部的展开/收缩按钮
  Widget _buildExpandButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _toggleSidebar,
          child: Container(
            height: 48,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: _isExpanded 
                ? MainAxisAlignment.spaceBetween 
                : MainAxisAlignment.center,
              children: [
                if (_isExpanded)
                  Opacity(
                    opacity: _animation.value,
                    child: SizedBox(
                      width: _animation.value * 100,
                      child: const Text(
                        '收起侧边栏',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                Icon(
                  _isExpanded ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 卡密管理页面
  Widget _buildCardManagementPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索和操作按钮
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索卡密...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onSubmitted: (value) => _cardController.search(value),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('添加卡密'),
                onPressed: () => _showAddCardDialog(context),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.download, color: Colors.blue),
                tooltip: '导出卡密数据',
                onSelected: (value) => _exportCardsData(value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Row(
                      children: [
                        Icon(Icons.download_for_offline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('导出全部卡密'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'unused',
                    child: Row(
                      children: [
                        Icon(Icons.new_releases, color: Colors.green),
                        SizedBox(width: 8),
                        Text('仅导出未使用卡密'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'used',
                    child: Row(
                      children: [
                        Icon(Icons.history, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('仅导出已使用卡密'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'disabled',
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.red),
                        SizedBox(width: 8),
                        Text('仅导出已停用卡密'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'current',
                    child: Row(
                      children: [
                        Icon(Icons.filter_list, color: Colors.purple),
                        SizedBox(width: 8),
                        Text('导出当前筛选结果'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                icon: const Icon(Icons.select_all),
                label: _selectedCardIds.length == _cardController.cards.length && _cardController.cards.isNotEmpty
                    ? const Text('取消全选')
                    : const Text('全选'),
                onPressed: _selectAllCards,
              ),
              if (_selectedCardIds.isNotEmpty) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '已选择 ${_selectedCardIds.length} 张卡密',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('批量管理'),
                  onPressed: _showBatchOperationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('清除选择'),
                  onPressed: _cancelMultiSelect,
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 卡密数据表格
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Obx(() {
                  if (_cardController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (_cardController.cards.isEmpty) {
                    return const Center(child: Text('没有卡密数据'));
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: DataTable2(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 700,
                          dataRowHeight: 70,
                          dividerThickness: 1,
                          bottomMargin: 10,
                          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          columns: [
                            // 始终显示多选列，不再使用条件判断
                            const DataColumn2(
                              label: Text('选择'),
                              size: ColumnSize.S,
                            ),
                            const DataColumn2(
                              label: Text('ID'),
                              size: ColumnSize.S,
                            ),
                            const DataColumn2(
                              label: Text('卡密'),
                              size: ColumnSize.L,
                            ),
                            const DataColumn2(
                              label: Text('状态'),
                              size: ColumnSize.S,
                            ),
                            const DataColumn2(
                              label: Text('创建时间'),
                              size: ColumnSize.S,
                            ),
                            const DataColumn2(
                              label: Text('类型'),
                              size: ColumnSize.S,
                            ),
                            const DataColumn2(
                              label: Text('操作'),
                              size: ColumnSize.L,
                              fixedWidth: 150,
                            ),
                          ],
                          rows: _cardController.cards.map((card) {
                            return DataRow(
                              selected: _selectedCardIds.contains(card.id),
                              onSelectChanged: (selected) {
                                _toggleCardSelection(card.id);
                              },
                              cells: [
                                // 始终显示多选框
                                DataCell(
                                  Checkbox(
                                    value: _selectedCardIds.contains(card.id),
                                    onChanged: (selected) {
                                      _toggleCardSelection(card.id);
                                    },
                                  ),
                                ),
                                DataCell(Text('${card.id}')),
                                DataCell(
                                  InkWell(
                                    child: Text(card.cardKey),
                                    onTap: () => _showCardDetailsDialog(context, card),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: card.status == 0
                                          ? Colors.green.shade100
                                          : (card.status == 1 ? Colors.orange.shade100 : Colors.red.shade100),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      card.statusText,
                                      style: TextStyle(
                                        color: card.status == 0
                                            ? Colors.green.shade800
                                            : (card.status == 1 ? Colors.orange.shade800 : Colors.red.shade800),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(
                                  card.createTimeFormatted,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )),
                                DataCell(Text(card.cardTypeText)),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        tooltip: '编辑状态',
                                        onPressed: () {
                                          setState(() {
                                            _selectedCardIds.add(card.id);
                                          });
                                          _showBatchOperationDialog();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20),
                                        tooltip: '删除',
                                        onPressed: () => _showDeleteConfirmDialog(context, card),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      
                      // 分页控制
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _cardController.currentPage.value > 0
                                  ? () => _cardController.previousPage()
                                  : null,
                            ),
                            Obx(() => Text(
                              '第 ${_cardController.currentPage.value + 1} 页，共 ${(_cardController.totalCount.value / _cardController.pageSize.value).ceil()} 页',
                              style: const TextStyle(fontSize: 14),
                            )),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _cardController.currentPage.value < 
                                  ((_cardController.totalCount.value / _cardController.pageSize.value).ceil() - 1)
                                  ? () => _cardController.nextPage()
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 系统设置页面
  Widget _buildSettingsPage() {
    final db = DatabaseConnection();
    
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadDatabaseSettings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('加载设置失败: ${snapshot.error}'));
        }
        
        final settings = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.settings, size: 28, color: Colors.blue),
                      const SizedBox(width: 16),
                      const Text(
                        '系统设置',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  
                  // 选项卡导航
                  DefaultTabController(
                    length: 2,
                    child: Expanded(
                      child: Column(
                        children: [
                          const TabBar(
                            tabs: [
                              Tab(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.storage),
                                    SizedBox(width: 8),
                                    Text('数据库连接'),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.info),
                                    SizedBox(width: 8),
                                    Text('系统信息'),
                                  ],
                                ),
                              ),
                            ],
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue,
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // 数据库连接设置
                                _buildDatabaseSettingsTab(settings, db),
                                
                                // 系统信息
                                _buildSystemInfoTab(db),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  // 加载数据库设置
  Future<Map<String, dynamic>> _loadDatabaseSettings() async {
    final db = DatabaseConnection();
    await db.loadConnectionSettings();
    return {
      'host': db.host,
      'port': db.port.toString(),
      'user': db.user,
      'password': db.password,
      'database': db.dbName,
    };
  }
  
  // 数据库设置选项卡
  Widget _buildDatabaseSettingsTab(Map<String, dynamic> settings, DatabaseConnection db) {
    final formKey = GlobalKey<FormBuilderState>();
    
    return StatefulBuilder(
      builder: (context, setState) {
        bool isChecking = false;
        bool isConnected = db.connection != null;
        String connectionStatus = isConnected ? '已连接' : '未连接';
        Color statusColor = isConnected ? Colors.green : Colors.red;
        
        // 测试数据库连接
        Future<void> testConnection() async {
          if (formKey.currentState?.saveAndValidate() ?? false) {
            final data = formKey.currentState!.value;
            
            setState(() {
              isChecking = true;
              connectionStatus = '正在连接...';
              statusColor = Colors.orange;
            });
            
            try {
              // 先保存旧连接信息以便恢复
              final oldHost = db.host;
              final oldPort = db.port;
              final oldUser = db.user;
              final oldPassword = db.password;
              final oldDb = db.dbName;
              
              // 尝试连接新设置
              await db.saveConnectionSettings(
                data['host'] as String,
                int.parse(data['port'] as String),
                data['user'] as String,
                data['password'] as String,
                data['database'] as String,
              );
              
              // 关闭现有连接
              await db.close();
              
              // 尝试连接
              final success = await db.connect();
              
              setState(() {
                isChecking = false;
                isConnected = success;
                connectionStatus = success ? '连接成功' : '连接失败';
                statusColor = success ? Colors.green : Colors.red;
              });
              
              if (!success) {
                // 恢复旧设置
                await db.saveConnectionSettings(
                  oldHost, oldPort, oldUser, oldPassword, oldDb
                );
                await db.connect();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('连接失败，已恢复原连接'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } catch (e) {
              setState(() {
                isChecking = false;
                isConnected = false;
                connectionStatus = '错误: $e';
                statusColor = Colors.red;
              });
            }
          }
        }
        
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 连接状态
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.check_circle : Icons.error,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '数据库状态: $connectionStatus',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isChecking)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Expanded(
                child: SingleChildScrollView(
                  child: FormBuilder(
                    key: formKey,
                    initialValue: settings,
                    child: Column(
                      children: [
                        _buildTextField(
                          name: 'host',
                          labelText: '数据库主机',
                          hintText: 'localhost',
                          prefixIcon: Icons.computer,
                          validator: FormBuilderValidators.required(),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          name: 'port',
                          labelText: '端口',
                          hintText: '3306',
                          prefixIcon: Icons.settings_ethernet,
                          isNumeric: true,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          name: 'user',
                          labelText: '用户名',
                          hintText: 'root',
                          prefixIcon: Icons.person,
                          validator: FormBuilderValidators.required(),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          name: 'password',
                          labelText: '密码',
                          prefixIcon: Icons.password,
                          isPassword: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          name: 'database',
                          labelText: '数据库名',
                          hintText: 'kami',
                          prefixIcon: Icons.storage,
                          validator: FormBuilderValidators.required(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              // 测试连接和保存按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.bolt),
                    label: const Text('测试连接'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isChecking ? null : testConnection,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('保存并应用'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isChecking ? null : () async {
                      await testConnection();
                      if (isConnected) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('数据库设置已保存并应用'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 系统信息选项卡
  Widget _buildSystemInfoTab(DatabaseConnection db) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: '系统版本',
            content: 'xxgkamiexe v1.0.0',
            icon: Icons.info,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: '数据库信息',
            content: '${db.host}:${db.port} / ${db.dbName}',
            icon: Icons.storage,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: '当前用户',
            content: _authController.username.value,
            icon: Icons.person,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: '操作系统',
            content: 'Windows 10',
            icon: Icons.computer,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: '开发框架',
            content: 'Flutter 3.6',
            icon: Icons.code,
            color: Colors.teal,
          ),
        ],
      ),
    );
  }
  
  // 显示卡密详情对话框
  void _showCardDetailsDialog(BuildContext context, CardModel card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('卡密详情'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('ID', '${card.id}'),
              _detailRow('卡密', card.cardKey),
              _detailRow('加密后卡密', card.encryptedKey),
              _detailRow('状态', card.statusText),
              _detailRow('创建时间', card.createTimeFormatted),
              _detailRow('使用时间', card.useTimeFormatted ?? '未使用'),
              _detailRow('到期时间', card.expireTimeFormatted ?? '未设置'),
              _detailRow('时长(天)', '${card.duration}'),
              _detailRow('验证方式', card.verifyMethod ?? '未设置'),
              _detailRow('允许重复验证', card.allowReverify ? '是' : '否'),
              _detailRow('设备ID', card.deviceId ?? '未绑定'),
              _detailRow('加密类型', card.encryptionType),
              _detailRow('卡密类型', card.cardTypeText),
              _detailRow('总次数', '${card.totalCount}'),
              _detailRow('剩余次数', '${card.remainingCount}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  // 显示高级卡密管理对话框
  void _showAdvancedCardManagementDialog(BuildContext context, CardModel card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.settings, color: Colors.blue),
            const SizedBox(width: 8),
            Text('高级管理: ${card.cardKey}'),
          ],
        ),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 操作按钮列表
              ListView(
                shrinkWrap: true,
                children: [
                  // 修改设备绑定
                  ListTile(
                    leading: const Icon(Icons.phone_android, color: Colors.blue),
                    title: const Text('设备绑定管理'),
                    subtitle: Text('当前设备: ${card.deviceId ?? "未绑定"}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeviceBindingDialog(context, card);
                    },
                  ),
                  const Divider(height: 1),
                  
                  // 修改时间/次数
                  ListTile(
                    leading: const Icon(Icons.timer, color: Colors.orange),
                    title: Text('修改${card.cardType == 'time' ? '时间' : '次数'}'),
                    subtitle: card.cardType == 'time'
                        ? Text('到期时间: ${card.expireTimeFormatted ?? "未设置"}')
                        : Text('剩余次数: ${card.remainingCount}/${card.totalCount}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context);
                      _showModifyCardTimeDialog(context, card);
                    },
                  ),
                  const Divider(height: 1),
                  
                  // 暂停/启用卡密
                  if (card.status != 2) // 如果不是已停用状态
                    ListTile(
                      leading: const Icon(Icons.pause_circle, color: Colors.red),
                      title: const Text('暂停卡密'),
                      subtitle: const Text('临时停用此卡密，可再次启用'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        _showPauseCardDialog(context, card);
                      },
                    ),
                  if (card.status == 2) // 如果是已停用状态
                    ListTile(
                      leading: const Icon(Icons.play_circle, color: Colors.green),
                      title: const Text('启用卡密'),
                      subtitle: const Text('重新启用此卡密'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        _showReactivateCardDialog(context, card);
                      },
                    ),
                  const Divider(height: 1),
                  
                  // 复制卡密
                  ListTile(
                    leading: const Icon(Icons.copy, color: Colors.purple),
                    title: const Text('复制卡密信息'),
                    subtitle: const Text('复制卡密详细信息到剪贴板'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      final cardInfo = '卡密: ${card.cardKey}\n'
                          '状态: ${card.statusText}\n'
                          '创建时间: ${card.createTimeFormatted}\n'
                          '${card.useTimeFormatted != null ? '使用时间: ${card.useTimeFormatted}\n' : ''}'
                          '${card.expireTimeFormatted != null ? '到期时间: ${card.expireTimeFormatted}\n' : ''}'
                          '${card.cardType == 'time' ? '时长(天): ${card.duration}' : '剩余次数: ${card.remainingCount}/${card.totalCount}'}';
                          
                      Clipboard.setData(ClipboardData(text: cardInfo));
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('卡密信息已复制到剪贴板'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  // 设备绑定管理对话框
  void _showDeviceBindingDialog(BuildContext context, CardModel card) {
    final deviceIdController = TextEditingController(text: card.deviceId);
    bool isUnbinding = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.phone_android, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('设备绑定管理'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '卡密: ${card.cardKey}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              card.deviceId != null && card.deviceId!.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('当前已绑定设备:'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          card.deviceId!,
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      isUnbinding 
                        ? Column(
                            children: [
                              const Text(
                                '确认解绑此设备? 解绑后卡密可以在其他设备上使用。',
                                style: TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isUnbinding = false;
                                      });
                                    },
                                    child: const Text('取消'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () async {
                                      await _updateCardDeviceBinding(card.id, null);
                                      if (context.mounted) Navigator.pop(context);
                                    },
                                    child: const Text('确认解绑'),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.link_off),
                            label: const Text('解除设备绑定'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                isUnbinding = true;
                              });
                            },
                          ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('此卡密目前未绑定设备，可以绑定新设备:'),
                      const SizedBox(height: 16),
                      TextField(
                        controller: deviceIdController,
                        decoration: InputDecoration(
                          labelText: '设备标识符',
                          hintText: '输入要绑定的设备ID',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.devices),
                        ),
                      ),
                    ],
                  ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            if (!isUnbinding && (card.deviceId == null || card.deviceId!.isEmpty))
              ElevatedButton(
                onPressed: () async {
                  if (deviceIdController.text.isNotEmpty) {
                    await _updateCardDeviceBinding(card.id, deviceIdController.text);
                    if (context.mounted) Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('请输入设备标识符'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('绑定设备'),
              ),
          ],
        ),
      ),
    );
  }
  
  // 修改卡密时间/次数对话框
  void _showModifyCardTimeDialog(BuildContext context, CardModel card) {
    final formKey = GlobalKey<FormBuilderState>();
    
    // 时间卡密：添加天数
    // 次数卡密：修改剩余次数
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              card.cardType == 'time' ? Icons.timer : Icons.pin,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            Text('修改${card.cardType == 'time' ? '时间' : '次数'}'),
          ],
        ),
        content: FormBuilder(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '卡密: ${card.cardKey}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              if (card.cardType == 'time') ...[
                // 显示当前到期时间
                Text('当前到期时间: ${card.expireTimeFormatted ?? '未设置'}'),
                const SizedBox(height: 16),
                
                FormBuilderTextField(
                  name: 'daysToAdd',
                  decoration: InputDecoration(
                    labelText: '添加时间(天)',
                    hintText: '输入要添加的天数，如: 30',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.add_circle),
                  ),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: '请输入要添加的天数'),
                    FormBuilderValidators.numeric(errorText: '请输入有效数字'),
                    FormBuilderValidators.min(1, errorText: '最小添加1天'),
                  ]),
                ),
              ] else ...[
                // 显示当前剩余次数
                Text('当前剩余次数: ${card.remainingCount}/${card.totalCount}'),
                const SizedBox(height: 16),
                
                FormBuilderTextField(
                  name: 'newRemainingCount',
                  decoration: InputDecoration(
                    labelText: '修改剩余次数',
                    hintText: '输入新的剩余次数，如: 10',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  initialValue: '${card.remainingCount}',
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: '请输入剩余次数'),
                    FormBuilderValidators.numeric(errorText: '请输入有效数字'),
                    FormBuilderValidators.min(0, errorText: '最小为0次'),
                    FormBuilderValidators.max(card.totalCount, errorText: '不能超过总次数${card.totalCount}'),
                  ]),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.saveAndValidate() ?? false) {
                final data = formKey.currentState!.value;
                
                if (card.cardType == 'time') {
                  final daysToAdd = int.parse(data['daysToAdd']);
                  await _extendCardExpiration(card.id, daysToAdd);
                } else {
                  final newRemainingCount = int.parse(data['newRemainingCount']);
                  await _updateCardRemainingCount(card.id, newRemainingCount);
                }
                
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('确认修改'),
          ),
        ],
      ),
    );
  }
  
  // 暂停卡密对话框
  void _showPauseCardDialog(BuildContext context, CardModel card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.pause_circle, color: Colors.red),
            SizedBox(width: 8),
            Text('暂停卡密'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '卡密: ${card.cardKey}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '暂停后此卡密将无法使用，但可以随时重新启用。',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '注意: 对于时间类卡密，暂停期间仍会计算到期时间',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await _updateCardStatus(card.id, 2); // 2 = 已停用
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('确认暂停'),
          ),
        ],
      ),
    );
  }
  
  // 重新启用卡密对话框
  void _showReactivateCardDialog(BuildContext context, CardModel card) {
    // 提供两个选项：恢复为未使用状态 或 恢复为已使用状态
    int selectedStatus = 0; // 默认恢复为未使用状态
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.play_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('启用卡密'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '卡密: ${card.cardKey}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '选择要将卡密恢复的状态:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              // 状态选择
              RadioListTile<int>(
                title: const Row(
                  children: [
                    Icon(Icons.key, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text('未使用状态'),
                  ],
                ),
                subtitle: const Text('卡密将可以被重新激活使用'),
                value: 0,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
              RadioListTile<int>(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Text('已使用状态'),
                  ],
                ),
                subtitle: const Text('卡密将保持激活状态，但已被使用'),
                value: 1,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await _updateCardStatus(card.id, selectedStatus);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('确认启用'),
            ),
          ],
        ),
      ),
    );
  }
  
  // 更新卡密设备绑定
  Future<bool> _updateCardDeviceBinding(int cardId, String? deviceId) async {
    try {
      // 更新数据库中的设备绑定
      await _cardController.updateCardDeviceBinding(cardId, deviceId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(deviceId == null ? '已成功解除设备绑定' : '已成功绑定设备'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 刷新卡密列表
      _cardController.refreshCards();
      
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('设备绑定操作失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
  
  // 延长卡密到期时间
  Future<bool> _extendCardExpiration(int cardId, int daysToAdd) async {
    try {
      // 更新数据库中的到期时间
      await _cardController.extendCardExpiration(cardId, daysToAdd);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已成功添加 $daysToAdd 天'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 刷新卡密列表
      _cardController.refreshCards();
      
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('延长到期时间失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
  
  // 更新卡密剩余次数
  Future<bool> _updateCardRemainingCount(int cardId, int newRemainingCount) async {
    try {
      // 更新数据库中的剩余次数
      await _cardController.updateCardRemainingCount(cardId, newRemainingCount);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已成功修改剩余次数为 $newRemainingCount'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 刷新卡密列表
      _cardController.refreshCards();
      
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('修改剩余次数失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
  
  // 更新卡密状态
  Future<bool> _updateCardStatus(int cardId, int newStatus) async {
    try {
      // 更新数据库中的状态
      await _cardController.updateCardStatus(cardId, newStatus);
      
      final statusText = newStatus == 0 ? '未使用' : (newStatus == 1 ? '已使用' : '已停用');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已成功将卡密状态修改为"$statusText"'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 刷新卡密列表
      _cardController.refreshCards();
      
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('修改卡密状态失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
  
  // 详情行
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  // 自定义美化下拉框
  Widget _buildDropdownButton<T>({
    required String name,
    required String labelText,
    required List<DropdownMenuItem<T>> items,
    required T initialValue,
    String? helperText,
    Icon? prefixIcon,
    Function(T?)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: FormBuilderField<T>(
        name: name,
        initialValue: initialValue,
        validator: (value) => value == null ? '请选择$labelText' : null,
        builder: (FormFieldState<T> field) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              helperText: helperText,
              errorText: field.errorText,
              prefixIcon: prefixIcon,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: field.value,
                isDense: true,
                isExpanded: true,
                borderRadius: BorderRadius.circular(8),
                items: items,
                onChanged: (value) {
                  field.didChange(value);
                  if (onChanged != null) {
                    onChanged(value);
                  }
                },
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                menuMaxHeight: 300,
                elevation: 4,
              ),
            ),
          );
        },
      ),
    );
  }
  
  // 显示添加卡密对话框
  void _showAddCardDialog(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();
    String selectedCardType = 'time'; // 默认选择时间卡密
    String selectedTimeUnit = 'day'; // 默认选择天为单位
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder( // 使用dialogContext替代context
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.vpn_key, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('添加卡密'),
            ],
          ),
          content: Container(
            width: 450,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: FormBuilder(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '请选择卡密类型和相关参数，生成后系统会自动设置验证方式和加密类型。',
                            style: TextStyle(color: Colors.blue.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDropdownButton<String>(
                    name: 'cardType',
                    labelText: '卡密类型',
                    helperText: '选择卡密类型后会显示相应选项',
                    prefixIcon: const Icon(Icons.category),
                    initialValue: selectedCardType,
                    onChanged: (value) {
                      if (value != null && value != selectedCardType) {
                        setState(() {
                          selectedCardType = value;
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'time',
                        child: Row(
                          children: [
                            Icon(Icons.timer, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('时间卡密'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'count',
                        child: Row(
                          children: [
                            Icon(Icons.pin, color: Colors.green),
                            SizedBox(width: 8),
                            Text('次数卡密'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 根据卡密类型显示不同选项
                  if (selectedCardType == 'time') ...[
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: FormBuilderTextField(
                            name: 'duration',
                            decoration: InputDecoration(
                              labelText: '时长',
                              helperText: '请输入数值',
                              prefixIcon: const Icon(Icons.schedule),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            initialValue: '30',
                            keyboardType: TextInputType.number,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.numeric(),
                              FormBuilderValidators.min(1),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: _buildDropdownButton<String>(
                            name: 'timeUnit',
                            labelText: '单位',
                            prefixIcon: const Icon(Icons.access_time),
                            initialValue: selectedTimeUnit,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedTimeUnit = value;
                                });
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 'hour',
                                child: Text('小时'),
                              ),
                              DropdownMenuItem(
                                value: 'day',
                                child: Text('天'),
                              ),
                              DropdownMenuItem(
                                value: 'week',
                                child: Text('周'),
                              ),
                              DropdownMenuItem(
                                value: 'month',
                                child: Text('月'),
                              ),
                              DropdownMenuItem(
                                value: 'year',
                                child: Text('年'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  if (selectedCardType == 'count')
                    FormBuilderTextField(
                      name: 'totalCount',
                      decoration: InputDecoration(
                        labelText: '可用次数',
                        helperText: '次数卡密的总次数',
                        prefixIcon: const Icon(Icons.countertops),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      initialValue: '10',
                      keyboardType: TextInputType.number,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                        FormBuilderValidators.min(1),
                      ]),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // 生成数量选项
                  FormBuilderTextField(
                    name: 'generateCount',
                    decoration: InputDecoration(
                      labelText: '生成数量',
                      helperText: '要生成的卡密数量 (最多100个)',
                      prefixIcon: const Icon(Icons.copy),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    initialValue: '1',
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.min(1),
                      FormBuilderValidators.max(100),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.cancel),
              label: const Text('取消'),
              onPressed: () => Navigator.pop(dialogContext), // 使用dialogContext
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('生成'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (formKey.currentState?.saveAndValidate() ?? false) {
                  final data = formKey.currentState!.value;
                  final cardType = data['cardType'] as String;
                  final generateCount = int.parse(data['generateCount']);
                  
                  // 保存根Scaffold的MessengerState，以便在异步操作后安全使用
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  
                  // 先保存变量，防止context丢失
                  BuildContext currentContext = dialogContext;
                  Navigator.pop(dialogContext);
                  
                  // 如果生成数量大于1，显示生成中对话框
                  BuildContext? loadingDialogContext;
                  if (generateCount > 1) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) {
                        loadingDialogContext = ctx;
                        return AlertDialog(
                          title: Row(
                            children: [
                              const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              const SizedBox(width: 16),
                              const Text('正在生成卡密'),
                            ],
                          ),
                          content: SizedBox(
                            height: 100,
                            child: Center(
                              child: Text('正在生成 $generateCount 个卡密，请稍候...'),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  
                  try {
                    int successCount = 0;
                    
                    // 根据卡密类型和时间单位设置参数
                    int duration = 0;
                    
                    if (cardType == 'time') {
                      final int rawDuration = int.parse(data['duration']);
                      final String timeUnit = data['timeUnit'] as String;
                      
                      // 将不同时间单位转换为天数
                      switch (timeUnit) {
                        case 'hour':
                          duration = (rawDuration / 24).ceil(); // 小时转天，向上取整
                          break;
                        case 'day':
                          duration = rawDuration;
                          break;
                        case 'week':
                          duration = rawDuration * 7;
                          break;
                        case 'month':
                          duration = rawDuration * 30; // 简化处理，按30天/月
                          break;
                        case 'year':
                          duration = rawDuration * 365; // 简化处理，按365天/年
                          break;
                        default:
                          duration = rawDuration;
                      }
                    }
                    
                    final int totalCount = cardType == 'count' ? int.parse(data['totalCount']) : 0;
                    
                    // 使用默认值的参数
                    const String verifyMethod = 'web';
                    const bool allowReverify = true;
                    const String encryptionType = 'sha1';
                    
                    // 批量生成卡密
                    if (generateCount > 1) {
                      successCount = await _cardController.generateCards(
                        count: generateCount,
                        duration: duration,
                        verifyMethod: verifyMethod,
                        allowReverify: allowReverify,
                        encryptionType: encryptionType,
                        cardType: cardType,
                        totalCount: totalCount,
                      );
                      
                      // 关闭生成中对话框
                      if (loadingDialogContext != null && Navigator.canPop(loadingDialogContext!)) {
                        Navigator.pop(loadingDialogContext!);
                      }
                      
                      // 使用保存的scaffoldMessenger而不是ScaffoldMessenger.of(context)
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('成功生成 $successCount 张卡密'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      // 生成单个卡密
                      final success = await _cardController.addCard(
                        duration: duration,
                        verifyMethod: verifyMethod,
                        allowReverify: allowReverify,
                        encryptionType: encryptionType,
                        cardType: cardType,
                        totalCount: totalCount,
                      );
                      
                      if (success) {
                        // 使用保存的scaffoldMessenger
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('添加卡密成功'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        // 使用保存的scaffoldMessenger
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('添加卡密失败'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // 如果有错误且生成中对话框仍在显示，则关闭它
                    if (generateCount > 1 && loadingDialogContext != null && Navigator.canPop(loadingDialogContext!)) {
                      Navigator.pop(loadingDialogContext!);
                    }
                    
                    // 使用保存的scaffoldMessenger
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('生成卡密失败: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // 显示更新卡密状态对话框
  void _showUpdateStatusDialog(BuildContext context, CardModel card) {
    int selectedStatus = card.status;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更新卡密状态'),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('当前卡密: ${card.cardKey}'),
              const SizedBox(height: 16),
              const Text('选择新状态:'),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      RadioListTile<int>(
                        title: const Text('未使用'),
                        value: 0,
                        groupValue: selectedStatus,
                        onChanged: (value) {
                          setState(() => selectedStatus = value!);
                        },
                      ),
                      RadioListTile<int>(
                        title: const Text('已使用'),
                        value: 1,
                        groupValue: selectedStatus,
                        onChanged: (value) {
                          setState(() => selectedStatus = value!);
                        },
                      ),
                      RadioListTile<int>(
                        title: const Text('已停用'),
                        value: 2,
                        groupValue: selectedStatus,
                        onChanged: (value) {
                          setState(() => selectedStatus = value!);
                        },
                      ),
                    ],
                      );
                    },
                  ),
                ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedStatus != card.status) {
                final success = await _cardController.updateCardStatus(
                  card.id,
                  selectedStatus,
                );
                
                Navigator.pop(context);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('更新状态成功')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('更新状态失败')),
                  );
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('更新'),
          ),
        ],
      ),
    );
  }
  
  // 显示删除确认对话框
  void _showDeleteConfirmDialog(BuildContext context, CardModel card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除卡密 ${card.cardKey} 吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final success = await _cardController.deleteCard(card.id);
              
              Navigator.pop(context);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除卡密成功')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除卡密失败')),
                );
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
  
  // 构建信息卡片
  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建设置表单字段
  Widget _buildTextField({
    required String name,
    required String labelText,
    String? hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isNumeric = false,
    FormFieldValidator<String>? validator,
  }) {
    return FormBuilderTextField(
      name: name,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      obscureText: isPassword,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: validator,
    );
  }
  
  // 版本信息页面
  Widget _buildVersionInfoPage() {
    // 网页版本历史
    final webVersions = [
      {
        'version': 'v1.0.4 版',
        'date': '2023-08-15',
        'changes': [
'新增支持时间卡和次数卡两种类型',
'时间卡：基于使用时间的有效期',
'次数卡：基于使用次数的限制',
'无需设备ID直接验证卡密',
'支持卡密查询功能',
'弹窗显示卡密详细信息',
'可查看最近验证记录',
'采用美观的响应式界面',
        ],
      },
      {
        'version': 'v1.0.3 版',
        'date': '2025-04-21',
        'changes': [
          '管理员可后台解绑设备',
          '解绑后允许新设备验证并绑定',
          '可配置是否允许同设备重复验证',
          '修复已知bug',
        ],
      },
      {
        'version': 'v1.0.2 版',
        'date': '2025-01-24',
        'changes': [
          '添加卡密SHA1加密存储',
          '新增设备绑定机制',
          '支持多API密钥管理',
          '添加API调用统计',
          '完善卡密管理功能',
          '优化安装流程',
        ],
      },
      {
        'version': 'v1.0.1 版',
        'date': '2025-01-10',
        'changes': [
          '修复安装过程数据库报错问题',
          '美化安装界面',
          '新增首页弹窗提示',
          '删除系统检测，支持虚拟主机安装程序',
        ],
      },
      {
        'version': 'V1.0 版本',
        'date': '2025-01-07',
        'changes': [
          '初始版本发布',
          '实现基础验证功能',
          '完成管理后台',
          '添加API接口',
        ],
      },
    ];
    
    // 程序版本历史
    final appVersions = [
      {
        'version': 'v1.0.0',
        'date': '2023-09-01',
        'changes': [
          '发布桌面端卡密管理软件正式版',
          '支持跨平台：Windows/macOS/Linux',
          '实现完整的卡密管理功能',
          '添加数据库连接配置功能',
          '支持卡密批量生成和管理',
        ],
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                const Icon(Icons.history, size: 28, color: Colors.blue),
                const SizedBox(width: 16),
                const Text(
                  '版本历史',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
            mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.new_releases, color: Colors.blue.shade700, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '当前版本: v1.0.0',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 选项卡
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                tabs: [
                  const Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.desktop_windows),
                        SizedBox(width: 8),
                        Text('桌面端程序'),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.web),
                        SizedBox(width: 8),
                        Text('网页版'),
                      ],
                    ),
                  ),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.blue,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
            const SizedBox(height: 24),
            
            // 版本历史内容
            Expanded(
              child: TabBarView(
                children: [
                  // 桌面端程序版本历史
                  _buildVersionTimeline(appVersions, Colors.indigo),
                  
                  // 网页版版本历史
                  _buildVersionTimeline(webVersions, Colors.teal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建版本时间线
  Widget _buildVersionTimeline(List<Map<String, dynamic>> versions, Color baseColor) {
    return ListView.builder(
      itemCount: versions.length,
      itemBuilder: (context, index) {
        final version = versions[index];
        final isFirst = index == 0;
        final isLast = index == versions.length - 1;
        
        // 使用固定颜色而不是动态计算透明度
        final List<Color> versionColors = [
          baseColor,
          baseColor.withOpacity(0.9),
          baseColor.withOpacity(0.8),
          baseColor.withOpacity(0.7),
          baseColor.withOpacity(0.6),
        ];
        
        // 确保索引不会超出颜色列表范围
        final color = index < versionColors.length 
            ? versionColors[index] 
            : versionColors.last;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 时间线
            Container(
              width: 30,
              alignment: Alignment.center,
              child: Column(
                children: [
                  // 上半部分连接线
                  if (!isFirst)
                    Container(
                      width: 2,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                  
                  // 时间点
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: isFirst
                        ? const Icon(Icons.star, color: Colors.white, size: 12)
                        : null,
                  ),
                  
                  // 下半部分连接线
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 100,
                      color: Colors.grey.shade300,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // 版本内容
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 版本标题和日期
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(isFirst ? Icons.new_releases : Icons.history, size: 20, color: color),
                          const SizedBox(width: 8),
                          Text(
                            version['version'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: color,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            version['date'],
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 版本更新内容
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final change in version['changes'] as List)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.check_circle, size: 16, color: color),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      change,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // API管理页面
  Widget _buildApiManagementPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区域
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.api, color: Colors.purple, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API密钥管理',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '管理API密钥，控制外部访问权限',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // 添加启用/禁用所有接口的按钮
              Row(
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.settings, color: Colors.blue),
                    tooltip: '批量操作',
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'enable_all',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('启用所有接口'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'disable_all',
                        child: Row(
                          children: [
                            Icon(Icons.block, color: Colors.red),
                            SizedBox(width: 8),
                            Text('禁用所有接口'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'enable_all') {
                        _showBatchUpdateApiKeyStatusConfirmDialog(true);
                      } else if (value == 'disable_all') {
                        _showBatchUpdateApiKeyStatusConfirmDialog(false);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  // 新增API密钥按钮
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('新增API密钥'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () => _showAddApiKeyDialog(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // API密钥列表
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchApiKeys(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('加载API密钥失败: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('重试'),
                          onPressed: () => setState(() {}),
                        ),
                      ],
                    ),
                  );
                }
                
                final apiKeys = snapshot.data ?? [];
                
                if (apiKeys.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.key_off, color: Colors.grey, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          '暂无API密钥',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '点击"新增API密钥"按钮创建您的第一个API密钥',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('新增API密钥'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _showAddApiKeyDialog(context),
                        ),
                      ],
                    ),
                  );
                }
                
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 表格头
                        Expanded(
                          child: DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 700,
                            dataRowHeight: 70,
                            dividerThickness: 1,
                            bottomMargin: 10,
                            headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            columns: const [
                              DataColumn2(
                                label: Text('名称'),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: Text('API密钥'),
                                size: ColumnSize.L,
                              ),
                              DataColumn2(
                                label: Text('状态'),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: Text('创建时间'),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: Text('最后使用'),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: Text('使用次数'),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: Text('备注'),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: Text('操作'),
                                size: ColumnSize.L,
                                fixedWidth: 150,
                              ),
                            ],
                            rows: apiKeys.map((apiKey) {
                              final bool isActive = apiKey['status'] == 1;
                              
                              return DataRow(
                                cells: [
                                  DataCell(Text(
                                    apiKey['key_name'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  )),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            apiKey['api_key'],
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.copy, size: 18),
                                          tooltip: '复制',
                                          onPressed: () {
                                            // 复制到剪贴板
                                            Clipboard.setData(ClipboardData(text: apiKey['api_key']));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('API密钥已复制到剪贴板')),
                                            );
                                          },
                                          padding: const EdgeInsets.all(4),
                                          constraints: const BoxConstraints(
                                            minWidth: 30,
                                            minHeight: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isActive ? '启用' : '禁用',
                                        style: TextStyle(
                                          color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      constraints: const BoxConstraints(maxWidth: 100),
                                      child: Text(
                                        _formatDateTime(apiKey['create_time']),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      constraints: const BoxConstraints(maxWidth: 100),
                                      child: Text(
                                        apiKey['last_use_time'] != null 
                                          ? _formatDateTime(apiKey['last_use_time']) 
                                          : '从未使用',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text('${apiKey['use_count']}')),
                                  DataCell(Text(
                                    apiKey['description'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  )),
                                  DataCell(
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, size: 20),
                                              tooltip: '编辑',
                                              onPressed: () => _showEditApiKeyDialog(context, apiKey),
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(
                                                minWidth: 30,
                                                minHeight: 30,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                isActive ? Icons.block : Icons.check_circle, 
                                                size: 20,
                                                color: isActive ? Colors.red : Colors.green,
                                              ),
                                              tooltip: isActive ? '禁用' : '启用',
                                              onPressed: () => _toggleApiKeyStatus(apiKey['id'], !isActive),
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(
                                                minWidth: 30,
                                                minHeight: 30,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                              tooltip: '删除',
                                              onPressed: () => _showDeleteApiKeyDialog(context, apiKey['id'], apiKey['key_name']),
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(
                                                minWidth: 30,
                                                minHeight: 30,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // 获取API密钥列表
  Future<List<Map<String, dynamic>>> _fetchApiKeys() async {
    final db = DatabaseConnection();
    if (db.connection == null) {
      throw Exception('数据库未连接');
    }
    
    try {
      final results = await db.connection!.query('SELECT * FROM api_keys ORDER BY id DESC');
      return results.map((row) => row.fields).toList();
    } catch (e) {
      throw Exception('获取API密钥失败: $e');
    }
  }
  
  // 显示添加API密钥对话框
  void _showAddApiKeyDialog(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.api, color: Colors.purple),
            const SizedBox(width: 8),
            const Text('新增API密钥'),
          ],
        ),
        content: Container(
          width: 500,
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: 'key_name',
                  decoration: InputDecoration(
                    labelText: '密钥名称',
                    hintText: '请输入密钥名称',
                    prefixIcon: const Icon(Icons.label),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: '请输入密钥名称'),
                    FormBuilderValidators.maxLength(50, errorText: '名称不能超过50个字符'),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'description',
                  decoration: InputDecoration(
                    labelText: '备注说明',
                    hintText: '请输入备注说明（选填）',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  validator: FormBuilderValidators.maxLength(255, errorText: '备注不能超过255个字符'),
                ),
                const SizedBox(height: 16),
                FormBuilderSwitch(
                  name: 'status',
                  title: const Text('立即启用'),
                  initialValue: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('创建'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState?.saveAndValidate() ?? false) {
                final data = formKey.currentState!.value;
                
                try {
                  final generatedApiKey = await _createApiKey(
                    data['key_name'],
                    data['description'] ?? '',
                    data['status'] ? 1 : 0,
                  );
                  
                  // 先关闭添加对话框
                  if (context.mounted) Navigator.pop(context);
                  // 刷新页面
                  setState(() {});
                  
                  // 显示创建成功对话框，附带生成的API密钥
                  if (context.mounted) {
                    // 显示创建成功对话框
                    _showApiKeyCreatedDialog(context, generatedApiKey);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('创建失败: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
  
  // 显示API密钥创建成功对话框
  void _showApiKeyCreatedDialog(BuildContext context, String apiKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('API密钥创建成功'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('请保存以下密钥，此密钥只会显示一次：'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                apiKey,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('复制密钥'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: apiKey));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('API密钥已复制到剪贴板'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          ElevatedButton(
            child: const Text('确认'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  // 显示编辑API密钥对话框
  void _showEditApiKeyDialog(BuildContext context, Map<String, dynamic> apiKey) {
    final formKey = GlobalKey<FormBuilderState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('编辑API密钥'),
          ],
        ),
        content: Container(
          width: 500,
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: formKey,
            initialValue: {
              'key_name': apiKey['key_name'],
              'description': apiKey['description'] ?? '',
              'status': apiKey['status'] == 1,
            },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                FormBuilderTextField(
                  name: 'key_name',
                  decoration: InputDecoration(
                    labelText: '密钥名称',
                    hintText: '请输入密钥名称',
                    prefixIcon: const Icon(Icons.label),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: '请输入密钥名称'),
                    FormBuilderValidators.maxLength(50, errorText: '名称不能超过50个字符'),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'description',
                  decoration: InputDecoration(
                    labelText: '备注说明',
                    hintText: '请输入备注说明（选填）',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  validator: FormBuilderValidators.maxLength(255, errorText: '备注不能超过255个字符'),
                ),
                const SizedBox(height: 16),
                FormBuilderSwitch(
                  name: 'status',
                  title: const Text('是否启用'),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('保存'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState?.saveAndValidate() ?? false) {
                final data = formKey.currentState!.value;
                
                try {
                  await _updateApiKey(
                    apiKey['id'],
                    data['key_name'],
                    data['description'] ?? '',
                    data['status'] ? 1 : 0,
                  );
                  
                  Navigator.pop(context);
                  setState(() {}); // 刷新页面
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('API密钥更新成功'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('更新失败: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
  
  // 显示删除API密钥确认对话框
  void _showDeleteApiKeyDialog(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除API密钥"$name"吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('删除'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                await _deleteApiKey(id);
                
                Navigator.pop(context);
                setState(() {}); // 刷新页面
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('API密钥删除成功'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('删除失败: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
  
  // 创建新的API密钥
  Future<String> _createApiKey(String keyName, String description, int status) async {
    final db = DatabaseConnection();
    if (db.connection == null) {
      throw Exception('数据库未连接');
    }
    
    // 生成32位随机API密钥
    final apiKey = _generateRandomApiKey(32);
    
    try {
      await db.connection!.query(
        'INSERT INTO api_keys (key_name, api_key, status, description) VALUES (?, ?, ?, ?)',
        [keyName, apiKey, status, description],
      );
      
      // 返回生成的API密钥以便在UI中显示
      return apiKey;
    } catch (e) {
      throw Exception('创建API密钥失败: $e');
    }
  }
  
  // 更新API密钥
  Future<void> _updateApiKey(int id, String keyName, String description, int status) async {
    final db = DatabaseConnection();
    if (db.connection == null) {
      throw Exception('数据库未连接');
    }
    
    try {
      await db.connection!.query(
        'UPDATE api_keys SET key_name = ?, description = ?, status = ? WHERE id = ?',
        [keyName, description, status, id],
      );
    } catch (e) {
      throw Exception('更新API密钥失败: $e');
    }
  }
  
  // 切换API密钥状态
  Future<void> _toggleApiKeyStatus(int id, bool isActive) async {
    final db = DatabaseConnection();
    if (db.connection == null) {
      throw Exception('数据库未连接');
    }
    
    try {
      await db.connection!.query(
        'UPDATE api_keys SET status = ? WHERE id = ?',
        [isActive ? 1 : 0, id],
      );
      
      setState(() {}); // 刷新页面
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API密钥已${isActive ? '启用' : '禁用'}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('操作失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // 删除API密钥
  Future<void> _deleteApiKey(int id) async {
    final db = DatabaseConnection();
    if (db.connection == null) {
      throw Exception('数据库未连接');
    }
    
    try {
      await db.connection!.query(
        'DELETE FROM api_keys WHERE id = ?',
        [id],
      );
    } catch (e) {
      throw Exception('删除API密钥失败: $e');
    }
  }
  
  // 生成随机API密钥
  String _generateRandomApiKey(int length) {
    const String _chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random _rnd = Random.secure();
    
    // 使用真正的随机生成算法，确保每次生成的结果都是随机的
    return String.fromCharCodes(
      Iterable.generate(
        length, 
        (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))
      )
    );
  }
  
  // 格式化日期时间
  String _formatDateTime(dynamic dateTime) {
    if (dateTime is DateTime) {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime is String) {
      final dt = DateTime.parse(dateTime);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '未知';
  }

  // 导出卡密数据
  Future<void> _exportCardsData(String type) async {
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('正在准备导出数据...'),
          ],
        ),
      ),
    );
    
    try {
      final db = DatabaseConnection();
      if (db.connection == null) {
        throw Exception('数据库未连接');
      }
      
      // 根据类型构建查询条件
      String whereClause = '';
      switch (type) {
        case 'unused':
          whereClause = 'WHERE status = 0';
          break;
        case 'used':
          whereClause = 'WHERE status = 1';
          break;
        case 'disabled':
          whereClause = 'WHERE status = 2';
          break;
        case 'current':
          // 使用当前的搜索条件
          if (_searchController.text.isNotEmpty) {
            whereClause = "WHERE card_key LIKE '%${_searchController.text}%'";
          }
          break;
        case 'all':
        default:
          // 无条件，导出全部
          break;
      }
      
      // 执行查询
      final results = await db.connection!.query(
        'SELECT * FROM cards $whereClause ORDER BY id DESC'
      );
      
      if (results.isEmpty) {
        // 关闭加载对话框
        Navigator.pop(context);
        
        // 显示无数据提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('没有符合条件的卡密数据可导出'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // 转换结果为列表
      final List<CardModel> cards = results.map((row) {
        return CardModel.fromMap(row.fields);
      }).toList();
      
      // 构建CSV内容
      final StringBuffer csvData = StringBuffer();
      
      // 添加CSV头
      csvData.writeln('ID,卡密,状态,创建时间,使用时间,到期时间,时长(天),卡密类型,总次数,剩余次数,验证方式,允许重复验证,设备ID');
      
      // 添加数据行
      for (final card in cards) {
        csvData.writeln(
          '${card.id},${card.cardKey},${card.statusText},${card.createTimeFormatted},'
          '${card.useTimeFormatted ?? ""},${card.expireTimeFormatted ?? ""},'
          '${card.duration},${card.cardTypeText},${card.totalCount},${card.remainingCount},'
          '${card.verifyMethod ?? ""},${card.allowReverify ? "是" : "否"},${card.deviceId ?? ""}'
        );
      }
      
      // 关闭加载对话框
      Navigator.pop(context);
      
      // 打开导出对话框
      _showExportDialog(csvData.toString(), type);
      
    } catch (e) {
      // 关闭加载对话框
      Navigator.pop(context);
      
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导出失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // 显示导出对话框
  void _showExportDialog(String csvData, String exportType) {
    final DateTime now = DateTime.now();
    final String timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    
    // 根据导出类型设置文件名
    String fileNamePrefix = '全部卡密';
    switch (exportType) {
      case 'unused':
        fileNamePrefix = '未使用卡密';
        break;
      case 'used':
        fileNamePrefix = '已使用卡密';
        break;
      case 'disabled':
        fileNamePrefix = '已停用卡密';
        break;
      case 'current':
        fileNamePrefix = '筛选结果';
        break;
    }
    
    final String fileName = '${fileNamePrefix}_$timestamp.csv';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.file_download_done, color: Colors.green),
            const SizedBox(width: 8),
            const Text('导出成功'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('成功导出 ${csvData.split('\n').length - 2} 条卡密数据'),
            const SizedBox(height: 16),
            const Text('请选择导出操作:'),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('复制到剪贴板'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvData));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('数据已复制到剪贴板'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('保存文件'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                // 使用file_saver包保存文件
                Navigator.pop(context);
                
                // 显示保存进度对话框
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('正在保存文件...'),
                      ],
                    ),
                  ),
                );
                
                // 保存文件
                await FileSaver.instance.saveFile(
                  name: fileName,
                  bytes: Uint8List.fromList(csvData.toString().codeUnits),
                  ext: 'csv',
                  mimeType: MimeType.csv,
                );
                
                // 关闭进度对话框
                Navigator.pop(context);
                
                // 显示成功提示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('文件已保存: $fileName'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                // 关闭进度对话框(如果打开)
                Navigator.pop(context);
                
                // 保存失败则使用剪贴板备选方案
                Clipboard.setData(ClipboardData(text: csvData));
                _showSaveFileInstructions(context, fileName);
                
                // 显示错误提示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('保存文件失败: $e，数据已复制到剪贴板'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
  
  // 显示保存文件说明对话框
  void _showSaveFileInstructions(BuildContext context, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存文件说明'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('数据已复制到剪贴板，请按照以下步骤保存:'),
            const SizedBox(height: 16),
            const Text('1. 打开Excel或记事本等文本编辑器'),
            const Text('2. 粘贴剪贴板内容'),
            const Text('3. 保存为CSV文件'),
            const SizedBox(height: 16),
            Text('建议文件名: $fileName'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }

  // 数据统计页面
  Widget _buildDataStatisticsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区域
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '数据统计',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '直观了解卡密使用情况和趋势',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('刷新数据'),
                onPressed: () => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 统计卡片
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _loadStatisticsData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('加载统计数据失败: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('重试'),
                          onPressed: () => setState(() {}),
                        ),
                      ],
                    ),
                  );
                }
                
                final data = snapshot.data!;
                
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // 统计数据概览
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatsCard(
                              title: '卡密总数',
                              value: '${data['totalCards']}',
                              icon: Icons.vpn_key,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatsCard(
                              title: '未使用卡密',
                              value: '${data['unusedCards']}',
                              icon: Icons.new_releases,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatsCard(
                              title: '已使用卡密',
                              value: '${data['usedCards']}',
                              icon: Icons.check_circle,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatsCard(
                              title: '已停用卡密',
                              value: '${data['disabledCards']}',
                              icon: Icons.block,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // 图表区域
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 左侧：卡密状态分布饼图
                          Expanded(
                            flex: 1,
                            child: _buildCard(
                              title: '卡密状态分布',
                              child: SizedBox(
                                height: 300,
                                child: _buildStatusPieChart(data),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          
                          // 右侧：卡密类型分布饼图
                          Expanded(
                            flex: 1,
                            child: _buildCard(
                              title: '卡密类型分布',
                              child: SizedBox(
                                height: 300,
                                child: _buildTypePieChart(data),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // 下方：最近30天卡密创建趋势折线图
                      _buildCard(
                        title: '最近30天卡密创建趋势',
                        child: SizedBox(
                          height: 300,
                          child: _buildCardCreationTrendChart(data),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // 最近创建的卡密列表
                      _buildCard(
                        title: '最近创建的卡密',
                        child: _buildRecentCardsList(data),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // 加载统计数据
  Future<Map<String, dynamic>> _loadStatisticsData() async {
    final db = DatabaseConnection();
    if (db.connection == null) {
      throw Exception('数据库未连接');
    }
    
    try {
      // 获取卡密总数
      final totalResult = await db.connection!.query('SELECT COUNT(*) as count FROM cards');
      final totalCards = totalResult.first.fields['count'] as int;
      
      // 获取不同状态的卡密数量
      final statusResult = await db.connection!.query(
        'SELECT status, COUNT(*) as count FROM cards GROUP BY status'
      );
      
      int unusedCards = 0;
      int usedCards = 0;
      int disabledCards = 0;
      
      for (final row in statusResult) {
        final status = row.fields['status'] as int;
        final count = row.fields['count'] as int;
        
        switch (status) {
          case 0:
            unusedCards = count;
            break;
          case 1:
            usedCards = count;
            break;
          case 2:
            disabledCards = count;
            break;
        }
      }
      
      // 获取不同类型的卡密数量
      final typeResult = await db.connection!.query(
        'SELECT card_type, COUNT(*) as count FROM cards GROUP BY card_type'
      );
      
      int timeCards = 0;
      int countCards = 0;
      
      for (final row in typeResult) {
        final type = row.fields['card_type'] as String;
        final count = row.fields['count'] as int;
        
        if (type == 'time') {
          timeCards = count;
        } else if (type == 'count') {
          countCards = count;
        }
      }
      
      // 获取最近30天每天创建的卡密数量
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final dateFormat = DateFormat('yyyy-MM-dd');
      
      final trendResult = await db.connection!.query(
        'SELECT DATE(create_time) as date, COUNT(*) as count FROM cards '
        'WHERE create_time >= ? GROUP BY DATE(create_time) ORDER BY date',
        [dateFormat.format(thirtyDaysAgo)],
      );
      
      // 创建完整的30天日期列表，确保没有卡密创建的日期也有数据点
      final Map<String, int> trendData = {};
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: 29 - i));
        trendData[dateFormat.format(date)] = 0;
      }
      
      // 填充实际数据
      for (final row in trendResult) {
        final date = row.fields['date'].toString().split(' ')[0]; // 提取日期部分
        final count = row.fields['count'] as int;
        trendData[date] = count;
      }
      
      // 获取最近创建的10张卡密
      final recentCardsResult = await db.connection!.query(
        'SELECT * FROM cards ORDER BY id DESC LIMIT 10'
      );
      
      final recentCards = recentCardsResult.map((row) {
        return CardModel.fromMap(row.fields);
      }).toList();
      
      // 返回所有统计数据
      return {
        'totalCards': totalCards,
        'unusedCards': unusedCards,
        'usedCards': usedCards,
        'disabledCards': disabledCards,
        'timeCards': timeCards,
        'countCards': countCards,
        'trendData': trendData,
        'recentCards': recentCards,
      };
    } catch (e) {
      throw Exception('获取统计数据失败: $e');
    }
  }
  
  // 构建统计卡片
  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建卡片容器
  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }
  
  // 构建状态分布饼图
  Widget _buildStatusPieChart(Map<String, dynamic> data) {
    final unusedCards = data['unusedCards'] as int;
    final usedCards = data['usedCards'] as int;
    final disabledCards = data['disabledCards'] as int;
    final totalCards = unusedCards + usedCards + disabledCards;
    
    // 计算百分比
    final unusedPercentage = totalCards > 0 ? (unusedCards / totalCards * 100).toStringAsFixed(1) : '0';
    final usedPercentage = totalCards > 0 ? (usedCards / totalCards * 100).toStringAsFixed(1) : '0';
    final disabledPercentage = totalCards > 0 ? (disabledCards / totalCards * 100).toStringAsFixed(1) : '0';
    
    return Row(
      children: [
        // 饼图
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.green,
                  value: unusedCards.toDouble(),
                  title: '$unusedPercentage%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.orange,
                  value: usedCards.toDouble(),
                  title: '$usedPercentage%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: disabledCards.toDouble(),
                  title: '$disabledPercentage%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 图例
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(
                color: Colors.green,
                title: '未使用卡密',
                value: '$unusedCards ($unusedPercentage%)',
              ),
              const SizedBox(height: 16),
              _buildLegendItem(
                color: Colors.orange,
                title: '已使用卡密',
                value: '$usedCards ($usedPercentage%)',
              ),
              const SizedBox(height: 16),
              _buildLegendItem(
                color: Colors.red,
                title: '已停用卡密',
                value: '$disabledCards ($disabledPercentage%)',
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 构建类型分布饼图
  Widget _buildTypePieChart(Map<String, dynamic> data) {
    final timeCards = data['timeCards'] as int;
    final countCards = data['countCards'] as int;
    final totalCards = timeCards + countCards;
    
    // 计算百分比
    final timePercentage = totalCards > 0 ? (timeCards / totalCards * 100).toStringAsFixed(1) : '0';
    final countPercentage = totalCards > 0 ? (countCards / totalCards * 100).toStringAsFixed(1) : '0';
    
    return Row(
      children: [
        // 饼图
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.blue,
                  value: timeCards.toDouble(),
                  title: '$timePercentage%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.purple,
                  value: countCards.toDouble(),
                  title: '$countPercentage%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 图例
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(
                color: Colors.blue,
                title: '时间卡密',
                value: '$timeCards ($timePercentage%)',
              ),
              const SizedBox(height: 16),
              _buildLegendItem(
                color: Colors.purple,
                title: '次数卡密',
                value: '$countCards ($countPercentage%)',
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 构建图例项
  Widget _buildLegendItem({
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 构建卡密创建趋势折线图
  Widget _buildCardCreationTrendChart(Map<String, dynamic> data) {
    final trendData = data['trendData'] as Map<String, int>;
    final sortedDates = trendData.keys.toList()..sort();
    
    final List<FlSpot> spots = [];
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final count = trendData[date]!;
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }
    
    // 找出最大值以设置Y轴上限
    double maxY = 0;
    for (final count in trendData.values) {
      if (count > maxY) maxY = count.toDouble();
    }
    maxY = maxY < 10 ? 10 : (maxY * 1.2); // 让Y轴上限高于最大值
    
    // 日期格式化
    final dateFormat = DateFormat('MM-dd');
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY / 5,
          verticalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 5 == 0 && value.toInt() < sortedDates.length) {
                  final date = DateTime.parse(sortedDates[value.toInt()]);
                  return Text(
                    dateFormat.format(date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            left: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        minX: 0,
        maxX: sortedDates.length.toDouble() - 1,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                final date = sortedDates[index];
                final count = barSpot.y.toInt();
                
                return LineTooltipItem(
                  '$date: $count',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
  
  // 构建最近创建的卡密列表
  Widget _buildRecentCardsList(Map<String, dynamic> data) {
    final recentCards = data['recentCards'] as List<CardModel>;
    
    if (recentCards.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('暂无数据'),
        ),
      );
    }
    
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: recentCards.length,
        itemBuilder: (context, index) {
          final card = recentCards[index];
          
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: card.status == 0
                  ? Colors.green.withOpacity(0.2)
                  : (card.status == 1 ? Colors.orange.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
              child: Icon(
                card.status == 0
                    ? Icons.key
                    : (card.status == 1 ? Icons.check : Icons.block),
                color: card.status == 0
                    ? Colors.green
                    : (card.status == 1 ? Colors.orange : Colors.red),
                size: 20,
              ),
            ),
            title: Text(card.cardKey),
            subtitle: Text(
              '创建时间: ${card.createTimeFormatted}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: card.cardType == 'time' ? Colors.blue.shade100 : Colors.purple.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                card.cardTypeText,
                style: TextStyle(
                  color: card.cardType == 'time' ? Colors.blue.shade800 : Colors.purple.shade800,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () => _showCardDetailsDialog(context, card),
          );
        },
      ),
    );
  }

  // 添加多选相关的方法
  void _toggleCardSelection(int cardId) {
    setState(() {
      if (_selectedCardIds.contains(cardId)) {
        _selectedCardIds.remove(cardId);
      } else {
        _selectedCardIds.add(cardId);
      }
    });
  }
  
  // 全选功能
  void _selectAllCards() {
    setState(() {
      if (_selectedCardIds.length == _cardController.cards.length) {
        // 如果已经全选，则取消全选
        _selectedCardIds.clear();
      } else {
        // 否则全选当前页的卡密
        _selectedCardIds.clear();
        for (final card in _cardController.cards) {
          _selectedCardIds.add(card.id);
        }
      }
    });
  }
  
  void _cancelMultiSelect() {
    setState(() {
      _selectedCardIds.clear();
    });
  }

  // 批量更新卡密状态
  Future<void> _batchUpdateStatus(int newStatus) async {
    try {
      for (final cardId in _selectedCardIds) {
        await _cardController.updateCardStatus(cardId, newStatus);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('成功更新 ${_selectedCardIds.length} 张卡密的状态'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 清除选择
      _cancelMultiSelect();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('批量更新失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 批量删除卡密
  Future<void> _batchDeleteCards() async {
    try {
      // 显示删除进度对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 16),
              const Text('正在删除卡密'),
            ],
          ),
          content: SizedBox(
            height: 100,
            child: Center(
              child: Text('正在删除 ${_selectedCardIds.length} 张卡密，请稍候...'),
            ),
          ),
        ),
      );
      
      // 保存ScaffoldMessenger，防止异步操作后context失效
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      
      // 记录成功和失败的数量
      int successCount = 0;
      int failCount = 0;
      
      // 逐个删除卡密
      for (final cardId in _selectedCardIds) {
        final success = await _cardController.deleteCard(cardId);
        if (success) {
          successCount++;
        } else {
          failCount++;
        }
      }
      
      // 关闭进度对话框
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // 显示结果
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('删除完成: 成功 $successCount 张，失败 $failCount 张'),
          backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
        ),
      );
      
      // 清除选择
      _cancelMultiSelect();
      
    } catch (e) {
      // 关闭进度对话框
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('批量删除失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // 显示批量删除确认对话框
  void _showBatchDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.red),
            const SizedBox(width: 8),
            const Text('确认批量删除'),
          ],
        ),
        content: Text(
          '确定要删除这 ${_selectedCardIds.length} 张卡密吗？\n此操作不可恢复，所有选中的卡密将被永久删除。',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text('确认删除'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _batchDeleteCards();
            },
          ),
        ],
      ),
    );
  }
  
  // 显示批量操作对话框
  void _showBatchOperationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit, color: Colors.blue),
            const SizedBox(width: 8),
            Text('批量管理 (${_selectedCardIds.length}张卡密)'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 状态更新操作
            const Text(
              '修改卡密状态:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.new_releases, color: Colors.green),
              title: const Text('设为未使用'),
              onTap: () {
                Navigator.pop(context);
                _batchUpdateStatus(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.orange),
              title: const Text('设为已使用'),
              onTap: () {
                Navigator.pop(context);
                _batchUpdateStatus(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('设为已停用'),
              onTap: () {
                Navigator.pop(context);
                _batchUpdateStatus(2);
              },
            ),
            
            const Divider(),
            
            // 删除操作
            const Text(
              '危险操作:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('批量删除卡密'),
              subtitle: const Text('此操作不可恢复'),
              onTap: () {
                Navigator.pop(context);
                _showBatchDeleteConfirmDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  // 批量更新API密钥状态确认对话框
  void _showBatchUpdateApiKeyStatusConfirmDialog(bool isEnable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isEnable ? Icons.check_circle : Icons.block,
              color: isEnable ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(isEnable ? '批量启用接口' : '批量禁用接口'),
          ],
        ),
        content: Text(
          isEnable 
              ? '确定要启用所有API接口吗？这将允许所有API密钥进行验证操作。'
              : '确定要禁用所有API接口吗？这将阻止所有API密钥进行验证操作，可能会影响您的客户端应用。',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton.icon(
            icon: Icon(isEnable ? Icons.check_circle : Icons.block),
            label: Text(isEnable ? '确认启用' : '确认禁用'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnable ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _batchUpdateApiKeyStatus(isEnable);
            },
          ),
        ],
      ),
    );
  }
  
  // 批量更新API密钥状态
  Future<void> _batchUpdateApiKeyStatus(bool isActive) async {
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 16),
            Text(isActive ? '正在启用所有接口' : '正在禁用所有接口'),
          ],
        ),
        content: const SizedBox(
          height: 80,
          child: Center(
            child: Text('请稍候...'),
          ),
        ),
      ),
    );
    
    // 保存ScaffoldMessenger，防止异步操作后context失效
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final db = DatabaseConnection();
      if (db.connection == null) {
        throw Exception('数据库未连接');
      }
      
      // 更新所有API密钥的状态
      await db.connection!.query(
        'UPDATE api_keys SET status = ?',
        [isActive ? 1 : 0],
      );
      
      // 关闭加载对话框
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // 刷新页面
      setState(() {});
      
      // 显示成功消息
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('已成功${isActive ? '启用' : '禁用'}所有API接口'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // 关闭加载对话框
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // 显示错误消息
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('操作失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 