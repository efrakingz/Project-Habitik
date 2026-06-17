import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:habitik/core/services/audio_service.dart';

// Import modular components
import 'models/waste_item.dart';
import 'models/level_config.dart';
import 'painters/blueprint_painter.dart';
import 'widgets/circular_timer.dart';
import 'widgets/conveyor_belt.dart';
import 'widgets/recycling_bin.dart';
import 'widgets/level_select.dart';
import 'widgets/game_over_overlay.dart';

class EcoPuzzleChallenge extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onComplete;

  const EcoPuzzleChallenge({super.key, required this.onBack, required this.onComplete});

  @override
  State<EcoPuzzleChallenge> createState() => _EcoPuzzleChallengeState();
}

class _EcoPuzzleChallengeState extends State<EcoPuzzleChallenge> with TickerProviderStateMixin {
  int _currentLevel = 0; // 0 = start screen, 1 = Level 1, 2 = Level 2, 3 = Level 3
  
  final List<BinData> _allBins = [
    const BinData(type: 'plastico', name: 'Plástico', color: Color(0xFFFFD54F), icon: Icons.recycling),
    const BinData(type: 'papel', name: 'Papel/Cartón', color: Color(0xFF8D6E63), icon: Icons.description),
    const BinData(type: 'vidrio', name: 'Vidrio', color: Color(0xFF64B5F6), icon: Icons.local_drink),
    const BinData(type: 'organico', name: 'Orgánico', color: Color(0xFF81C784), icon: Icons.eco),
    const BinData(type: 'peligroso', name: 'Peligroso', color: Color(0xFFE57373), icon: Icons.warning),
    const BinData(type: 'metal', name: 'Metal', color: Color(0xFF90A4AE), icon: Icons.hardware),
  ];

  final List<WasteItem> _allItems = [
    const WasteItem(id: 'pet_bottle', binType: 'plastico', name: 'Botella PET'),
    const WasteItem(id: 'detergent_bottle', binType: 'plastico', name: 'Detergente'),
    const WasteItem(id: 'plastic_bag', binType: 'plastico', name: 'Bolsa'),
    const WasteItem(id: 'plastic_cup', binType: 'plastico', name: 'Vaso Plástico'),
    const WasteItem(id: 'newspaper', binType: 'papel', name: 'Periódico'),
    const WasteItem(id: 'cardboard', binType: 'papel', name: 'Cartón'),
    const WasteItem(id: 'envelope', binType: 'papel', name: 'Sobre'),
    const WasteItem(id: 'notebook', binType: 'papel', name: 'Cuaderno'),
    const WasteItem(id: 'glass_bottle', binType: 'vidrio', name: 'Botella Vidrio'),
    const WasteItem(id: 'glass_jar', binType: 'vidrio', name: 'Frasco'),
    const WasteItem(id: 'wine_glass', binType: 'vidrio', name: 'Copa'),
    const WasteItem(id: 'mirror', binType: 'vidrio', name: 'Espejo'),
    const WasteItem(id: 'orange_peel', binType: 'organico', name: 'Naranja'),
    const WasteItem(id: 'apple_core', binType: 'organico', name: 'Manzana'),
    const WasteItem(id: 'banana_peel', binType: 'organico', name: 'Plátano'),
    const WasteItem(id: 'coffee', binType: 'organico', name: 'Café'),
    const WasteItem(id: 'battery', binType: 'peligroso', name: 'Pila'),
    const WasteItem(id: 'phone', binType: 'peligroso', name: 'Celular'),
    const WasteItem(id: 'lightbulb', binType: 'peligroso', name: 'Bombilla'),
    const WasteItem(id: 'spray_can', binType: 'peligroso', name: 'Aerosol'),
    const WasteItem(id: 'can', binType: 'metal', name: 'Lata'),
    const WasteItem(id: 'food_can', binType: 'metal', name: 'Conserva'),
    const WasteItem(id: 'metal_screw', binType: 'metal', name: 'Tornillo'),
    const WasteItem(id: 'key', binType: 'metal', name: 'Llave'),
  ];

  late AnimationController _conveyorController;
  Timer? _spawnTimer;
  Timer? _gameTimer;

  int _score = 0;
  int _targetScore = 0;
  int _timeLeft = 0;
  int _totalTimeLimit = 60;
  bool _isGameOver = false;
  bool _won = false;
  
  List<BinData> _activeBins = [];
  List<WasteItem> _activeItemsPool = [];
  
  final List<Map<String, dynamic>> _conveyorItems = [];
  final Random _random = Random();
  late ConfettiController _confettiController;

  // Track bin currently hovered during drag and drop
  String? _hoveredBinType;

  @override
  void initState() {
    super.initState();
    AudioService.playBGM('puzzle_bgm.mp3');
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    _conveyorController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _conveyorController.addListener(() {
      if (!_isGameOver && _currentLevel > 0) {
        _updateConveyorItems();
      }
    });
  }

  @override
  void dispose() {
    _conveyorController.dispose();
    _confettiController.dispose();
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    AudioService.stopBGM();
    super.dispose();
  }

  void _startGame(int level) {
    setState(() {
      _currentLevel = level;
      _score = 0;
      _isGameOver = false;
      _won = false;
      _conveyorItems.clear();
      
      final config = level == 1
          ? LevelConfig.level1
          : (level == 2 ? LevelConfig.level2 : LevelConfig.level3);
      
      _totalTimeLimit = config.timeLimitSeconds;
      _timeLeft = _totalTimeLimit;
      _targetScore = config.targetClassified;
      
      if (level == 1) {
        _activeBins = _allBins.sublist(0, 4);
        _conveyorController.duration = const Duration(seconds: 3);
      } else if (level == 2) {
        _activeBins = _allBins.sublist(0, 5);
        _conveyorController.duration = const Duration(milliseconds: 2500);
      } else {
        _activeBins = _allBins;
        _conveyorController.duration = const Duration(seconds: 2);
      }
      
      _conveyorController.repeat();
      
      final activeBinTypes = _activeBins.map((b) => b.type).toSet();
      _activeItemsPool = _allItems.where((i) => activeBinTypes.contains(i.binType)).toList();
    });

    _startGameTimer();
    _startSpawner();
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });
  }

  void _startSpawner() {
    _spawnTimer?.cancel();
    final spawnInterval = _currentLevel == 1 ? 2500 : (_currentLevel == 2 ? 2000 : 1500);
    
    _spawnItem();
    _spawnTimer = Timer.periodic(Duration(milliseconds: spawnInterval), (timer) {
      if (!_isGameOver) _spawnItem();
    });
  }

  void _spawnItem() {
    if (_activeItemsPool.isEmpty) return;
    final item = _activeItemsPool[_random.nextInt(_activeItemsPool.length)];
    setState(() {
      _conveyorItems.add({
        'item': item,
        'id': DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(100).toString(),
        'progress': 0.0,
        'status': 'moving',
      });
    });
  }

  void _updateConveyorItems() {
    if (!mounted) return;
    
    final speed = _currentLevel == 1 ? 0.003 : (_currentLevel == 2 ? 0.004 : 0.005);
    bool needsUpdate = false;
    
    for (var i = 0; i < _conveyorItems.length; i++) {
      if (_conveyorItems[i]['status'] == 'moving') {
        _conveyorItems[i]['progress'] += speed;
        needsUpdate = true;
        if (_conveyorItems[i]['progress'] > 1.0) {
          _conveyorItems[i]['status'] = 'missed';
          AudioService.playSFX('error.mp3');
        }
      }
    }
    
    if (needsUpdate) {
      setState(() {
        _conveyorItems.removeWhere((item) => item['status'] == 'missed');
      });
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    _conveyorController.stop();
    
    setState(() {
      _isGameOver = true;
      _won = _score >= _targetScore;
    });
    
    if (_won) {
      AudioService.playSFX('win.mp3');
      _confettiController.play();
    } else {
      AudioService.playSFX('error.mp3');
    }
  }

  void _onItemDropped(WasteItem item, String binType) {
    if (_isGameOver) return;
    
    if (item.binType == binType) {
      AudioService.playSFX('catch_trash.mp3');
      setState(() {
        _score++;
        if (_score >= _targetScore) {
          _endGame();
        }
      });
    } else {
      AudioService.playSFX('error.mp3');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background blueprint canvas
          Positioned.fill(
            child: CustomPaint(
              painter: BlueprintGridPainter(),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                if (_currentLevel == 0)
                  Expanded(
                    child: LevelSelect(
                      onLevelSelected: _startGame,
                    ),
                  )
                else
                  Expanded(child: _buildGameArea()),
              ],
            ),
          ),
          
          if (_isGameOver)
            GameOverOverlay(
              won: _won,
              score: _score,
              targetScore: _targetScore,
              onComplete: widget.onComplete,
              onRetry: () => _startGame(_currentLevel),
              onMenu: () => setState(() => _currentLevel = 0),
            ),
          
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              colors: const [Colors.green, Colors.blue, Colors.yellow, Colors.red],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final titleText = _currentLevel == 0
        ? 'ECO-PUZZLE'
        : 'Eco-Puzzle';
    final subtitleText = _currentLevel == 0
        ? 'Clasifica y Recicla'
        : (_currentLevel == 1
            ? 'Inicio de Planta'
            : (_currentLevel == 2
                ? 'Desafío Orgánico'
                : 'Más Tipos'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              if (_currentLevel > 0) {
                _gameTimer?.cancel();
                _spawnTimer?.cancel();
                _conveyorController.stop();
                setState(() {
                  _isGameOver = false;
                  _currentLevel = 0;
                });
              } else {
                widget.onBack();
              }
            },
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titleText,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitleText,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF64B5F6),
                ),
              ),
            ],
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return Column(
      children: [
        const SizedBox(height: 16),
        CircularTimer(
          timeLeft: _timeLeft,
          totalTimeLimit: _totalTimeLimit,
          score: _score,
          targetScore: _targetScore,
        ),
        const Spacer(),
        _buildConveyorBeltWidget(),
        const Spacer(),
        _buildBinsAreaWidget(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildConveyorBeltWidget() {
    final List<Widget> itemsWidgets = _conveyorItems.map((itemObj) {
      final item = itemObj['item'] as WasteItem;
      final progress = itemObj['progress'] as double;
      final id = itemObj['id'] as String;
      
      return Positioned(
        left: (MediaQuery.of(context).size.width * progress) - 37.5,
        child: Draggable<WasteItem>(
          data: item,
          feedback: _buildTrashItem(item, dragging: true),
          childWhenDragging: const SizedBox(width: 75, height: 75),
          onDragStarted: () {
            setState(() {
              itemObj['status'] = 'dragging';
            });
          },
          onDraggableCanceled: (velocity, offset) {
            setState(() {
              itemObj['status'] = 'moving';
            });
          },
          onDragCompleted: () {
            setState(() {
              _conveyorItems.removeWhere((e) => e['id'] == id);
            });
          },
          child: _buildTrashItem(item),
        ),
      );
    }).toList();

    return ConveyorBelt(
      controller: _conveyorController,
      items: itemsWidgets,
    );
  }

  double _getItemScaleX(String itemId) {
    switch (itemId) {
      case 'pet_bottle':
      case 'metal_screw':
      case 'spray_can':
        return 0.50; // Squeeze significantly to make them tall and thin
      case 'battery':
        return 0.55;
      case 'food_can':
      case 'plastic_cup':
        return 0.60; // Squeeze from wide square to standard container proportion
      case 'lightbulb':
      case 'mirror':
        return 0.65;
      case 'notebook':
        return 0.70;
      default:
        return 1.0;
    }
  }

  Widget _buildTrashItem(WasteItem item, {bool dragging = false}) {
    final double scaleX = _getItemScaleX(item.id);
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: dragging ? Colors.white.withAlpha(50) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: dragging
            ? [BoxShadow(color: Colors.cyan.withAlpha(120), blurRadius: 15, spreadRadius: 3)]
            : [],
      ),
      child: Transform.scale(
        scaleX: scaleX,
        scaleY: 1.0,
        child: Image.asset(
          'lib/features/challenges/games/eco_puzzle/images/${item.id}.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildBinsAreaWidget() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int binsCount = _activeBins.length;

    // Adapt level height and rows: Level 1 has 4 tall bins (height: 130), Level 2-3 have shorter bins (height: 60)
    if (binsCount <= 4) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _activeBins
              .map((bin) => _buildBinDragTarget(bin, screenWidth / 4.6, 130.0))
              .toList(),
        ),
      );
    } else {
      final row1 = _activeBins.sublist(0, 3);
      final row2 = _activeBins.sublist(3);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row1
                  .map((bin) => _buildBinDragTarget(bin, screenWidth / 3.6, 60.0))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row2
                  .map((bin) => _buildBinDragTarget(bin, screenWidth / 3.6, 60.0))
                  .toList(),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBinDragTarget(BinData bin, double width, double height) {
    return DragTarget<WasteItem>(
      onWillAcceptWithDetails: (details) {
        setState(() => _hoveredBinType = bin.type);
        return true;
      },
      onLeave: (data) {
        setState(() => _hoveredBinType = null);
      },
      onAcceptWithDetails: (details) {
        setState(() => _hoveredBinType = null);
        _onItemDropped(details.data, bin.type);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = _hoveredBinType == bin.type;
        return PixelBinWidget(
          bin: bin,
          isHovered: isHovered,
          width: width,
          height: height,
        );
      },
    );
  }
}