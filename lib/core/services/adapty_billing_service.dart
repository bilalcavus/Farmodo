import 'dart:async';
import 'dart:io';

import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:collection/collection.dart';
import 'package:farmodo/data/models/purchasable_lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdaptyBillingService {
  static const String _100_coin = "pomodoro_100_coins";
  static const String _500_coin = "pomodoro_500_coins";
  static const String _2000_coin = "pomodoro_2000_coins";
  static const String _5000_coin = "pomodoro_5000_coins";
  static const String _lottie_small_pack = "pomodoro_lottie_small_pack";
  static const String _lottie_medium_pack = "pomodoro_lottie_medium_pack";
  static const String _lottie_advanced_pack = "pomodoro_lottie_advanced_pack";
  static const String coinPlacementId = 'consumable_coins';
  static const String lottiePackPlacementId = 'pro_animation';
  
  // Development mode: true iken gerçek satın alma yapmaz, sadece simüle eder
  // Store'lara ürünler eklendikten sonra false yapın

  AdaptyProfile? _profile;
  bool _isAvailable = false;
  StreamSubscription<AdaptyProfile>? _profileSubscription;
  StreamSubscription<User?>? _authSubscription;
  String? _currentAdaptyUserId;

  bool get isAvailable => _isAvailable;
  AdaptyProfile? get profile => _profile;

  Function(AdaptyProfile)? onProfileUpdate;

  Future<void> initialize() async {
    try {
      debugPrint('Initializing Adapty Billing...');
      debugPrint('Platform: ${Platform.operatingSystem}');

      if(Platform.isAndroid || Platform.isIOS){
        _isAvailable = true;

        // Sync Adapty profile with the current Firebase user so purchases are not shared across accounts
        _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
          (user) => _syncAdaptyUser(user),
        );
        await _syncAdaptyUser(FirebaseAuth.instance.currentUser);

        debugPrint('Loading Adapty profile...');
        
        try {
          if (_profile == null) {
            await _loadProfile();
          }
          if (_profile != null) {
            debugPrint('Profile loaded successfully: ${_profile!.profileId}');
          } else {
            debugPrint('Warning: Profile is null after loading');
          }
        } catch (e) {
           debugPrint('Warning: Could not load profile during initialization: $e');
          // Profile yüklenemese bile devam et
        }

        // Set up purchase update listener
        _setupPurchaseUpdateListener();
        _isAvailable = true;
        debugPrint('Adapty billing initialization completed successfully');
        debugPrint('isAvailable: $_isAvailable');
      } else {
         debugPrint('Unsupported platform for in-app purchases: ${Platform.operatingSystem}');
        _isAvailable = false;
      }
    } catch (e, stackTrace) {
       debugPrint('Error initializing Adapty Billing: $e');
      debugPrint('Stack trace: $stackTrace');
      _isAvailable = false;
    }
  }

  Future<void> _syncAdaptyUser(User? user) async {
    if (!_isAvailable) return;

    final newUserId = user?.uid;
    if (newUserId == _currentAdaptyUserId && _profile != null) {
      return;
    }

    try {
      if (newUserId != null) {
        await Adapty().identify(newUserId);
        debugPrint('Adapty identify called with Firebase uid: $newUserId');
      } else {
        await Adapty().logout();
        debugPrint('Adapty profile logged out (no Firebase user)');
      }

      await _loadProfile();
      _currentAdaptyUserId = newUserId;

      if (_profile != null && onProfileUpdate != null) {
        onProfileUpdate!(_profile!);
      }
    } catch (e) {
      debugPrint('Error syncing Adapty user: $e');
    }
  }

  /// Purchase update listener'ı ayarla
  void _setupPurchaseUpdateListener() {
    try {
      // Adapty'nin otomatik purchase update'lerini dinle
      debugPrint('Setting up Adapty purchase update listener');
      
      // Profile değişikliklerini dinle
      _profileSubscription = Adapty().didUpdateProfileStream.listen((profile) {
        debugPrint('Adapty profile updated: ${profile.profileId}');
        _profile = profile;
        
        // Callback'i çağır (SubscriptionProvider Firebase'i güncelleyecek)
        if (onProfileUpdate != null) {
          debugPrint('Calling onProfileUpdate callback');
          onProfileUpdate!(profile);
        }
      });
      
      debugPrint('Profile update listener set up successfully');
    } catch (e) {
      debugPrint('Error setting up purchase update listener: $e');
    }
  }

  Future<void> _loadProfile() async {
    try {
      _profile = await Adapty().getProfile();
      debugPrint('Adapty profile loaded: ${_profile?.profileId}');
    } catch (e) {
      debugPrint('Error loading Adapty profile: $e');
      _profile = null;
    }
  }

  bool _isCancelledError(Object e) {
    final text = e.toString().toLowerCase();
    return text.contains('user canceled') ||
        text.contains('user cancelled') ||
        text.contains('purchase cancelled') ||
        text.contains('purchase canceled') ||
        text.contains('cancelled') ||
        text.contains('canceled') ||
        // Play Store billing response codes for cancellation often surface as strings
        text.contains('responsecode=1') || // BillingResponseCode.USER_CANCELED
        text.contains('responsecode=5') || // Developer error often emitted when user closes dialog without a signature in tests
        text.contains('response code 1') ||
        text.contains('response code 5');
  }

  Future<Map<String, dynamic>> purchaseCoins(
    int coinAmount, {
    String? productIdOverride,
  }) async {
    try {
      
      if(!_isAvailable){
        debugPrint('Adapty not available. Aborting Coin purchase.');
        return {'success': false, 'error': 'Adapty not available'};
      }

      final paywall = await _getCoinPaywallWithFallback();
      if(paywall == null){
        debugPrint('Coin paywall not found (tried: consumable_coin, credits, coins)');
        return {'success': false, 'error': 'Paywall not found'};
      }

      String productId;
      
      if (productIdOverride != null && productIdOverride.isNotEmpty) {
        productId = productIdOverride;
      } else {
        switch(coinAmount){
          case 100: productId = _100_coin; break;
          case 500: productId = _500_coin; break;
          case 2000: productId = _2000_coin; break;
          case 5000: productId = _5000_coin; break;
          default:
          debugPrint('Invalid Coin amount: $coinAmount');
            return {'success': false, 'error': 'Invalid Coin amount'};
        }
      }

      // Paywall için ürünleri al
      final products = await Adapty().getPaywallProducts(paywall: paywall);
      if (products.isEmpty) {
        debugPrint('No products found in paywall');
        return {'success': false, 'error': 'No products in paywall'};
      }

      //Coini bul
      AdaptyPaywallProduct? coinProduct;
      try {
        coinProduct = products.firstWhere((p) => p.vendorProductId == productId);
      } catch (e) {
        debugPrint('Coin product not found: $productId');
        debugPrint('Available products: ${products.map((p) => p.vendorProductId).join(", ")}');
        return {'success': false, 'error': 'Coin product not found: $productId'};
      }

        // Adapty ile satın alma
      debugPrint('Attempting to purchase $coinAmount Coin via Adapty...');
      debugPrint('Product: ${coinProduct.vendorProductId}');
      
      final purchaseResult = await Adapty().makePurchase(product: coinProduct);

      if (purchaseResult is AdaptyPurchaseResultUserCancelled) {
        debugPrint('Coin purchase cancelled by user');
        return {'success': false, 'error': 'purchase_cancelled'};
      }

      if (purchaseResult is AdaptyPurchaseResultPending) {
        debugPrint('Coin purchase is pending, not granting yet');
        return {'success': false, 'error': 'purchase_pending'};
      }

      if (purchaseResult is! AdaptyPurchaseResultSuccess) {
        debugPrint(
            'Unexpected Adapty purchase result: ${purchaseResult.runtimeType}');
        return {'success': false, 'error': 'Unexpected purchase result'};
      }

      _profile = purchaseResult.profile;

      // Refresh profile from backend to be sure purchase is recorded
      await _loadProfile();

      final activeProfile = _profile ?? purchaseResult.profile;

      final isRecordedInProfile = activeProfile?.nonSubscriptions.entries
              .firstWhereOrNull(
                  (entry) => entry.key == coinProduct?.vendorProductId)
              ?.value
              .firstWhereOrNull(
                (purchase) =>
                    purchase.vendorProductId ==
                        coinProduct?.vendorProductId &&
                    purchase.isRefund != true,
              ) !=
          null;

      if (!isRecordedInProfile) {
        debugPrint(
            'Adapty profile does not contain purchase for ${coinProduct.vendorProductId} (possible cancellation)');
        return {
          'success': false,
          'error': 'purchase_not_confirmed',
        };
      }

      debugPrint('Coin purchase completed');
      debugPrint('Profile ID: ${_profile?.profileId}');

      return {'success': true, 'profile': _profile, 'coins': coinProduct};
    } catch (e) {
      if (_isCancelledError(e)) {
        return {'success': false, 'error': 'purchase_cancelled'};
      }
      debugPrint('Error purchasing coin: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  String _resolveLottieProductId(
    LottiePackType packType, {
    String? productIdOverride,
  }) {
    if (productIdOverride != null && productIdOverride.isNotEmpty) {
      return productIdOverride;
    }

    switch (packType) {
      case LottiePackType.small:
        return _lottie_small_pack;
      case LottiePackType.medium:
        return _lottie_medium_pack;
      case LottiePackType.advanced:
        return _lottie_advanced_pack;
      case LottiePackType.unknown:
        return _lottie_small_pack;
    }
  }

  String lottieDefaultProductId(LottiePackType packType) {
    return _resolveLottieProductId(packType);
  }

  Future<Map<String, dynamic>> purchaseLottiePack(
    LottiePackType packType, {
    String? productIdOverride,
  }) async {
    try {
      if (!_isAvailable) {
        debugPrint('Adapty not available. Aborting lottie purchase.');
        return {'success': false, 'error': 'Adapty not available'};
      }

      final paywall = await getPaywall(lottiePackPlacementId);
      if (paywall == null) {
        return {'success': false, 'error': 'Paywall not found'};
      }

      final products = await Adapty().getPaywallProducts(paywall: paywall);
      if (products.isEmpty) {
        debugPrint('No products found in lottie paywall');
        return {'success': false, 'error': 'No products in paywall'};
      }

      final desiredProductId = _resolveLottieProductId(
        packType,
        productIdOverride: productIdOverride,
      );
      AdaptyPaywallProduct? packProduct;
      try {
        packProduct =
            products.firstWhere((p) => p.vendorProductId == desiredProductId);
      } catch (_) {
        debugPrint(
            'Lottie product not found. Wanted: $desiredProductId, Available: ${products.map((p) => p.vendorProductId).join(", ")}');
        return {
          'success': false,
          'error': 'Product not found: $desiredProductId'
        };
      }

      debugPrint(
          'Attempting to purchase lottie pack: ${packProduct.vendorProductId}');
      await Adapty().makePurchase(product: packProduct);
      await _loadProfile();

      final isRecordedInProfile = _profile?.nonSubscriptions.entries
              .firstWhereOrNull(
                  (entry) => entry.key == packProduct?.vendorProductId)
              ?.value
              .firstWhereOrNull(
                (purchase) =>
                    purchase.vendorProductId == packProduct?.vendorProductId &&
                    purchase.isRefund != true,
              ) !=
          null;

      if (!isRecordedInProfile) {
        debugPrint(
            'Adapty profile does not contain purchase for ${packProduct.vendorProductId}');
        return {
          'success': false,
          'error': 'Purchase not confirmed by App Store/Play Store',
        };
      }

      debugPrint('Lottie pack purchase completed: ${packType.readableName}');

      return {'success': true, 'profile': _profile, 'product': packProduct};
    } catch (e) {
      if (_isCancelledError(e)) {
        return {'success': false, 'error': 'purchase_cancelled'};
      }
      debugPrint('Error purchasing lottie pack: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> restorePurchases() async {
    try {
      if (!_isAvailable) {
        debugPrint('Adapty not available. Skipping restorePurchases.');
        return;
      }
      debugPrint('Restoring purchases...');
      await Adapty().restorePurchases();
      // Reload profile after restore
      await _loadProfile();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }
  

  Future<AdaptyPaywall?> getPaywall(String placementId) async {
    try {
      final paywall = await Adapty().getPaywall(placementId: placementId);
      debugPrint('Paywall found for placement: $placementId');
      return paywall;
    } catch (e) {
      debugPrint('Error getting paywall $placementId: $e');
      debugPrint('Make sure placement "$placementId" is created in Adapty Dashboard');
      return null;
    }
  }

  /// Paywall'ı göster (Custom UI kullanarak)
  /// Not: Bu metod paywall bilgilerini döndürür, UI tarafında gösterilmelidir
  Future<AdaptyPaywall?> showPaywall(String placementId) async {
    try {
      if (!_isAvailable) {
        debugPrint('Adapty not available. Cannot show paywall.');
        return null;
      }
      
      final paywall = await getPaywall(placementId);
      if (paywall == null) {
        debugPrint('Paywall not found: $placementId');
        return null;
      }
      
      debugPrint('Paywall retrieved: $placementId');
      try {
        final products = await Adapty().getPaywallProducts(paywall: paywall);
        debugPrint('Products in paywall: ${products.length}');
      } catch (e) {
        debugPrint('Could not load products: $e');
      }
      
      return paywall;
    } catch (e) {
      debugPrint('Error showing paywall: $e');
      return null;
    }
  }

  // Paywall bilgilerini ve products'ı birlikte al
  Future<Map<String, dynamic>?> getPaywallWithProducts(String placementId) async {
    try {
      final paywall = await getPaywall(placementId);
      if (paywall == null) return null;
      
      final products = await Adapty().getPaywallProducts(paywall: paywall);
      
      return {
        'paywall': paywall,
        'products': products,
      };
    } catch (e) {
      debugPrint('Error getting paywall with products: $e');
      return null;
    }
  }

  Future<AdaptyPaywall?> _getCoinPaywallWithFallback() async {
    const fallbacks = [
      coinPlacementId,
      'credits', // legacy
      'coins',   // alternative naming
    ];
    for (final id in fallbacks) {
      final paywall = await getPaywall(id);
      if (paywall != null) {
        return paywall;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getCoinPaywallWithProducts() async {
    const fallbacks = [
      coinPlacementId,
      'credits',
      'coins',
    ];
    for (final id in fallbacks) {
      final data = await getPaywallWithProducts(id);
      if (data != null) return data;
    }
    return null;
  }

  String? getLocalizedPriceForProduct({
    required List<AdaptyPaywallProduct> products,
    required String productId,
  }) {
    try {
      final product = products.firstWhere((p) => p.vendorProductId == productId);
      return product.price.localizedString;
    } catch (_) {
      return null;
    }
  }

  /// Kredi paywall'ını göster
  Future<void> showCreditsPaywall() async {
    await showPaywall('credits');
  }

  void dispose() {
    _profileSubscription?.cancel();
    _authSubscription?.cancel();
  }
}
