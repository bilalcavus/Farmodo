import 'package:farmodo/data/services/sample_data_service.dart';
import 'package:farmodo/feature/gamification/viewmodel/gamification_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DebugGamificationView extends StatefulWidget {
  const DebugGamificationView({super.key});

  @override
  State<DebugGamificationView> createState() => _DebugGamificationViewState();
}

class _DebugGamificationViewState extends State<DebugGamificationView> {
  final SampleDataService _sampleDataService = SampleDataService();
  final GamificationController _gamificationController = Get.put(GamificationController());
  bool _isLoading = false;
  String _statusMessage = 'Hazır';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Gamification'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Durum: $_statusMessage',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Debug Info
            Obx(() => Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debug Bilgileri:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Başarılar: ${_gamificationController.achievements.length}'),
                    Text('Görevler: ${_gamificationController.quests.length}'),
                    Text('Kullanıcı Başarıları: ${_gamificationController.userAchievements.length}'),
                    Text('Kullanıcı Görevleri: ${_gamificationController.userQuests.length}'),
                    Text('Loading Başarılar: ${_gamificationController.isLoadingAchievements.value}'),
                    Text('Loading Görevler: ${_gamificationController.isLoadingQuests.value}'),
                  ],
                ),
              ),
            )),
            
            const SizedBox(height: 20),
            
            // Buttons
            ElevatedButton(
              onPressed: _isLoading ? null : _checkExistingData,
              child: const Text('Mevcut Verileri Kontrol Et'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadSampleAchievements,
              child: const Text('Örnek Başarıları Yükle'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadSampleQuests,
              child: const Text('Örnek Görevleri Yükle'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _uploadAllSampleData,
              child: const Text('Tüm Örnek Verileri Yükle'),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _refreshData,
              child: const Text('Verileri Yenile'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _printUserStats,
              child: const Text('Kullanıcı İstatistiklerini Göster'),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _clearSampleData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Örnek Verileri Temizle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkExistingData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Veriler kontrol ediliyor...';
    });

    try {
      await _sampleDataService.checkExistingData(FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        _statusMessage = 'Veriler kontrol edildi - Konsolu kontrol edin';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadSampleAchievements() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Başarılar yükleniyor...';
    });

    try {
      await _sampleDataService.uploadSampleAchievements();
      await _gamificationController.refreshGamification();
      setState(() {
        _statusMessage = 'Başarılar başarıyla yüklendi!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadSampleQuests() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Görevler yükleniyor...';
    });

    try {
      await _sampleDataService.uploadSampleQuests();
      await _gamificationController.refreshGamification();
      setState(() {
        _statusMessage = 'Görevler başarıyla yüklendi!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadAllSampleData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Tüm veriler yükleniyor...';
    });

    try {
      await _sampleDataService.uploadAllSampleData();
      await _gamificationController.refreshGamification();
      setState(() {
        _statusMessage = 'Tüm veriler başarıyla yüklendi!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Veriler yenileniyor...';
    });

    try {
      await _gamificationController.refreshGamification();
      setState(() {
        _statusMessage = 'Veriler yenilendi!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _printUserStats() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'İstatistikler kontrol ediliyor...';
    });

    try {
      // final gamificationService = GamificationService();
      // await gamificationService.printUserStats();
      setState(() {
        _statusMessage = 'İstatistikler konsola yazdırıldı!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearSampleData() async {
    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri Temizle'),
        content: const Text('Tüm örnek veriler silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Veriler temizleniyor...';
    });

    try {
      await _sampleDataService.clearSampleData();
      await _gamificationController.refreshGamification();
      setState(() {
        _statusMessage = 'Veriler başarıyla temizlendi!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
