import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmodo/data/models/lottie_pack.dart';
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
  static const String _selectedPackKey = 'selected_lottie_pack';
  static const String _defaultLottieAssetPath = 'assets/lottie/timer_lottie.json';

  Future<List<PurchasableLottie>> _fetchPurchasableLotties({
    LottiePackType? type,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('purchasable_lotties')
        .where('isAvailable', isEqualTo: true);

    if (type != null && type != LottiePackType.unknown) {
      query = query.where('type', isEqualTo: lottiePackTypeToString(type));
    }

    final snapshot = await query.get();
    return snapshot.docs.map(PurchasableLottie.fromFirestore).toList();
  }

  Future<List<PurchasableLottie>> getLottiesForPack(LottiePackType type) async {
    return _fetchPurchasableLotties(type: type);
  }

  Future<List<LottiePack>> fetchAvailablePacks() async {
    final lotties = await _fetchPurchasableLotties();
    final Map<LottiePackType, List<PurchasableLottie>> grouped = {};

    for (final lottie in lotties) {
      final packType = lottie.packType;
      if (packType == LottiePackType.unknown) continue;
      grouped.putIfAbsent(packType, () => []).add(lottie);
    }

    return grouped.entries.map((entry) {
      final lottiesInPack = entry.value;
      final preview = lottiesInPack.isNotEmpty ? lottiesInPack.first : null;

      return LottiePack(
        type: entry.key,
        name: entry.key.readableName,
        description: '${lottiesInPack.length} animation',
        price: preview?.price ?? 0,
        lotties: lottiesInPack,
        productId: preview?.productId,
      );
    }).toList();
  }

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

      final lotties = snapshot.docs.map(PurchasableLottie.fromFirestore).toList();
      final ownedPackTypes = await getOwnedPackTypes();

      if (ownedPackTypes.isEmpty) {
        return lotties;
      }

      final packLotties = await Future.wait(
        ownedPackTypes.map(getLottiesForPack),
      );

      final Map<String, PurchasableLottie> merged = {
        for (final lottie in lotties) lottie.id: lottie,
      };

      for (final pack in packLotties) {
        for (final lottie in pack) {
          merged[lottie.id] = lottie;
        }
      }

      return merged.values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<Set<LottiePackType>> getOwnedPackTypes() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {};

    try {
      final packSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('purchased_lottie_packs')
          .get();

      final ownedTypes = packSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return lottiePackTypeFromString(data['type'] ?? doc.id);
          })
          .where((type) => type != LottiePackType.unknown)
          .toSet();

      if (ownedTypes.isNotEmpty) return ownedTypes;

      // Fallback: eski verilerden tip çıkar
      final lottieSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('purchased_lotties')
          .get();

      final fallbackTypes = lottieSnapshot.docs
          .map((doc) {
            final data = doc.data();
            return lottiePackTypeFromString(data['type']);
          })
          .where((type) => type != LottiePackType.unknown)
          .toSet();

      return fallbackTypes;
    } catch (e) {
      return {};
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

  Future<void> purchaseLottie(
    PurchasableLottie lottie, {
    String purchaseMethod = 'free',
  }) async {
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
        'type': lottie.type,
        'purchasedAt': FieldValue.serverTimestamp(),
        'purchaseMethod': purchaseMethod,
      }, SetOptions(merge: true));

      final ownedLotties = await getUserLotties();
      if (ownedLotties.length == 1) {
        await selectLottie(lottie.id, lottie.assetPath);
      }
    } catch (e) {
      throw Exception('Purchase failed: $e');
    }
  }

  Future<void> registerPackPurchase({
    required LottiePack pack,
    String purchaseMethod = 'iap',
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(uid);
    final packRef = userRef
        .collection('purchased_lottie_packs')
        .doc(lottiePackTypeToString(pack.type));

    batch.set(packRef, {
      'type': lottiePackTypeToString(pack.type),
      'name': pack.name,
      'productId': pack.productId,
      'purchaseMethod': purchaseMethod,
      'purchasedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final purchasedLottiesRef = userRef.collection('purchased_lotties');
    for (final lottie in pack.lotties) {
      final docRef = purchasedLottiesRef.doc(lottie.id);
      batch.set(docRef, {
        'id': lottie.id,
        'name': lottie.name,
        'assetPath': lottie.assetPath,
        'price': lottie.price,
        'type': lottie.type,
        'purchaseMethod': purchaseMethod,
        'purchasedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();

    await selectPackType(pack.type);
    if (pack.lotties.isNotEmpty) {
      final first = pack.lotties.first;
      await selectLottie(first.id, first.assetPath);
    }
  }

  Future<void> selectPackType(LottiePackType type) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _auth.currentUser?.uid ?? 'guest';
    final key = '${uid}_$_selectedPackKey';
    await prefs.setString(key, lottiePackTypeToString(type));
  }

  Future<LottiePackType?> getSelectedPackType() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _auth.currentUser?.uid ?? 'guest';
    final key = '${uid}_$_selectedPackKey';
    final type = prefs.getString(key);
    final parsed = lottiePackTypeFromString(type);
    if (parsed == LottiePackType.unknown) return null;
    return parsed;
  }

  Future<void> selectLottie(String lottieId, String assetPath) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _auth.currentUser?.uid ?? 'guest';

    final key = '${uid}_$_selectedLottieKey';
    await prefs.setString(key, lottieId);
    await prefs.setString('${key}_path', assetPath);
  }

  Future<String> getSelectedLottieAssetPath() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _auth.currentUser?.uid ?? 'guest';

    final key = '${uid}_$_selectedLottieKey';
    final assetPath = prefs.getString('${key}_path');

    return assetPath ?? _defaultLottieAssetPath;
  }

  Future<String?> getSelectedLottieId() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _auth.currentUser?.uid ?? 'guest';

    final key = '${uid}_$_selectedLottieKey';
    return prefs.getString(key);
  }

  String get defaultLottieAssetPath => _defaultLottieAssetPath;

  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _auth.currentUser?.uid ?? 'guest';

    final key = '${uid}_$_selectedLottieKey';
    await prefs.remove(key);
    await prefs.remove('${key}_path');
    await prefs.remove('${uid}_$_selectedPackKey');
  }
  Future<void> syncWithAdapty(AdaptyProfile profile) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final profileUserId = profile.customerUserId;
    if (profileUserId != null && profileUserId != uid) {
      print(
        'Skipping Adapty sync: profile belongs to $profileUserId but current user is $uid',
      );
      return;
    }

    try {
      // Non-subscription purchases (Lottie packs)
      final nonSubscriptions = profile.nonSubscriptions;
      if (nonSubscriptions.isEmpty) return;

      final ownedPacks = await getOwnedPackTypes();
      
      for (final entry in nonSubscriptions.entries) {
        final productId = entry.key;
        final purchaseList = entry.value;
        
        // Check if purchase is active/valid
        // Filter out refunds if the property exists (assuming isRefund is available)
        final validPurchase = purchaseList.firstWhereOrNull((p) => 
          p.vendorProductId == productId && (p.isRefund == false)
        );
        
        if (validPurchase != null) {
           // Map productId to LottiePackType with STRICT matching
           LottiePackType? type;
           
           // Use exact IDs from AdaptyBillingService (hardcoded here to avoid circular dependency or extra lookup)
           if (productId == 'pomodoro_lottie_small_pack') type = LottiePackType.small;
           else if (productId == 'pomodoro_lottie_medium_pack') type = LottiePackType.medium;
           else if (productId == 'pomodoro_lottie_advanced_pack') type = LottiePackType.advanced;
           
           if (type != null && !ownedPacks.contains(type)) {
             // User has it in Adapty but not in Firestore -> Sync it
             print('Syncing Lottie pack from Adapty: $type');
             
             final availablePacks = await fetchAvailablePacks();
             final packToSync = availablePacks.firstWhereOrNull((p) => p.type == type);
             
             if (packToSync != null) {
               await registerPackPurchase(
                 pack: packToSync,
                 purchaseMethod: 'iap_sync',
               );
             }
           }
        }
      }
    } catch (e) {
      print('Sync error: $e');
    }
  }
}
