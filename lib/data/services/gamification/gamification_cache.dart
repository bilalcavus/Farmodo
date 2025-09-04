class CacheEntry<T> {
  final List<T> data;
  final DateTime fetchedAt;

  CacheEntry(this.data, this.fetchedAt);

  bool isValid(Duration ttl) {
    return DateTime.now().difference(fetchedAt) < ttl;
  }
}

class GamificationCache {
  final Duration defaultTtl;
  final Duration userTtl;

  GamificationCache({
    this.defaultTtl = const Duration(minutes: 5),
    this.userTtl = const Duration(minutes: 2),
  });

  final Map<String, CacheEntry> _cache = {};

  /// Genel cache set etme
  void set<T>(String key, List<T> data) {
    _cache[key] = CacheEntry<T>(data, DateTime.now());
  }

  /// Genel cache alma (TTL kontrolü ile)
  List<T>? get<T>(String key, {Duration? ttl}) {
    final entry = _cache[key] as CacheEntry<T>?;
    if (entry == null) return null;

    final effectiveTtl = ttl ?? defaultTtl;
    if (entry.isValid(effectiveTtl)) {
      return entry.data;
    } else {
      _cache.remove(key);
      return null;
    }
  }

  void clear(String key) {
    _cache.remove(key);
  }

  void clearAll() {
    _cache.clear();
  }
}
