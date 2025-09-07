import 'dart:math' as math;

import 'package:farmodo/data/models/animal_model.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class FarmGame extends FlameGame {
  static const int gridCols = 12;
  static const int gridRows = 10;
  static const double tileSize = 100; // base square size before isometric transform
  static const double worldScale = 1.5; // overall world scale

  Vector2? gridOrigin; // top center of the diamond
  late final List<List<TileComponent>> tiles;
  final Map<String, Sprite> animalSprites = {};
  final List<DecorationComponent> decorations = [];
  
  // Farm animals from the app
  List<FarmAnimal> farmAnimals = [];
  Function(FarmAnimal)? onAnimalTap;

  AnimalSprite? draggingAnimal;
  int? hoverRow;
  int? hoverCol;

  @override
  Color backgroundColor() => const Color(0xFF8BC34A); // Light green background covering entire page

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add background grass that covers the entire screen
    add(BackgroundGrassComponent(size: size));

    gridOrigin = Vector2(size.x * 0.5, 200);

    tiles = List.generate(gridRows, (r) {
      return List.generate(gridCols, (c) {
        final pos = isoPositionOf(r, c);
        final tile = TileComponent(
          row: r,
          col: c,
          position: pos,
          size: Vector2(tileSize * worldScale, tileSize * 0.5 * worldScale),
        );
        add(tile);
        return tile;
      });
    });

    // Configure asset prefix so we can load with 'animals/foo.png'
    images.prefix = '';

    // Load animal sprites from assets
    final animalNames = [
      'chicken',
      'cow', 
      'goat',
      'dog',
      'tiger',
      'squirrel',
    
    ];
    
    for (final name in animalNames) {
      try {
        final img = await images.load('assets/images/animals/$name.png');
        animalSprites[name] = Sprite(img);
      } catch (e) {
        // Asset bulunamazsa varsayılan sprite kullan
        print('Animal asset not found: $name');
      }
    }

    // Add decorative elements
    _addDecorations();

    // No in-game palette; animals will be provided from modal bottom sheet
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Game resize olduğunda hayvanları güncelle
    if (gridOrigin != null && farmAnimals.isNotEmpty) {
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
    
    farmAnimals = animals;
    
    // Add new farm animal sprites
    for (int i = 0; i < animals.length && i < gridRows * gridCols; i++) {
      final animal = animals[i];
      final row = i ~/ gridCols;
      final col = i % gridCols;
      
      if (row < gridRows && col < gridCols) {
        final position = isoPositionOf(row, col);
        
        // Hayvan adına göre sprite bul
        Sprite? animalSprite;
        final animalName = _getAnimalSpriteName(animal.name);
        if (animalSprites.containsKey(animalName)) {
          animalSprite = animalSprites[animalName];
        }
        
        final sprite = FarmAnimalSprite(
          animal: animal,
          position: position,
          onTap: onAnimalTap,
          animalSprite: animalSprite,
        );
        add(sprite);
      }
    }
  }
  
  // Hayvan adından sprite adını belirle
  String _getAnimalSpriteName(String animalName) {
    final name = animalName.toLowerCase();
    
    // Hayvan adlarını sprite adlarıyla eşleştir
    if (name.contains('chicken') || name.contains('tavuk')) return 'chicken';
    if (name.contains('cow') || name.contains('inek')) return 'cow';
    if (name.contains('goat') || name.contains('keçi')) return 'goat';
    if (name.contains('dog') || name.contains('köpek')) return 'dog';
    if (name.contains('tiger') || name.contains('kaplan')) return 'tiger';
    if (name.contains('squirrel') || name.contains('sincap')) return 'squirrel';
    if (name.contains('pig') || name.contains('domuz')) return 'pig';
    if (name.contains('sheep') || name.contains('koyun')) return 'sheep';
    if (name.contains('horse') || name.contains('at')) return 'horse';
    if (name.contains('duck') || name.contains('ördek')) return 'duck';
    
    // Varsayılan olarak ilk mevcut sprite'ı kullan
    return animalSprites.keys.isNotEmpty ? animalSprites.keys.first : 'chicken';
  }

  void _addDecorations() {
    if (gridOrigin == null) return;
    
    // Add trees around the farm - outside the farm area
    final treePositions = [
      Vector2(gridOrigin!.x - 400, gridOrigin!.y - 250), // Top left, further out
      Vector2(gridOrigin!.x + 400, gridOrigin!.y - 230), // Top right, further out
      Vector2(gridOrigin!.x - 380, gridOrigin!.y + 300), // Bottom left, further out
      Vector2(gridOrigin!.x + 420, gridOrigin!.y + 320), // Bottom right, further out
      Vector2(gridOrigin!.x - 500, gridOrigin!.y + 100),  // Far left
      Vector2(gridOrigin!.x + 500, gridOrigin!.y + 80),  // Far right
      Vector2(gridOrigin!.x - 350, gridOrigin!.y - 100), // Additional trees
      Vector2(gridOrigin!.x + 350, gridOrigin!.y - 80),
      Vector2(gridOrigin!.x - 300, gridOrigin!.y + 400),
      Vector2(gridOrigin!.x + 300, gridOrigin!.y + 420),
    ];
    for (final pos in treePositions) {
      final tree = TreeComponent(position: pos);
      add(tree);
      decorations.add(tree);
    }

    // Add a small pond - outside the farm area
    final pond = PondComponent(position: Vector2(gridOrigin!.x - 300, gridOrigin!.y + 200));
    add(pond);
    decorations.add(pond);

    // Add some rocks - outside the farm area
    final rockPositions = [
      Vector2(gridOrigin!.x - 350, gridOrigin!.y - 120),  // Top left area
      Vector2(gridOrigin!.x + 370, gridOrigin!.y - 100),  // Top right area
      Vector2(gridOrigin!.x - 280, gridOrigin!.y + 280), // Bottom left area
      Vector2(gridOrigin!.x + 300, gridOrigin!.y + 300), // Bottom right area
      Vector2(gridOrigin!.x - 450, gridOrigin!.y + 50),  // Far left area
      Vector2(gridOrigin!.x + 450, gridOrigin!.y + 30),  // Far right area
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
      tiles[tile.row][tile.col].triggerPulse();
    }
    draggingAnimal = null;
    _setTileHighlighted(hoverRow, hoverCol, false);
    hoverRow = null;
    hoverCol = null;
  }

  void _setTileHighlighted(int? row, int? col, bool value) {
    if (row == null || col == null) return;
    if (row < 0 || col < 0 || row >= gridRows || col >= gridCols) return;
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
        tiles[t.row][t.col].triggerPulse();
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
    tiles[t.row][t.col].triggerPulse();
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
  }) : super(anchor: Anchor.center);

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

    // Create farm area grass - darker and more vibrant than background
    Color base = const Color(0xFF66BB6A); // Farm area green - more vibrant
    if (isHighlighted) {
      final t = (math.sin(_blinkTime * 8) + 1) / 2; // 0..1
      base = Color.lerp(base, const Color(0xFF81C784), t * 0.7)!;
    }
    if (_pulseTime > 0) {
      final p = _pulseTime / 0.35; // 1..0
      base = Color.lerp(base, const Color(0xFFFFFFFF), p * 0.8)!;
    }

    final Paint fill = Paint()..color = base;
    final Paint border = Paint()
      ..color = const Color(0xFF4CAF50) // Darker border for farm area
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
      ..color = const Color(0xFF4CAF50) // Darker grass details for farm area
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5; // Thicker lines for farm area

    for (int i = 0; i < 10; i++) { // More grass details in farm area
      final x = (random.nextDouble() - 0.5) * size.x * 0.8;
      final y = (random.nextDouble() - 0.5) * size.y * 0.8;
      final length = 4 + random.nextDouble() * 5; // Longer grass in farm area
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
          size: Vector2.all(80),
          anchor: Anchor.center,
        );

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
    
    // Hayvan gövdesi (gradient efektli daire)
    final animalSize = 25.0 + (animal.level * 2.5);
    
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
    final animalSize = 25.0 + (animal.level * 2.5);
    
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
      final levelBgSize = 20.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, -animalSize - 15),
            width: levelBgSize,
            height: 12,
          ),
          const Radius.circular(6),
        ),
        paint,
      );
      
      // Seviye metni
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'L${animal.level}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
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
          -animalSize - 21
        ),
      );
    }
    
    // Favori göstergesi
    if (animal.isFavorite) {
      paint.color = const Color(0xFFFFD700);
      paint.style = PaintingStyle.fill;
      _drawStar(canvas, paint, Offset(-animalSize - 10, -animalSize - 10), 8.0);
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
  DecorationComponent({required Vector2 position}) : super(position: position, anchor: Anchor.center);
}

class BackgroundGrassComponent extends PositionComponent {
  BackgroundGrassComponent({required Vector2 size}) : super(size: size, anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    // Draw the entire background with light green grass
    final Paint backgroundPaint = Paint()..color = const Color(0xFF8BC34A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), backgroundPaint);

    // Add some grass texture to the background
    final Paint grassPaint = Paint()
      ..color = const Color(0xFF689F38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final random = math.Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.x;
      final y = random.nextDouble() * size.y;
      final length = 2 + random.nextDouble() * 3;
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


