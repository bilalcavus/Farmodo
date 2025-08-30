import 'package:get/get.dart';

class NavigationController extends GetxController {
  final currentIndex = 0.obs;
  final lastIndex = 0.obs; // Son ziyaret edilen indexi tutacak değişken

  // Başlangıçta lastIndex = 0 (Anasayfa)
  @override
  void onInit() {
    super.onInit();
    lastIndex.value = 0; // Başlangıçta ana sayfa
  }

  void changePage(int index) {
    if (index != currentIndex.value) {
      lastIndex.value = currentIndex.value; // Mevcut indexi lastIndex'e kaydet
      currentIndex.value = index; // Yeni indexi ayarla
    }
  }
  
  // Bir önceki sayfaya dönmek için
  void goBack() {
    // Eğer lastIndex geçerli bir değerse oraya git
    if (lastIndex.value >= 0 && lastIndex.value <= 5 && lastIndex.value != currentIndex.value) {
      currentIndex.value = lastIndex.value;
    } else {
      // Değilse ana sayfaya dön (0)
      currentIndex.value = 0;
    }
  }
}