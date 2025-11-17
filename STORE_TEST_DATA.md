# Store Test Data - Firestore Collection Setup

Bu dosya, store'da coin ve lottie'lerin görünebilmesi için Firestore'da test verileri oluşturmanız için bir rehberdir.

## 1. Firestore Console'a Giriş

1. Firebase Console'a gidin: https://console.firebase.google.com
2. Projenizi seçin
3. Sol menüden "Firestore Database" seçin

## 2. Purchasable Coins Collection Oluşturma

1. "Start collection" butonuna tıklayın
2. Collection ID: `purchasable_coins`
3. İlk dokümanı ekleyin:

```
Document ID: (Auto-ID)

Fields:
- id: (string) "coin_pack_1"
- name: (string) "Small Coin Pack"
- assetPath: (string) "assets/purchase_items/coin/coin_small.png"
- price: (number) 0.99
- description: (string) "100 coins"
- isAvailable: (boolean) true
- createdAt: (timestamp) [current timestamp]
```

### Örnek Coin Paketleri

**Küçük Paket:**
```
id: "coin_pack_small"
name: "Küçük Coin Paketi"
assetPath: "assets/purchase_items/coin/coin_small.png"
price: 0.99
description: "100 coin"
isAvailable: true
createdAt: [timestamp]
```

**Orta Paket:**
```
id: "coin_pack_medium"
name: "Orta Coin Paketi"
assetPath: "assets/purchase_items/coin/coin_medium.png"
price: 2.99
description: "500 coin"
isAvailable: true
createdAt: [timestamp]
```

**Büyük Paket:**
```
id: "coin_pack_large"
name: "Büyük Coin Paketi"
assetPath: "assets/purchase_items/coin/coin_large.png"
price: 4.99
description: "1000 coin"
isAvailable: true
createdAt: [timestamp]
```

## 3. Purchasable Lotties Collection Oluşturma

1. "Start collection" butonuna tıklayın
2. Collection ID: `purchasable_lotties`
3. İlk dokümanı ekleyin:

```
Document ID: (Auto-ID)

Fields:
- id: (string) "timer_style_1"
- name: (string) "Blue Timer"
- assetPath: (string) "assets/lottie/blue_loading.json"
- price: (number) 1.99
- description: (string) "Mavi zamanlayıcı animasyonu"
- isAvailable: (boolean) true
- createdAt: (timestamp) [current timestamp]
```

### Örnek Lottie Animasyonları

**Mavi Timer:**
```
id: "timer_blue"
name: "Mavi Zamanlayıcı"
assetPath: "assets/lottie/blue_loading.json"
price: 1.99
description: "Modern mavi zamanlayıcı animasyonu"
isAvailable: true
createdAt: [timestamp]
```

**Splash Animasyonu:**
```
id: "timer_splash"
name: "Splash Zamanlayıcı"
assetPath: "assets/lottie/splash_lottie.json"
price: 2.99
description: "Dinamik splash animasyonu"
isAvailable: true
createdAt: [timestamp]
```

**Timer Animasyonu:**
```
id: "timer_default"
name: "Klasik Zamanlayıcı"
assetPath: "assets/lottie/timer_lottie.json"
price: 1.49
description: "Klasik zamanlayıcı animasyonu"
isAvailable: true
createdAt: [timestamp]
```

## 4. Firestore Rules

Eğer okuma izni yoksa, Firestore Rules'a şunu ekleyin:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Purchasable items - herkes okuyabilir
    match /purchasable_coins/{coinId} {
      allow read: if true;
      allow write: if false; // Sadece admin ekleyebilir
    }
    
    match /purchasable_lotties/{lottieId} {
      allow read: if true;
      allow write: if false; // Sadece admin ekleyebilir
    }
  }
}
```

## 5. Konsol Loglarını Kontrol Etme

Uygulamayı çalıştırdıktan sonra konsol loglarında şunları göreceksiniz:

```
📦 Loading data for category: StoreCategory.coins
🔍 Fetched 3 items of type PurchasableCoin
✅ Assigned 3 items to targetList
💰 Coins loaded: 3
```

Eğer "⚠️ No items found" görüyorsanız, Firestore'da veri yok demektir.
Eğer "❌ Error fetching items" görüyorsanız, Firestore rules veya bağlantı sorunu var demektir.

## 6. Test Asset'lerinin Varlığını Kontrol

Kullandığınız asset path'lerinin gerçekten `assets/` klasöründe olduğundan emin olun.

Mevcut asset'ler:
- ✅ `assets/purchase_items/coin/` klasörü var
- ✅ `assets/lottie/blue_loading.json` var
- ✅ `assets/lottie/splash_lottie.json` var
- ✅ `assets/lottie/timer_lottie.json` var

## Sorun Giderme

### Veri gelmiyor
1. Firestore Console'da collection'ların olduğunu kontrol edin
2. Konsol loglarını kontrol edin
3. Firestore Rules'ı kontrol edin
4. İnternet bağlantısını kontrol edin

### Resim/Animasyon görünmüyor
1. Asset path'lerinin doğru olduğunu kontrol edin
2. `pubspec.yaml` dosyasında asset'lerin tanımlı olduğunu kontrol edin
3. Asset dosyalarının gerçekten var olduğunu kontrol edin

