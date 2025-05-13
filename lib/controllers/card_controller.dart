import 'package:get/get.dart';
import 'package:xxgkamiexe/models/card_model.dart';
import 'package:xxgkamiexe/services/card_service.dart';

class CardController extends GetxController {
  static CardController get to => Get.find();
  
  final _cardService = CardService();
  
  RxList<CardModel> cards = <CardModel>[].obs;
  RxInt totalCount = 0.obs;
  RxInt currentPage = 0.obs;
  RxInt pageSize = 20.obs;
  RxBool isLoading = false.obs;
  RxString searchTerm = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadCards();
  }
  
  Future<void> loadCards() async {
    isLoading.value = true;
    try {
      final offset = currentPage.value * pageSize.value;
      final cardsData = await _cardService.getCards(
        limit: pageSize.value,
        offset: offset,
        searchTerm: searchTerm.value.isNotEmpty ? searchTerm.value : null,
      );
      
      cards.value = cardsData;
      totalCount.value = await _cardService.getCardCount(
        searchTerm: searchTerm.value.isNotEmpty ? searchTerm.value : null,
      );
    } catch (e) {
      print('加载卡密失败: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // 刷新卡密数据
  Future<void> refreshCards() async {
    await loadCards();
  }
  
  void nextPage() {
    final maxPage = (totalCount.value / pageSize.value).ceil() - 1;
    if (currentPage.value < maxPage) {
      currentPage.value++;
      loadCards();
    }
  }
  
  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      loadCards();
    }
  }
  
  void goToPage(int page) {
    if (page >= 0 && page < (totalCount.value / pageSize.value).ceil()) {
      currentPage.value = page;
      loadCards();
    }
  }
  
  void search(String term) {
    searchTerm.value = term;
    currentPage.value = 0;
    loadCards();
  }
  
  Future<bool> addCard({
    String? cardKey,
    required int duration,
    required String verifyMethod,
    required bool allowReverify,
    required String encryptionType,
    required String cardType,
    required int totalCount,
  }) async {
    try {
      final success = await _cardService.addCard(
        cardKey: cardKey,
        duration: duration,
        verifyMethod: verifyMethod,
        allowReverify: allowReverify,
        encryptionType: encryptionType,
        cardType: cardType,
        totalCount: totalCount,
      );
      
      if (success) {
        await loadCards();
      }
      
      return success;
    } catch (e) {
      print('添加卡密失败: $e');
      return false;
    }
  }
  
  Future<int> generateCards({
    required int count,
    required int duration,
    required String verifyMethod,
    required bool allowReverify,
    required String encryptionType,
    required String cardType,
    required int totalCount,
  }) async {
    try {
      final successCount = await _cardService.generateCards(
        count: count,
        duration: duration,
        verifyMethod: verifyMethod,
        allowReverify: allowReverify,
        encryptionType: encryptionType,
        cardType: cardType,
        totalCount: totalCount,
      );
      
      await loadCards();
      return successCount;
    } catch (e) {
      print('生成卡密失败: $e');
      return 0;
    }
  }
  
  Future<bool> updateCardStatus(int id, int status) async {
    try {
      final success = await _cardService.updateCardStatus(id, status);
      
      if (success) {
        await loadCards();
      }
      
      return success;
    } catch (e) {
      print('更新卡密状态失败: $e');
      return false;
    }
  }
  
  Future<bool> deleteCard(int id) async {
    try {
      final success = await _cardService.deleteCard(id);
      
      if (success) {
        await loadCards();
      }
      
      return success;
    } catch (e) {
      print('删除卡密失败: $e');
      return false;
    }
  }
  
  // 更新卡密设备绑定
  Future<bool> updateCardDeviceBinding(int id, String? deviceId) async {
    try {
      final success = await _cardService.updateCardDeviceBinding(id, deviceId);
      
      if (success) {
        await loadCards();
      }
      
      return success;
    } catch (e) {
      print('更新卡密设备绑定失败: $e');
      return false;
    }
  }
  
  // 延长卡密到期时间
  Future<bool> extendCardExpiration(int id, int daysToAdd) async {
    try {
      final success = await _cardService.extendCardExpiration(id, daysToAdd);
      
      if (success) {
        await loadCards();
      }
      
      return success;
    } catch (e) {
      print('延长卡密到期时间失败: $e');
      return false;
    }
  }
  
  // 更新卡密剩余次数
  Future<bool> updateCardRemainingCount(int id, int newRemainingCount) async {
    try {
      final success = await _cardService.updateCardRemainingCount(id, newRemainingCount);
      
      if (success) {
        await loadCards();
      }
      
      return success;
    } catch (e) {
      print('更新卡密剩余次数失败: $e');
      return false;
    }
  }
} 