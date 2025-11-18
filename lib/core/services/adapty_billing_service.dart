import 'dart:async';
import 'dart:io';

import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/material.dart';

class AdaptyBillingService {
  static const String _100_coin = "pomodoro_100_coins";
  static const String _500_coin = "pomodoro_500_coins";
  static const String _2000_coin = "pomodoro_2000_coins";
  static const String _5000_coin = "pomodoro_5000_coins";
  
  // Development mode: true iken gerçek satın alma yapmaz, sadece simüle eder
  // Store'lara ürünler eklendikten sonra false yapın
  static const bool isDevelopmentMode = true;

  AdaptyProfile? _profile;
  bool _isAvailable = false;
  StreamSubscription<AdaptyProfile>? _profileSubscription;

  bool get isAvailable => _isAvailable;
  AdaptyProfile? get profile => _profile;

  Function(AdaptyProfile)? onProfileUpdate;

  Future<void> initialize() async {
    try {
      debugPrint('Initializing Adapty Billing...');
      debugPrint('Platform: ${Platform.operatingSystem}');

      if(Platform.isAndroid || Platform.isIOS){
        debugPrint('Loading Adapty profile...');
        
        try {
          await _loadProfile();
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

  Future<Map<String, dynamic>> purchaseCoins(int coinAmount) async {
    try {
      // Development mode: Gerçek satın alma yapmadan simüle et
      if (isDevelopmentMode) {
        debugPrint('⚠️ DEVELOPMENT MODE: Simulating purchase of $coinAmount coins');
        debugPrint('⚠️ This is NOT a real purchase. Set isDevelopmentMode = false when ready.');
        
        // 2 saniye bekle (gerçekçi olsun)
        await Future.delayed(const Duration(seconds: 2));
        
        // Başarılı satın alma simülasyonu
        return {
          'success': true, 
          'profile': _profile, 
          'coins': coinAmount,
          'isDevelopment': true,
        };
      }
      
      if(!_isAvailable){
        debugPrint('Adapty not available. Aborting Coin purchase.');
        return {'success': false, 'error': 'Adapty not available'};
      }

      final paywall = await getPaywall('consumable_coins');
      if(paywall == null){
        debugPrint('Coin paywall not found');
        return {'success': false, 'error': 'Paywall not found'};
      }

      String productId;
      
      switch(coinAmount){
        case 100: productId = _100_coin; break;
        case 500: productId = _500_coin; break;
        case 2000: productId = _2000_coin; break;
        case 5000: productId = _5000_coin; break;
        default:
        debugPrint('Invalid Coin amount: $coinAmount');
          return {'success': false, 'error': 'Invalid Coin amount'};
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
      
      await Adapty().makePurchase(product: coinProduct);

      await _loadProfile();

      debugPrint('Coin purchase completed');
      debugPrint('Profile ID: ${_profile?.profileId}');

      return {'success': true, 'profile': _profile, 'coins': coinProduct};
    } catch (e) {
      debugPrint('Error purchasing coin: $e');
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

  /// Kredi paywall'ını göster
  Future<void> showCreditsPaywall() async {
    await showPaywall('credits');
  }

}