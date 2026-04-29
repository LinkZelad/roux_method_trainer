import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../roux/cube.dart';
import '../widgets/cube_3d.dart';

/// Demo mode screen: shows a 3D cube with step-by-step algorithm playback.
/// Similar to book.rouxers.com interactive examples.
class DemoScreen extends StatefulWidget {
  final String title;
  final String scramble;
  final String algorithm;

  const DemoScreen({
    super.key,
    required this.title,
    required this.scramble,
    required this.algorithm,
  });

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> with SingleTickerProviderStateMixin {
  late RouxCube _cube;
  late List<String> _moves;
  int _currentStep = 0;
  bool _isPlaying = false;
  
  late AnimationController _animController;
  String? _animatingMove;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _cube = RouxCube.solved().applyAlg(widget.scramble);
    _moves = _parseMoves(widget.algorithm);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<String> _parseMoves(String alg) {
    final seq = RouxMoveSeq.parse(alg);
    return seq.moves.map((m) => m.name).toList();
  }

  Future<void> _goToStep(int step) async {
    if (step < 0) step = 0;
    if (step > _moves.length) step = _moves.length;
    if (step == _currentStep || _isAnimating) return;

    if (step == _currentStep + 1) {
      // Animate forward
      final move = _moves[_currentStep];
      setState(() {
        _animatingMove = move;
        _isAnimating = true;
      });
      await _animController.forward(from: 0);
      setState(() {
        _cube = _cube.applyAlg(move);
        _currentStep = step;
        _animatingMove = null;
        _isAnimating = false;
      });
      _animController.reset();
    } else if (step == _currentStep - 1) {
      // Animate backward
      final move = _moves[step];
      final inverseMove = RouxMoveSeq.parse(move).inverse().moves.first.name;
      setState(() {
        _animatingMove = inverseMove;
        _isAnimating = true;
      });
      await _animController.forward(from: 0);
      setState(() {
        _cube = _cube.applyAlg(inverseMove);
        _currentStep = step;
        _animatingMove = null;
        _isAnimating = false;
      });
      _animController.reset();
    } else {
      // Jump
      setState(() {
        _cube = RouxCube.solved().applyAlg(widget.scramble);
        for (int i = 0; i < step; i++) {
          _cube = _cube.applyAlg(_moves[i]);
        }
        _currentStep = step;
      });
    }
  }

  void _stepForward() {
    if (_currentStep < _moves.length) {
      _goToStep(_currentStep + 1);
    }
  }

  void _stepBackward() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _goToStart() {
    _goToStep(0);
  }

  void _goToEnd() {
    _goToStep(_moves.length);
  }

  void _togglePlay() {
    if (_isPlaying) {
      _stopPlay();
    } else {
      _startPlay();
    }
  }

  void _startPlay() {
    if (_currentStep >= _moves.length) return;
    setState(() => _isPlaying = true);
    _playNext();
  }

  Future<void> _playNext() async {
    if (!_isPlaying || _currentStep >= _moves.length) {
      _stopPlay();
      return;
    }
    await _goToStep(_currentStep + 1);
    await Future.delayed(const Duration(milliseconds: 200));
    if (_isPlaying) _playNext();
  }

  void _stopPlay() {
    setState(() => _isPlaying = false);
  }

  /// Parse a move notation into face name, direction icon, and description.
  _MoveInfo? _parseMoveInfo(String move) {
    if (move.isEmpty) return null;
    final face = move[0];
    final suffix = move.length > 1 ? move.substring(1) : '';

    final faceNames = {
      'U': 'Up',
      'D': 'Down',
      'F': 'Front',
      'B': 'Back',
      'R': 'Right',
      'L': 'Left',
      'M': 'Middle',
      'E': 'Equator',
      'S': 'Standing',
      'u': 'u-wide',
      'd': 'd-wide',
      'f': 'f-wide',
      'b': 'b-wide',
      'r': 'r-wide',
      'l': 'l-wide',
      'x': 'x-rotate',
      'y': 'y-rotate',
      'z': 'z-rotate',
    };

    final faceName = faceNames[face] ?? face;

    if (suffix == "'") {
      return _MoveInfo(
        face: face,
        faceName: faceName,
        direction: 'Counter-clockwise',
        icon: Icons.rotate_left,
      );
    } else if (suffix == '2') {
      return _MoveInfo(
        face: face,
        faceName: faceName,
        direction: '180°',
        icon: Icons.flip_camera_android,
      );
    } else {
      return _MoveInfo(
        face: face,
        faceName: faceName,
        direction: 'Clockwise',
        icon: Icons.rotate_right,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.watch<TimerProvider>().settings.colorScheme;
    final currentMove = _currentStep > 0 && _currentStep <= _moves.length
        ? _parseMoveInfo(_moves[_currentStep - 1])
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Current move indicator
          if (currentMove != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    currentMove.icon,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${currentMove.face}  ${currentMove.faceName}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'RobotoMono',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentMove.direction,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 36),
          const SizedBox(height: 8),
          // 3D Cube
          Expanded(
            flex: 3,
            child: Center(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Cube3D.fromCube(
                    _cube,
                    colorScheme: colorScheme,
                    size: MediaQuery.sizeOf(context).width * 0.7,
                    animatingMove: _animatingMove,
                    animationProgress: _animController.value,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Step counter
          Text(
            _currentStep > 0
                ? 'Step $_currentStep / ${_moves.length}'
                : 'Start',
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 12),
          // Algorithm move buttons
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _moves.length,
              itemBuilder: (context, index) {
                final isActive = index < _currentStep;
                final isCurrent = index == _currentStep - 1 && _currentStep > 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => _goToStep(index + 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Colors.orange
                            : isActive
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.grey[800],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isCurrent
                              ? Colors.orange
                              : isActive
                                  ? Colors.green
                                  : Colors.grey[700]!,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _moves[index],
                        style: TextStyle(
                          color: isActive || isCurrent
                              ? Colors.white
                              : Colors.white54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'RobotoMono',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Full algorithm text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.algorithm,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: 'RobotoMono',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          // Playback controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: Icons.skip_previous,
                    onPressed: _goToStart,
                  ),
                  _buildControlButton(
                    icon: Icons.fast_rewind,
                    onPressed: _stepBackward,
                  ),
                  _buildControlButton(
                    icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                    onPressed: _togglePlay,
                    isPrimary: true,
                  ),
                  _buildControlButton(
                    icon: Icons.fast_forward,
                    onPressed: _stepForward,
                  ),
                  _buildControlButton(
                    icon: Icons.skip_next,
                    onPressed: _goToEnd,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return Container(
      width: isPrimary ? 64 : 48,
      height: isPrimary ? 64 : 48,
      decoration: BoxDecoration(
        color: isPrimary ? Colors.green : Colors.grey[800],
        borderRadius: BorderRadius.circular(isPrimary ? 32 : 12),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isPrimary ? Colors.black : Colors.white,
          size: isPrimary ? 32 : 24,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _MoveInfo {
  final String face;
  final String faceName;
  final String direction;
  final IconData icon;

  _MoveInfo({
    required this.face,
    required this.faceName,
    required this.direction,
    required this.icon,
  });
}
