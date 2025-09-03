import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/data/services/animal_service.dart';
import 'package:farmodo/data/services/gamification_service.dart';
import 'package:get/get.dart';

class FarmController extends GetxController {
  final AnimalService _animalService = AnimalService();
  final GamificationService _gamificationService = GamificationService();
  
  final RxList<FarmAnimal> animals = <FarmAnimal>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedAnimalId = ''.obs;
  
  final RxString feedingAnimalId = ''.obs;
  final RxString lovingAnimalId = ''.obs;
  final RxString playingAnimalId = ''.obs;
  final RxString healingAnimalId = ''.obs;
  final Rx<DateTime> lastStatusUpdate = DateTime.now().obs;


  @override
  void onInit() {
    super.onInit();
    loadAnimals();
  }

  Future<void> loadAnimals() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final userAnimals = await _animalService.getUserAnimals();
      animals.assignAll(userAnimals);
    } catch (e) {
      errorMessage.value = 'Hayvanlar yüklenirken hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncPurchasedAnimalsToFarm() async {
    try {
      await loadAnimals();
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }


  // Hayvanı besle
  Future<void> feedAnimal(String animalId) async {
    feedingAnimalId.value = animalId;
    errorMessage.value = '';
    try {
      await _animalService.feedAnimal(animalId);
      await loadAnimals();
      await _gamificationService.triggerCareAction('feedAnimals', animalId: animalId);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      feedingAnimalId.value = '';
    }
  }

  // Hayvana sevgi göster
  Future<void> loveAnimal(String animalId) async {
    errorMessage.value = '';
    lovingAnimalId.value = animalId;
    
    try {
      await _animalService.loveAnimal(animalId);
      await loadAnimals();
      await _gamificationService.triggerCareAction('loveAnimals', animalId: animalId);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      lovingAnimalId.value = '';
    }
  }

  // Hayvanla oyna
  Future<void> playWithAnimal(String animalId) async {
    errorMessage.value = '';
    playingAnimalId.value = animalId;
    
    try {
      await _animalService.playWithAnimal(animalId);
      await loadAnimals();
      await _gamificationService.triggerCareAction('playWithAnimals', animalId: animalId);

    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      playingAnimalId.value = '';
    }
  }

  // Hayvanı iyileştir
  Future<void> healAnimal(String animalId) async {
    errorMessage.value = '';
    healingAnimalId.value = animalId;
    
    try {
      await _animalService.healAnimal(animalId);
      await loadAnimals(); // Hayvanları yeniden yükle
      await _gamificationService.triggerCareAction('healAnimals', animalId: animalId);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      healingAnimalId.value = '';
    }
  }

  Future<void> updateAnimalNickname(String animalId, String nickname) async {
    try {
      await _animalService.updateAnimalNickname(animalId, nickname);
      await loadAnimals();
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }


  Future<void> toggleAnimalFavorite(String animalId) async {
    errorMessage.value = '';
    try {
      await _animalService.toggleAnimalFavorite(animalId);
      await loadAnimals();
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> addAnimalExperience(String animalId, int experience) async {
    errorMessage.value = '';
    try {
      await _animalService.addAnimalExperience(animalId, experience);
      await loadAnimals();
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  // Hayvanı sil
  Future<void> deleteAnimal(String animalId) async {
    errorMessage.value = '';
    try {
      await _animalService.deleteAnimal(animalId);
      await loadAnimals(); // Hayvanları yeniden yükle
      
      // Get.snackbar(
      //   'Başarılı!',
      //   'Hayvan silindi!',
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  // Zamanla hayvan durumlarını güncelle
  Future<void> updateAnimalStatusesOverTime() async {
    try {
      await _animalService.updateAnimalStatusesOverTime();
      await loadAnimals(); // Hayvanları yeniden yükle
      lastStatusUpdate.value = DateTime.now();
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  // Seçili hayvanı getir
  FarmAnimal? getSelectedAnimal() {
    if (selectedAnimalId.value.isEmpty) return null;
    try {
      return animals.firstWhere((animal) => animal.id == selectedAnimalId.value);
    } catch (e) {
      return null;
    }
  }

  // Favori hayvanları getir
  List<FarmAnimal> get favoriteAnimals {
    return animals.where((animal) => animal.isFavorite).toList();
  }

  // Aç hayvanları getir
  List<FarmAnimal> get hungryAnimals {
    return animals.where((animal) => animal.status.isHungry).toList();
  }

  // Sevgiye ihtiyacı olan hayvanları getir
  List<FarmAnimal> get animalsNeedingLove {
    return animals.where((animal) => animal.status.needsLove).toList();
  }

  // Yorgun hayvanları getir
  List<FarmAnimal> get tiredAnimals {
    return animals.where((animal) => animal.status.isTired).toList();
  }

  // Hasta hayvanları getir
  List<FarmAnimal> get sickAnimals {
    return animals.where((animal) => animal.status.isSick).toList();
  }

  // Mutlu hayvanları getir
  List<FarmAnimal> get happyAnimals {
    return animals.where((animal) => animal.status.isHappy).toList();
  }

  // Hayvan sayısı
  int get totalAnimals => animals.length;
  int get totalFavorites => favoriteAnimals.length;
  int get totalHungry => hungryAnimals.length;
  int get totalNeedingLove => animalsNeedingLove.length;
  int get totalTired => tiredAnimals.length;
  int get totalSick => sickAnimals.length;
  int get totalHappy => happyAnimals.length;

  // Son güncelleme zamanını formatla
  String get lastUpdateTimeString {
    final now = DateTime.now();
    final difference = now.difference(lastStatusUpdate.value);
    
    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }
}
