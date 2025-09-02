import 'package:farmodo/data/services/sample_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GamificationTestPage extends StatefulWidget {
  const GamificationTestPage({super.key});

  @override
  State<GamificationTestPage> createState() => _GamificationTestPageState();
}

class _GamificationTestPageState extends State<GamificationTestPage> {
  final SampleDataService _sampleDataService = SampleDataService();
  bool _isLoading = false;
  String _statusMessage = 'Hazır';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamification Test'),
        backgroundColor: Colors.blue,
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
              onPressed: _isLoading ? null : _clearSampleData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Örnek Verileri Temizle'),
            ),
            
            const Spacer(),
            
            const Text(
              'Bu sayfa Firestore\'da gamification verilerini test etmek için kullanılır.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
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

