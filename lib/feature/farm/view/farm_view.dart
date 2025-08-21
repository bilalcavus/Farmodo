import 'package:farmodo/feature/farm/viewmodel/farm_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class FarmView extends StatefulWidget {
  const FarmView({super.key});

  @override
  State<FarmView> createState() => _FarmViewState();
}

class _FarmViewState extends State<FarmView> {
  late final FarmGame game;
  final GlobalKey _gameKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    game = FarmGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8BC34A),
      appBar: AppBar(
        title: const Text('Çiftlik'),
        actions: [
          IconButton(
            tooltip: 'Hayvanlar',
            icon: const Icon(Icons.pets),
            onPressed: _openAnimalsSheet,
          ),
        ],
      ),
      body: GestureDetector(
        onScaleStart: (_) => FocusScope.of(context).unfocus(),
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 2.2,
          boundaryMargin: const EdgeInsets.all(200),
          panEnabled: false,
          scaleEnabled: true,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) {
              final pos = Vector2(e.localPosition.dx, e.localPosition.dy);
              game.handlePanStart(pos);
            },
            onPointerMove: (e) => game.handlePanUpdate(Vector2(e.localPosition.dx, e.localPosition.dy)),
            onPointerUp: (_) => game.handlePanEnd(),
            child: GameWidget(key: _gameKey, game: game),
          ),
        ),
      ),
    );
  }

  void _openAnimalsSheet() {
    showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      backgroundColor: const Color(0xFFF7FAF5),
      builder: (_) => _AnimalBottomSheet(game: game, gameBoxKey: _gameKey),
    ).then((value) {
      if (value != null) {
        final center = _gameCenterLocal();
        game.beginDragFromPalette(value, center);
        game.updateHoverFromLocal(center);
      }
    });
  }

  Vector2 _gameCenterLocal() {
    final RenderBox? box = _gameKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Vector2.zero();
    final size = box.size;
    return Vector2(size.width / 2, size.height / 2);
  }
}

class _AnimalBottomSheet extends StatefulWidget {
  const _AnimalBottomSheet({required this.game, required this.gameBoxKey});
  final FarmGame game;
  final GlobalKey gameBoxKey;

  @override
  State<_AnimalBottomSheet> createState() => _AnimalBottomSheetState();
}

class _AnimalBottomSheetState extends State<_AnimalBottomSheet> {
  bool placing = false;
  String? selected;

  @override
  Widget build(BuildContext context) {
    final names = widget.game.animalSprites.keys.toList();
    return Material(
      color: const Color(0xFFF7FAF5),
      elevation: 8,
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemBuilder: (c, i) {
            final n = names[i];
            final selectedThis = selected == n;
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(n),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: selectedThis ? Colors.green.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Image.asset('assets/images/animals/$n.png', width: 68, height: 68),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemCount: names.length,
        ),
      ),
    );
  }

  // No coordinate conversion needed here anymore; selection returns name only.
}


