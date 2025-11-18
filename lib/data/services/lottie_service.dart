import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmodo/data/models/purchasable_lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LottieService {
  static final LottieService _instance = LottieService._internal();
  factory LottieService() => _instance;
  LottieService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _selectedLottieKey = 'selected_lottie_id';
  static const String _defaultLottieAssetPath = 'assets/lottie/timer_lottie.json';

  Future<List<PurchasableLottie>> getUserLotties() async {
    final uid = _auth.currentUser?.uid;
    
    if (uid == null) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('purchased_lotties')
          .get();

      
      final lotties = snapshot.docs.map((doc) {
        return PurchasableLottie.fromFirestore(doc);
      }).toList();
          
      return lotties;
    } catch (e) {
      return [];
    }
  }

  Future<bool> userOwnsLottie(String lottieId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('purchased_lotties')
          .doc(lottieId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }


  Future<void> purchaseLottie(PurchasableLottie lottie) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('purchased_lotties')
          .doc(lottie.id)
          .set({
        'id': lottie.id,
        'name': lottie.name,
        'assetPath': lottie.assetPath,
        'price': lottie.price,
        'purchasedAt': FieldValue.serverTimestamp(),
        'purchaseMethod': 'free', // Şimdilik ücretsiz
      });

      // İlk satın alınan lottie ise, onu seçili yap
      final ownedLotties = await getUserLotties();
      if (ownedLotties.length == 1) {
        await selectLottie(lottie.id, lottie.assetPath);
      }
    } catch (e) {
      throw Exception('Purchase failed: $e');
    }
  }

  // TODO: İleride in-app purchase için bu metod kullanılacak
  // Future<void> purchaseLottieWithIAP(PurchasableLottie lottie, String purchaseToken) async {
  //   // In-app purchase verification
  //   // Firebase'e kaydetme
  // }

  // Seçili lottie'yi ayarla (local storage)
  Future<void> selectLottie(String lottieId, String assetPath) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _auth.currentUser?.uid ?? 'guest';
    
    // Kullanıcıya ve cihaza özel key
    final key = '${uid}_$_selectedLottieKey';
    await prefs.setString(key, lottieId);
    await prefs.setString('${key}_path', assetPath);
  }

  // Seçili lottie'nin asset path'ini getir (cihazdan)
  Future<String> getSelectedLottieAssetPath() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _auth.currentUser?.uid ?? 'guest';
    
    final key = '${uid}_$_selectedLottieKey';
    final assetPath = prefs.getString('${key}_path');
    
    return assetPath ?? _defaultLottieAssetPath;
  }

  // Seçili lottie'nin ID'sini getir
  Future<String?> getSelectedLottieId() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _auth.currentUser?.uid ?? 'guest';
    
    final key = '${uid}_$_selectedLottieKey';
    return prefs.getString(key);
  }

  // Default lottie path
  String get defaultLottieAssetPath => _defaultLottieAssetPath;

  // Lottie'yi sıfırla (default'a dön)
  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _auth.currentUser?.uid ?? 'guest';
    
    final key = '${uid}_$_selectedLottieKey';
    await prefs.remove(key);
    await prefs.remove('${key}_path');
  }
}

