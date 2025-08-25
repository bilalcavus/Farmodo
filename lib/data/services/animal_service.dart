import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmodo/data/models/animal_model.dart';
import 'package:farmodo/data/models/reward_model.dart';
import 'package:farmodo/data/services/gamification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AnimalService {
  static final AnimalService _instance = AnimalService._internal();
  factory AnimalService() => _instance;
  AnimalService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GamificationService _gamificationService = GamificationService();

  Future<List<FarmAnimal>> getUserAnimals() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animals')
          .get();

      return snapshot.docs.map((doc) => FarmAnimal.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> userOwnedAnimal(String rewardId) async {
    final uid = _auth.currentUser?.uid;
    if(uid == null) return false;
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animals')
          .where('rewardId', isEqualTo: rewardId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> addAnimalFromReward(Reward reward) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) throw Exception('User not found');
      
      final currentXp = (userDoc.data()?['xp'] as int?) ?? 0;
      if (currentXp < reward.xpCost) {
        throw Exception('Yetersiz XP. Gerekli: ${reward.xpCost}, Mevcut: $currentXp');
      }

      await _firestore.runTransaction((transaction) async {
        transaction.update(_firestore.collection('users').doc(uid), {
          'xp': FieldValue.increment(-reward.xpCost),
        });

        final animal = FarmAnimal.fromReward(
          userId: uid,
          rewardId: reward.id,
          name: reward.name,
          imageUrl: reward.imageUrl,
          description: reward.description,
        );

        transaction.set(
          _firestore
              .collection('users')
              .doc(uid)
              .collection('animals')
              .doc(animal.id),
          {
            'userId': animal.userId,
            'rewardId': animal.rewardId,
            'name': animal.name,
            'imageUrl': animal.imageUrl,
            'description': animal.description,
            'hunger': animal.status.hunger,
            'love': animal.status.love,
            'energy': animal.status.energy,
            'health': animal.status.health,
            'lastFed': Timestamp.fromDate(animal.status.lastFed),
            'lastLoved': Timestamp.fromDate(animal.status.lastLoved),
            'lastPlayed': Timestamp.fromDate(animal.status.lastPlayed),
            'acquiredAt': Timestamp.fromDate(animal.acquiredAt),
            'level': animal.level,
            'experience': animal.experience,
            'nickname': animal.nickname,
            'isFavorite': animal.isFavorite,
          }
        );
      });

      final updatedAnimals = await getUserAnimals();
      await _gamificationService.triggerAnimalCountChange(updatedAnimals.length);
      await _gamificationService.triggerAnimalPurchase(reward.id);
    } catch (e) {
      rethrow;
    }
  }


  Future<void> feedAnimal(String animalId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      final animalDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animals')
          .doc(animalId)
          .get();

      if (animalDoc.exists) {
        final animal = FarmAnimal.fromFirestore(animalDoc);
        final updatedAnimal = animal.feed();
        final levelGained = updatedAnimal.level - animal.level;
        
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('animals')
            .doc(animalId)
            .update({
              'hunger': updatedAnimal.status.hunger,
              'love': updatedAnimal.status.love,
              'energy': updatedAnimal.status.energy,
              'health': updatedAnimal.status.health,
              'lastFed': Timestamp.fromDate(updatedAnimal.status.lastFed),
              'lastLoved': Timestamp.fromDate(updatedAnimal.status.lastLoved),
              'lastPlayed': Timestamp.fromDate(updatedAnimal.status.lastPlayed),
              'experience': updatedAnimal.experience,
              'level': updatedAnimal.level,
            });
        if (levelGained > 0) {
          await _triggerLevelUpGamification(updatedAnimal.level);
        }
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<void> loveAnimal(String animalId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      final animalDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animals')
          .doc(animalId)
          .get();

      if (animalDoc.exists) {
        final animal = FarmAnimal.fromFirestore(animalDoc);
        final updatedAnimal = animal.love();
        final levelGained = updatedAnimal.level - animal.level;
        
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('animals')
            .doc(animalId)
            .update({
              'hunger': updatedAnimal.status.hunger,
              'love': updatedAnimal.status.love,
              'energy': updatedAnimal.status.energy,
              'health': updatedAnimal.status.health,
              'lastFed': Timestamp.fromDate(updatedAnimal.status.lastFed),
              'lastLoved': Timestamp.fromDate(updatedAnimal.status.lastLoved),
              'lastPlayed': Timestamp.fromDate(updatedAnimal.status.lastPlayed),
              'experience': updatedAnimal.experience,
              'level': updatedAnimal.level,
            });
            
        if (levelGained > 0) {
          await _gamificationService.triggerAnimalLevelUp(updatedAnimal.level);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> playWithAnimal(String animalId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      final animalDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animals')
          .doc(animalId)
          .get();

      if (animalDoc.exists) {
        final animal = FarmAnimal.fromFirestore(animalDoc);
        final updatedAnimal = animal.play();
        final levelGained = updatedAnimal.level - animal.level;
        
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('animals')
            .doc(animalId)
            .update({
              'hunger': updatedAnimal.status.hunger,
              'love': updatedAnimal.status.love,
              'energy': updatedAnimal.status.energy,
              'health': updatedAnimal.status.health,
              'lastFed': Timestamp.fromDate(updatedAnimal.status.lastFed),
              'lastLoved': Timestamp.fromDate(updatedAnimal.status.lastLoved),
              'lastPlayed': Timestamp.fromDate(updatedAnimal.status.lastPlayed),
              'experience': updatedAnimal.experience,
              'level': updatedAnimal.level,
            });
        
        if (levelGained > 0) {
          await _triggerLevelUpGamification(updatedAnimal.level);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> healAnimal(String animalId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      final animalDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animals')
          .doc(animalId)
          .get();

      if (animalDoc.exists) {
        final animal = FarmAnimal.fromFirestore(animalDoc);
        final updatedAnimal = animal.heal();
        final levelGained = updatedAnimal.level - animal.level;
        
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('animals')
            .doc(animalId)
            .update({
              'hunger': updatedAnimal.status.hunger,
              'love': updatedAnimal.status.love,
              'energy': updatedAnimal.status.energy,
              'health': updatedAnimal.status.health,
              'lastFed': Timestamp.fromDate(updatedAnimal.status.lastFed),
              'lastLoved': Timestamp.fromDate(updatedAnimal.status.lastLoved),
              'lastPlayed': Timestamp.fromDate(updatedAnimal.status.lastPlayed),
              'experience': updatedAnimal.experience,
              'level': updatedAnimal.level,
            });
            
        
        if (levelGained > 0) {
          await _triggerLevelUpGamification(updatedAnimal.level);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _triggerLevelUpGamification(int newLevel) async {
    try {
      final animals = await getUserAnimals();
      final totalLevel = animals.fold<int>(0, (sum, animal) => sum + animal.level);
      await _gamificationService.triggerAnimalLevelUp(newLevel);
      if (totalLevel > 0) {
        await _gamificationService.triggerAnimalLevelUp(totalLevel);
      }
    } catch (e) {
      debugPrint('Error triggering level up gamification: $e');
    }
  }


  Future<void> updateAnimalNickname(String animalId, String nickname) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('animals')
          .doc(animalId)
          .update({'nickname': nickname});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleAnimalFavorite(String animalId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      final animalDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animals')
          .doc(animalId)
          .get();

      if (animalDoc.exists) {
        final animal = FarmAnimal.fromFirestore(animalDoc);
        final updatedAnimal = animal.toggleFavorite();
        
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('animals')
            .doc(animalId)
            .update({'isFavorite': updatedAnimal.isFavorite});
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAnimalExperience(String animalId, int experience) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      final animalDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animals')
          .doc(animalId)
          .get();

      if (animalDoc.exists) {
        final animal = FarmAnimal.fromFirestore(animalDoc);
        final updatedAnimal = animal.addExperience(experience);
        
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('animals')
            .doc(animalId)
            .update({
              'experience': updatedAnimal.experience,
              'level': updatedAnimal.level,
            });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAnimal(String animalId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('animals')
          .doc(animalId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAnimalStatusesOverTime() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final animals = await getUserAnimals();
      final now = DateTime.now();

      for (final animal in animals) {
        final hoursSinceLastFed = now.difference(animal.status.lastFed).inHours;
        final hoursSinceLastPlayed = now.difference(animal.status.lastPlayed).inHours;
        final hoursSinceLastLoving = now.difference(animal.status.lastLoved).inHours;

        // Her saat başı açlık %10 azalır
        final newHunger = (animal.status.hunger - (hoursSinceLastFed * 0.1)).clamp(0.0, 1.0);
        
        // Her 2 saat başı enerji %15 azalır
        final newEnergy = (animal.status.energy - (hoursSinceLastPlayed * 0.075)).clamp(0.0, 1.0);

        ///her saat başı %20 azalır
        final newLove = (animal.status.love - (hoursSinceLastLoving * 0.2)).clamp(0.0, 1.0);

        final newHealth = (animal.status.health - ((1 - newHunger) * 0.05)).clamp(0.0, 1.0);

        if (newHunger != animal.status.hunger || newEnergy != animal.status.energy || newLove != animal.status.love) {
          final updatedStatus = animal.status.copyWith(
            hunger: newHunger,
            energy: newEnergy,
            love: newLove,
            health: newHealth,
          );

          await _firestore
              .collection('users')
              .doc(uid)
              .collection('animals')
              .doc(animal.id)
              .update({
                'hunger': updatedStatus.hunger,
                'energy': updatedStatus.energy,
                'love': updatedStatus.love,
                'health': updatedStatus.health,
              });
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
