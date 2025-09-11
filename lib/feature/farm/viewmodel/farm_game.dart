import 'dart:math' as math;

import 'package:farmodo/data/models/animal_model.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class FarmGame extends FlameGame {
  static const int gridCols = 8;
  static const int gridRows = 6;
  static const double tileSize = 80; // base square size before isometric transform
  static const double worldScale = 1.2; // overall world scale

  Vector2? gridOrigin; // top center of the diamond
  List<List<TileComponent>> tiles = [];
  final Map<String, Sprite> animalSprites = {};
  final List<DecorationComponent> decorations = [];
  
  // Farm animals from the app
  List<FarmAnimal> farmAnimals = [];
  Function(FarmAnimal)? onAnimalTap;

  AnimalSprite? draggingAnimal;
  int? hoverRow;
  int? hoverCol;

  @override
  Color backgroundColor() => const Color(0x00000000); // Transparent - scaffold rengini kullan

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Arkaplan kaldırıldı - scaffold rengi kullanılacak

    gridOrigin = Vector2(size.x * 0.5, 150); // Biraz daha yukarı

    tiles = List.generate(gridRows, (r) {
      return List.generate(gridCols, (c) {
        final pos = isoPositionOf(r, c);
        
        // Önce 3D grass block'ını ekle (altında)
        final grassBlock = GrassBlockComponent(
          row: r,
          col: c,
          position: pos,
          size: Vector2(tileSize * worldScale * 1.2, tileSize * 0.5 * worldScale * 1.2),
        );
        add(grassBlock);
        
        // Sonra tile'ı ekle (üstünde)
        final tile = TileComponent(
          row: r,
          col: c,
          position: pos,
          size: Vector2(tileSize * worldScale * 1.2, tileSize * 0.5 * worldScale * 1.2), // Biraz daha büyük
        );
        add(tile);
        return tile;
      });
    });

    // Configure asset prefix so we can load with 'animals/foo.png'
    images.prefix = '';

    // Hayvan sprite'ları dinamik olarak yüklenecek - hardcode liste kaldırıldı

    // Add decorative elements
    _addDecorations();

    // No in-game palette; animals will be provided from modal bottom sheet
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    // Arkaplan kaldırıldı - scaffold rengi kullanılıyor
    
    // Grid origin'i yeniden hesapla
    gridOrigin = Vector2(size.x * 0.5, 150); // Biraz daha yukarı
    
    // Grass block'ları yeniden konumlandır
    final grassBlocks = children.whereType<GrassBlockComponent>().toList();
    
    for (final grassBlock in grassBlocks) {
      grassBlock.position = isoPositionOf(grassBlock.row, grassBlock.col);
    }
    
    if (tiles.isNotEmpty && tiles.length == gridRows) {
      for (int r = 0; r < gridRows; r++) {
        if (tiles[r].length == gridCols) {
          for (int c = 0; c < gridCols; c++) {
            tiles[r][c].position = isoPositionOf(r, c);
          }
        }
      }
    }
    
    // Dekorasyonları yeniden konumlandır
    final existingDecorations = children.whereType<DecorationComponent>().toList();
    for (final decoration in existingDecorations) {
      decoration.removeFromParent();
    }
    decorations.clear();
    _addDecorations();
    
    // Hayvanları güncelle
    if (farmAnimals.isNotEmpty) {
      updateFarmAnimals(farmAnimals);
    }
  }

  // Update farm animals from the app
  void updateFarmAnimals(List<FarmAnimal> animals) {
    // Check if game is loaded
    if (gridOrigin == null) return;
    
    // Remove existing farm animal sprites safely
    final existingSprites = children.whereType<FarmAnimalSprite>().toList();
    for (final sprite in existingSprites) {
      sprite.removeFromParent();
    }
    
    // Kullanılmayan sprite'ları temizle
    _cleanupUnusedSprites(animals);
    
    farmAnimals = animals;
    
    // Gerekli sprite'ları dinamik olarak yükle
    _loadRequiredSprites(animals);
    
    // Add new farm animal sprites
    for (int i = 0; i < animals.length && i < gridRows * gridCols; i++) {
      final animal = animals[i];
      final row = i ~/ gridCols;
      final col = i % gridCols;
      
      if (row < gridRows && col < gridCols) {
        final tilePosition = isoPositionOf(row, col);
        // Hayvanı tile'ın tam üstüne yerleştir (biraz yukarı)
        final animalPosition = Vector2(tilePosition.x, tilePosition.y - 15);
        
        // Hayvan ID'sine göre sprite bul (önce imageUrl'den, sonra asset'ten)
        Sprite? animalSprite;
        if (animalSprites.containsKey(animal.id)) {
          animalSprite = animalSprites[animal.id];
        }
        
        final sprite = FarmAnimalSprite(
          animal: animal,
          position: animalPosition,
          onTap: onAnimalTap,
          animalSprite: animalSprite,
        );
        add(sprite);
      }
    }
  }
  
  // Hayvan görsellerini assets'ten dinamik olarak yükle
  Future<void> _loadRequiredSprites(List<FarmAnimal> animals) async {
    for (final animal in animals) {
      final animalId = animal.id;
      
      // Bu hayvanın sprite'ı zaten yüklü mü?
      if (animalSprites.containsKey(animalId)) {
        continue;
      }
      
      try {
        // Önce hayvanın kendi imageUrl'ini kullan (AnimalCard gibi)
        if (animal.imageUrl.isNotEmpty) {
          final img = await images.load(animal.imageUrl);
          animalSprites[animalId] = Sprite(img);
          print('Loaded animal sprite from imageUrl: ${animal.imageUrl} for ${animal.name}');
          continue;
        }
      } catch (e) {
        print('Failed to load animal sprite from imageUrl: ${animal.imageUrl} for ${animal.name}, error: $e');
      }
      
      try {
        // imageUrl yoksa veya başarısızsa, hayvan adından sprite adını belirle
        final spriteName = _getAnimalSpriteName(animal.name);
        if (spriteName.isNotEmpty) {
          final img = await images.load('assets/images/animals/$spriteName.png');
          animalSprites[animalId] = Sprite(img);
          print('Loaded animal sprite from asset: $spriteName for ${animal.name}');
          continue;
        }
      } catch (e) {
        print('Failed to load animal sprite from asset: ${_getAnimalSpriteName(animal.name)} for ${animal.name}, error: $e');
      }
      
      // Sprite bulunamazsa, default circle kullanılacak
      print('No sprite found for animal: ${animal.name}, will use default circle');
    }
  }
  
  // Kullanılmayan sprite'ları temizle
  void _cleanupUnusedSprites(List<FarmAnimal> animals) {
    final activeAnimalIds = animals.map((a) => a.id).toSet();
    final spritesToRemove = <String>[];
    
    for (final spriteKey in animalSprites.keys) {
      // Eğer bu sprite aktif hayvanlardan birine ait değilse, temizle
      if (!activeAnimalIds.contains(spriteKey)) {
        spritesToRemove.add(spriteKey);
      }
    }
    
    for (final key in spritesToRemove) {
      animalSprites.remove(key);
      print('Cleaned up unused sprite: $key');
    }
  }

  // Network image yükleme kaldırıldı - sadece assets kullanılıyor

  // Hayvan adından sprite adını dinamik olarak belirle
  String _getAnimalSpriteName(String animalName) {
    // Hayvan adını temizle ve küçük harfe çevir
    final cleanName = animalName.toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    
    // Mevcut asset'lerdeki hayvan isimleri
    final availableSprites = [
      'chicken', 'cow', 'dog', 'fox', 'goat', 
      'monkey', 'rooster', 'squirrel', 'thorny_dragon', 'tiger'
    ];
    
    // Önce tam eşleşme ara
    if (availableSprites.contains(cleanName)) {
      return cleanName;
    }
    
    // Kısmi eşleşme ara
    for (final spriteName in availableSprites) {
      if (cleanName.contains(spriteName) || spriteName.contains(cleanName)) {
        return spriteName;
      }
    }
    
    // Türkçe isimler için özel eşleştirmeler
    final turkishMappings = {
      'tavuk': 'chicken',
      'horoz': 'rooster', 
      'inek': 'cow',
      'köpek': 'dog',
      'tilki': 'fox',
      'keçi': 'goat',
      'maymun': 'monkey',
      'sincap': 'squirrel',
      'kaplan': 'tiger',
      'ejder': 'thorny_dragon',
    };
    
    for (final entry in turkishMappings.entries) {
      if (cleanName.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Hiçbir eşleşme bulunamazsa default chicken kullan
    return 'chicken';
  }

  void _addDecorations() {
    if (gridOrigin == null) return;
    
    // Add trees around the farm - outside the farm area
    final treePositions = [
      Vector2(gridOrigin!.x - 280, gridOrigin!.y - 180), // Top left
      Vector2(gridOrigin!.x + 280, gridOrigin!.y - 160), // Top right
      Vector2(gridOrigin!.x - 260, gridOrigin!.y + 220), // Bottom left
      Vector2(gridOrigin!.x + 300, gridOrigin!.y + 240), // Bottom right
      Vector2(gridOrigin!.x - 350, gridOrigin!.y + 60),  // Far left
      Vector2(gridOrigin!.x + 350, gridOrigin!.y + 40),  // Far right
      Vector2(gridOrigin!.x - 200, gridOrigin!.y - 80),  // Additional trees
      Vector2(gridOrigin!.x + 200, gridOrigin!.y - 60),
    ];
    for (final pos in treePositions) {
      final tree = TreeComponent(position: pos);
      add(tree);
      decorations.add(tree);
    }

    // Add a small pond - outside the farm area
    final pond = PondComponent(position: Vector2(gridOrigin!.x - 220, gridOrigin!.y + 150));
    add(pond);
    decorations.add(pond);

    // Add some rocks - outside the farm area
    final rockPositions = [
      Vector2(gridOrigin!.x - 250, gridOrigin!.y - 90),   // Top left area
      Vector2(gridOrigin!.x + 270, gridOrigin!.y - 70),   // Top right area
      Vector2(gridOrigin!.x - 200, gridOrigin!.y + 200),  // Bottom left area
      Vector2(gridOrigin!.x + 220, gridOrigin!.y + 220),  // Bottom right area
      Vector2(gridOrigin!.x - 320, gridOrigin!.y + 30),   // Far left area
      Vector2(gridOrigin!.x + 320, gridOrigin!.y + 10),   // Far right area
    ];
    for (final pos in rockPositions) {
      final rock = RockComponent(position: pos);
      add(rock);
      decorations.add(rock);
    }
  }

  Vector2 isoPositionOf(int row, int col) {
    // Convert grid (row,col) into isometric diamond coordinates
    final double half = tileSize * worldScale / 2;
    final double x = (col - row) * half;
    final double y = (col + row) * half * 0.5; // squash vertically for iso look
    return gridOrigin! + Vector2(x, y);
  }

  ({int row, int col}) nearestTile(Vector2 worldPoint) {
    // Inverse transform approximation to compute tile from world point
    final Vector2 p = worldPoint - gridOrigin!;
    final double half = tileSize * worldScale / 2;
    final double cApprox = p.x / half + (p.y / (half * 0.5));
    final double rApprox = (p.y / (half * 0.5)) - p.x / half;
    int col = cApprox ~/ 2;
    int row = rApprox ~/ 2;
    col = col.clamp(0, gridCols - 1);
    row = row.clamp(0, gridRows - 1);
    return (row: row, col: col);
  }

  bool isInsideGrid(Vector2 worldPoint) {
    final Vector2 p = worldPoint - gridOrigin!;
    final double half = tileSize * worldScale / 2;
    final double cFloat = (p.x / half + (p.y / (half * 0.5))) / 2.0;
    final double rFloat = ((p.y / (half * 0.5)) - p.x / half) / 2.0;
    return rFloat >= 0 && cFloat >= 0 && rFloat <= gridRows - 1 && cFloat <= gridCols - 1;
  }

  AnimalSprite? _hitAnimal(Vector2 point, {bool paletteOnly = false, bool placedOnly = false}) {
    AnimalSprite? result;
    for (final a in children.whereType<AnimalSprite>()) {
      if (paletteOnly && !a.asPalette) continue;
      if (placedOnly && a.asPalette) continue;
      if (a.containsPoint(point)) {
        result = a;
        break;
      }
    }
    return result;
  }

  void handlePanStart(Vector2 pos) {
    final hitPalette = _hitAnimal(pos, paletteOnly: true);
    if (hitPalette != null) {
      draggingAnimal = AnimalSprite(
        name: hitPalette.name,
        sprite: animalSprites[hitPalette.name]!,
        position: pos.clone(),
        asPalette: false,
      );
      add(draggingAnimal!);
      return;
    }

    final hitPlaced = _hitAnimal(pos, placedOnly: true);
    if (hitPlaced != null) {
      draggingAnimal = hitPlaced;
    }
  }

  void handlePanUpdate(Vector2 pos) {
    if (draggingAnimal != null) {
      draggingAnimal!.position = pos;
      if (isInsideGrid(pos)) {
        final t = nearestTile(pos);
        if (hoverRow != t.row || hoverCol != t.col) {
          _setTileHighlighted(hoverRow, hoverCol, false);
          hoverRow = t.row;
          hoverCol = t.col;
          _setTileHighlighted(hoverRow, hoverCol, true);
        }
      } else {
        _setTileHighlighted(hoverRow, hoverCol, false);
        hoverRow = null;
        hoverCol = null;
      }
    } else {
      // not dragging → ensure highlight is cleared
      _setTileHighlighted(hoverRow, hoverCol, false);
      hoverRow = null;
      hoverCol = null;
    }
  }

  void handlePanEnd() {
    if (draggingAnimal == null) return;

    final pos = draggingAnimal!.position;
    final tile = nearestTile(pos);
    final snapped = isoPositionOf(tile.row, tile.col);

    AnimalSprite? occupied;
    for (final a in children.whereType<AnimalSprite>()) {
      if (!a.asPalette && a != draggingAnimal && a.gridRow == tile.row && a.gridCol == tile.col) {
        occupied = a;
        break;
      }
    }

    if (occupied != null) {
      if (draggingAnimal!.fromPalette) {
        draggingAnimal!.removeFromParent();
      } else if (draggingAnimal!.gridRow != null && draggingAnimal!.gridCol != null) {
        draggingAnimal!.position = isoPositionOf(draggingAnimal!.gridRow!, draggingAnimal!.gridCol!);
      }
    } else {
      draggingAnimal!
        ..gridRow = tile.row
        ..gridCol = tile.col
        ..position = snapped;
      
      // Güvenli tile pulse
      if (tiles.isNotEmpty && tiles.length > tile.row && tiles[tile.row].length > tile.col) {
        tiles[tile.row][tile.col].triggerPulse();
      }
    }
    draggingAnimal = null;
    _setTileHighlighted(hoverRow, hoverCol, false);
    hoverRow = null;
    hoverCol = null;
  }

  void _setTileHighlighted(int? row, int? col, bool value) {
    if (row == null || col == null) return;
    if (row < 0 || col < 0 || row >= gridRows || col >= gridCols) return;
    if (tiles.isEmpty || tiles.length <= row || tiles[row].length <= col) return;
    tiles[row][col].isHighlighted = value;
  }

  // External UI (bottom sheet) integration
  void updateHoverFromLocal(Vector2 pos) {
    final t = nearestTile(pos);
    if (hoverRow != t.row || hoverCol != t.col) {
      _setTileHighlighted(hoverRow, hoverCol, false);
      hoverRow = t.row;
      hoverCol = t.col;
      _setTileHighlighted(hoverRow, hoverCol, true);
    }
  }

  void clearHover() {
    _setTileHighlighted(hoverRow, hoverCol, false);
    hoverRow = null;
    hoverCol = null;
  }

  void placeFromLocal(Vector2 pos, String name) {
    if (!isInsideGrid(pos)) {
      // invalid placement: remove temporary dragged animal if came from palette
      if (draggingAnimal != null && draggingAnimal!.fromPalette) {
        draggingAnimal!.removeFromParent();
      }
      clearHover();
      draggingAnimal = null;
      return;
    }
    final t = nearestTile(pos);
    // occupancy check
    for (final a in children.whereType<AnimalSprite>()) {
      if (!a.asPalette && a.gridRow == t.row && a.gridCol == t.col) {
        // Güvenli tile pulse
        if (tiles.isNotEmpty && tiles.length > t.row && tiles[t.row].length > t.col) {
          tiles[t.row][t.col].triggerPulse();
        }
        return;
      }
    }
    final placed = AnimalSprite(
      name: name,
      sprite: animalSprites[name]!,
      position: isoPositionOf(t.row, t.col),
      asPalette: false,
    )
      ..gridRow = t.row
      ..gridCol = t.col;
    add(placed);
    
    // Güvenli tile pulse
    if (tiles.isNotEmpty && tiles.length > t.row && tiles[t.row].length > t.col) {
      tiles[t.row][t.col].triggerPulse();
    }
    
    clearHover();
    draggingAnimal = null;
  }

  // Start a drag from external palette at a given local position
  void beginDragFromPalette(String name, Vector2 localPos) {
    draggingAnimal = AnimalSprite(
      name: name,
      sprite: animalSprites[name]!,
      position: localPos.clone(),
      asPalette: false,
    );
    add(draggingAnimal!);
    updateHoverFromLocal(localPos);
  }
}

class TileComponent extends PositionComponent {
  final int row;
  final int col;
  bool isHighlighted = false;
  double _blinkTime = 0;
  double _pulseTime = 0;

  TileComponent({
    required this.row,
    required this.col,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center) {
    // Tile'ların grass block'ların üstünde kalması için priority
    priority = 2;
  }

  void triggerPulse() {
    _pulseTime = 0.35; // quick flash after drop
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isHighlighted) {
      _blinkTime += dt;
    } else {
      _blinkTime = 0;
    }
    if (_pulseTime > 0) {
      _pulseTime -= dt;
      if (_pulseTime < 0) _pulseTime = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    final path = Path();
    final double w = size.x;
    final double h = size.y;
    // Diamond around the origin (anchor center)
    path.moveTo(0, -h / 2);
    path.lineTo(w / 2, 0);
    path.lineTo(0, h / 2);
    path.lineTo(-w / 2, 0);
    path.close();

    // Tile'lar transparan - grass block'lar alttan görünsün
    Color base = const Color(0xFF4CAF50).withOpacity(0.3); // Transparan yeşil
    if (isHighlighted) {
      final t = (math.sin(_blinkTime * 8) + 1) / 2; // 0..1
      base = Color.lerp(base, const Color(0xFF66BB6A).withOpacity(0.6), t * 0.7)!;
    }
    if (_pulseTime > 0) {
      final p = _pulseTime / 0.35; // 1..0
      base = Color.lerp(base, const Color(0xFFFFFFFF).withOpacity(0.8), p * 0.8)!;
    }

    final Paint fill = Paint()..color = base;
    final Paint border = Paint()
      ..color = const Color(0xFF2E7D32).withOpacity(0.8) // Transparan border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);

    // Add farm grass texture details - more defined than background
    _drawGrassTexture(canvas, path);
  }

  void _drawGrassTexture(Canvas canvas, Path tilePath) {
    final random = math.Random(row * 1000 + col);
    final Paint grassPaint = Paint()
      ..color = const Color(0xFF2E7D32) // Çok daha koyu çim detayları
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0; // Daha kalın çizgiler

    for (int i = 0; i < 12; i++) { // Daha fazla çim detayı
      final x = (random.nextDouble() - 0.5) * size.x * 0.9;
      final y = (random.nextDouble() - 0.5) * size.y * 0.9;
      final length = 5 + random.nextDouble() * 6; // Daha uzun çim
      final angle = random.nextDouble() * math.pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawLine(
        Offset(-length / 2, 0),
        Offset(length / 2, 0),
        grassPaint,
      );
      canvas.restore();
    }
  }
}

class GrassBlockComponent extends PositionComponent {
  final int row;
  final int col;

  GrassBlockComponent({
    required this.row,
    required this.col,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.center) {
    // Grass block'lar en arkada olmalı
    priority = 0;
  }

  @override
  void render(Canvas canvas) {
    final double w = size.x;
    final double h = size.y;
    final double blockHeight = 35.0; // 3D blok yüksekliği - daha yüksek
    
    // 3D grass block çiz - görseldeki gibi
    _drawGrassBlock(canvas, w, h, blockHeight);
  }

  void _drawGrassBlock(Canvas canvas, double w, double h, double blockHeight) {
    final double grassHeight = blockHeight * 0.4; // Yeşil grass kısmı
    
    // Ana yeşil yüzey (üst)
    final Path topPath = Path();
    topPath.moveTo(0, -h / 2);
    topPath.lineTo(w / 2, 0);
    topPath.lineTo(0, h / 2);
    topPath.lineTo(-w / 2, 0);
    topPath.close();

    final Paint topPaint = Paint()..color = const Color(0xFF7CB342); // Parlak yeşil
    canvas.drawPath(topPath, topPaint);

    // Sol yan yüzey - yeşil kısım (üst)
    final Path leftGrassPath = Path();
    leftGrassPath.moveTo(-w / 2, 0);
    leftGrassPath.lineTo(0, h / 2);
    leftGrassPath.lineTo(0, h / 2 + grassHeight);
    leftGrassPath.lineTo(-w / 2, grassHeight);
    leftGrassPath.close();

    final Paint leftGrassPaint = Paint()..color = const Color(0xFF689F38); // Koyu yeşil
    canvas.drawPath(leftGrassPath, leftGrassPaint);

    // Sol yan yüzey - kahverengi kısım (alt)
    final Path leftDirtPath = Path();
    leftDirtPath.moveTo(-w / 2, grassHeight);
    leftDirtPath.lineTo(0, h / 2 + grassHeight);
    leftDirtPath.lineTo(0, h / 2 + blockHeight);
    leftDirtPath.lineTo(-w / 2, blockHeight);
    leftDirtPath.close();

    final Paint leftDirtPaint = Paint()..color = const Color(0xFF8D6E63); // Kahverengi
    canvas.drawPath(leftDirtPath, leftDirtPaint);

    // Sağ yan yüzey - yeşil kısım (üst)
    final Path rightGrassPath = Path();
    rightGrassPath.moveTo(w / 2, 0);
    rightGrassPath.lineTo(0, h / 2);
    rightGrassPath.lineTo(0, h / 2 + grassHeight);
    rightGrassPath.lineTo(w / 2, grassHeight);
    rightGrassPath.close();

    final Paint rightGrassPaint = Paint()..color = const Color(0xFF558B2F); // Daha koyu yeşil
    canvas.drawPath(rightGrassPath, rightGrassPaint);

    // Sağ yan yüzey - kahverengi kısım (alt)
    final Path rightDirtPath = Path();
    rightDirtPath.moveTo(w / 2, grassHeight);
    rightDirtPath.lineTo(0, h / 2 + grassHeight);
    rightDirtPath.lineTo(0, h / 2 + blockHeight);
    rightDirtPath.lineTo(w / 2, blockHeight);
    rightDirtPath.close();

    final Paint rightDirtPaint = Paint()..color = const Color(0xFF6D4C41); // Daha koyu kahverengi
    canvas.drawPath(rightDirtPath, rightDirtPaint);

    // Çim tekstürü detayları üst yüzeyde
    _drawGrassTexture(canvas, topPath, w, h);
    
    // Dirt tekstürü detayları yan yüzeylerde
    _drawDirtTexture(canvas, leftDirtPath, rightDirtPath);
    
    // Kenar çizgileri
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawPath(topPath, borderPaint);
    canvas.drawPath(leftGrassPath, borderPaint);
    canvas.drawPath(leftDirtPath, borderPaint);
    canvas.drawPath(rightGrassPath, borderPaint);
    canvas.drawPath(rightDirtPath, borderPaint);
  }

  void _drawGrassTexture(Canvas canvas, Path clipPath, double w, double h) {
    canvas.save();
    canvas.clipPath(clipPath);
    
    final random = math.Random(row * 1000 + col);
    final Paint grassPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Çim detayları
    for (int i = 0; i < 8; i++) {
      final x = (random.nextDouble() - 0.5) * w * 0.7;
      final y = (random.nextDouble() - 0.5) * h * 0.7;
      final length = 3 + random.nextDouble() * 4;
      final angle = random.nextDouble() * math.pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.drawLine(
        Offset(-length / 2, 0),
        Offset(length / 2, 0),
        grassPaint,
      );
      canvas.restore();
    }
    
    canvas.restore();
  }

  void _drawDirtTexture(Canvas canvas, Path leftDirtPath, Path rightDirtPath) {
    final random = math.Random(row * 1000 + col + 999);
    
    // Sol dirt yüzeyine tekstür
    canvas.save();
    canvas.clipPath(leftDirtPath);

    for (int i = 0; i < 6; i++) {
      final x = (random.nextDouble() - 0.5) * size.x * 0.4 - size.x * 0.25;
      final y = (random.nextDouble() * size.y * 0.4) + size.y * 0.3;
      final radius = 1 + random.nextDouble() * 2;
      
      canvas.drawCircle(Offset(x, y), radius, Paint()..color = const Color(0xFF5D4037));
    }
    
    canvas.restore();
    
    // Sağ dirt yüzeyine tekstür
    canvas.save();
    canvas.clipPath(rightDirtPath);
    
    for (int i = 0; i < 6; i++) {
      final x = (random.nextDouble() - 0.5) * size.x * 0.4 + size.x * 0.25;
      final y = (random.nextDouble() * size.y * 0.4) + size.y * 0.3;
      final radius = 1 + random.nextDouble() * 2;
      
      canvas.drawCircle(Offset(x, y), radius, Paint()..color = const Color(0xFF4E342E));
    }
    
    canvas.restore();
  }
}

class AnimalSprite extends PositionComponent {
  final String name;
  final bool asPalette;
  int? gridRow;
  int? gridCol;
  final Sprite sprite;

  AnimalSprite({required this.name, required this.sprite, required Vector2 position, required this.asPalette})
      : super(
          position: position,
          size: Vector2.all(asPalette ? 64 : 72),
          anchor: Anchor.center,
        );

  bool get fromPalette => gridRow == null || gridCol == null;

  @override
  bool containsPoint(Vector2 point) {
    final rect = Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: size.x,
      height: size.y,
    );
    return rect.contains(Offset(point.x, point.y));
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    // draw sprite centered
    sprite.render(
      canvas,
      anchor: Anchor.center,
      position: Vector2.zero(),
      size: size,
    );
    canvas.restore();
  }
}

class FarmAnimalSprite extends PositionComponent {
  final FarmAnimal animal;
  final Function(FarmAnimal)? onTap;
  final Sprite? animalSprite;

  FarmAnimalSprite({
    required this.animal,
    required Vector2 position,
    this.onTap,
    this.animalSprite,
  }) : super(
          position: position,
          size: Vector2.all(60), // Küçük grid için boyutu azalt
          anchor: Anchor.center,
        ) {
    // Hayvanların tile'ların üstünde render edilmesi için yüksek priority
    priority = 10;
  }

  @override
  bool containsPoint(Vector2 point) {
    final rect = Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: size.x,
      height: size.y,
    );
    return rect.contains(Offset(point.x, point.y));
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint();
    
    // Gerçek sprite varsa onu kullan, yoksa renkli daire çiz
    if (animalSprite != null) {
      // Sprite'ı çiz
      canvas.save();
      animalSprite!.render(
        canvas,
        anchor: Anchor.center,
        position: Vector2.zero(),
        size: size,
      );
      canvas.restore();
    } else {
      // Varsayılan renkli daire çiz
      _drawDefaultAnimal(canvas, paint);
    }
    
    // Durum göstergeleri (sprite üzerine)
    _drawStatusIndicators(canvas, paint);
  }
  
  void _drawDefaultAnimal(Canvas canvas, Paint paint) {
    // Hayvan durumuna göre renk belirle
    Color animalColor;
    Color borderColor;
    if (animal.status.isHappy) {
      animalColor = const Color(0xFFFFD700); // Altın sarısı
      borderColor = const Color(0xFFFFA500);
    } else if (animal.status.isHungry) {
      animalColor = const Color(0xFFFF8C00); // Turuncu
      borderColor = const Color(0xFFFF4500);
    } else if (animal.status.isSick) {
      animalColor = const Color(0xFFDC143C); // Kırmızı
      borderColor = const Color(0xFF8B0000);
    } else if (animal.status.needsLove) {
      animalColor = const Color(0xFFFF69B4); // Pembe
      borderColor = const Color(0xFFFF1493);
    } else {
      animalColor = const Color(0xFF8B4513); // Kahverengi
      borderColor = const Color(0xFF654321);
    }
    
    // Hayvan gövdesi (gradient efektli daire) - küçük grid için boyutu azalt
    final animalSize = 18.0 + (animal.level * 1.5);
    
    // Ana gövde
    paint.color = animalColor;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, animalSize, paint);
    
    // Dış çerçeve
    paint.color = borderColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawCircle(Offset.zero, animalSize, paint);
    
    // İç gölge efekti
    paint.color = Colors.white.withOpacity(0.3);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      const Offset(-2, -2), 
      animalSize * 0.6, 
      paint
    );
    
    // Hayvan gölgesi (daha gerçekçi)
    paint.color = Colors.black.withOpacity(0.4);
    paint.style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, animalSize + 3),
        width: animalSize * 1.8,
        height: animalSize * 0.6,
      ),
      paint,
    );
  }
  
  void _drawStatusIndicators(Canvas canvas, Paint paint) {
    final animalSize = 18.0 + (animal.level * 1.5);
    
    // Durum göstergesi (küçük nokta)
    if (animal.status.isHungry || animal.status.isSick || animal.status.needsLove) {
      paint.color = Colors.red;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(animalSize * 0.7, -animalSize * 0.7),
        3.0,
        paint,
      );
    }
    
    // Seviye göstergesi (daha güzel)
    if (animal.level > 1) {
      // Seviye arka planı
      paint.color = const Color(0xFF4CAF50);
      paint.style = PaintingStyle.fill;
      final levelBgSize = 16.0; // Küçük grid için boyutu azalt
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, -animalSize - 12), // Pozisyonu da ayarla
            width: levelBgSize,
            height: 10, // Yüksekliği de azalt
          ),
          const Radius.circular(5),
        ),
        paint,
      );
      
      // Seviye metni
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'L${animal.level}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8, // Küçük grid için font boyutu azalt
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          -textPainter.width / 2, 
          -animalSize - 17 // Pozisyonu ayarla
        ),
      );
    }
    
    // Favori göstergesi
    if (animal.isFavorite) {
      paint.color = const Color(0xFFFFD700);
      paint.style = PaintingStyle.fill;
      _drawStar(canvas, paint, Offset(-animalSize - 8, -animalSize - 8), 6.0); // Küçük grid için boyutu azalt
    }
  }
  
  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    const numPoints = 5;
    const angle = 3.14159 / numPoints;
    
    for (int i = 0; i < numPoints * 2; i++) {
      final r = (i % 2 == 0) ? radius : radius * 0.5;
      final x = center.dx + r * math.cos(i * angle - 3.14159 / 2);
      final y = center.dy + r * math.sin(i * angle - 3.14159 / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  bool onTapDown(TapDownEvent event) {
    if (onTap != null) {
      onTap!(animal);
      return true;
    }
    return false;
  }
}

// Decorative components
abstract class DecorationComponent extends PositionComponent {
  DecorationComponent({required Vector2 position}) : super(position: position, anchor: Anchor.center) {
    // Dekorasyonlar orta seviyede priority
    priority = 5;
  }
}

// BackgroundGrassComponent kaldırıldı - scaffold arkaplan rengi kullanılıyor

class TreeComponent extends DecorationComponent {
  TreeComponent({required super.position});

  @override
  void render(Canvas canvas) {
    // Draw trunk
    final trunkPaint = Paint()..color = const Color(0xFF8D6E63);
    final trunkRect = Rect.fromCenter(center: Offset.zero, width: 8, height: 20);
    canvas.drawRect(trunkRect, trunkPaint);

    // Draw foliage
    final foliagePaint = Paint()..color = const Color(0xFF4CAF50);
    final foliagePath = Path()
      ..addOval(Rect.fromCenter(center: Offset(0, -15), width: 40, height: 35));
    canvas.drawPath(foliagePath, foliagePaint);

    // Add some detail
    final detailPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(-8, -20), 3, detailPaint);
    canvas.drawCircle(Offset(8, -18), 2, detailPaint);
    canvas.drawCircle(Offset(0, -25), 2, detailPaint);
  }
}

class PondComponent extends DecorationComponent {
  PondComponent({required super.position});

  // @override
  // void render(Canvas canvas) {
  //   // Draw water
  //   final waterPaint = Paint()..color = const Color(0xFF42A5F5);
  //   final waterPath = Path()
  //     ..addOval(Rect.fromCenter(center: Offset.zero, width: 80, height: 56));
  //   canvas.drawPath(waterPath, waterPaint);

  //   // // Add water ripples
  //   // final ripplePaint = Paint()
  //   //   ..color = const Color(0xFF1976D2)
  //   //   ..style = PaintingStyle.stroke
  //   //   ..strokeWidth = 1.0;
  //   // canvas.drawCircle(Offset.zero, 25, ripplePaint);
  //   // canvas.drawCircle(Offset.zero, 15, ripplePaint);
  // }
}

class RockComponent extends DecorationComponent {
  RockComponent({required super.position});

  @override
  void render(Canvas canvas) {
    final rockPaint = Paint()..color = const Color(0xFF757575);
    final rockPath = Path()
      ..addOval(Rect.fromCenter(center: Offset.zero, width: 30, height: 18));
    canvas.drawPath(rockPath, rockPaint);

    // Add some texture
    final detailPaint = Paint()
      ..color = const Color(0xFF616161)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(-8, -5), Offset(8, -5), detailPaint);
    canvas.drawLine(Offset(-6, 0), Offset(6, 0), detailPaint);
    canvas.drawLine(Offset(-4, 5), Offset(4, 5), detailPaint);
  }
}


