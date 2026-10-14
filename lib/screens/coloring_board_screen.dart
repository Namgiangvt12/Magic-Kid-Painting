import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import '../theme/app_colors.dart';
import '../services/app_settings_service.dart';
import '../services/audio_service.dart';
import '../localization/app_strings.dart';
import 'celebration_screen.dart';

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  DrawingStroke clone() {
    return DrawingStroke(
      points: List<Offset>.from(points),
      color: color,
      strokeWidth: strokeWidth,
    );
  }
}

abstract class DrawingAction {}

class StrokeAction extends DrawingAction {
  final DrawingStroke stroke;
  StrokeAction(this.stroke);
}

class EraseAction extends DrawingAction {
  final List<DrawingStroke> previousStrokes;
  final List<DrawingStroke> newStrokes;
  final Map<int, int> clearedPixels; // idx -> previousColor
  final Color previousBgColor;
  final Color newBgColor;

  EraseAction({
    required this.previousStrokes,
    required this.newStrokes,
    this.clearedPixels = const {},
    this.previousBgColor = Colors.white,
    this.newBgColor = Colors.white,
  });
}

class FillAction extends DrawingAction {
  final Int32List indices;
  final int previousColor;
  final int newColor;
  final List<DrawingStroke> previousStrokes;
  final List<DrawingStroke> newStrokes;
  final Color previousBgColor;
  final Color newBgColor;

  FillAction({
    required this.indices,
    required this.previousColor,
    required this.newColor,
    required this.previousStrokes,
    required this.newStrokes,
    required this.previousBgColor,
    required this.newBgColor,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final ui.Image? fillImage;
  final ui.Image? outlineImage;
  final Color canvasBgColor;

  DrawingPainter({
    required this.strokes,
    this.fillImage,
    this.outlineImage,
    this.canvasBgColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Canvas background color
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = canvasBgColor,
    );

    final fittedDst = _ColoringBoardScreenState.calculateFittedRect(size, 1024, 1024);

    // 2) Bucket filled regions
    if (fillImage != null) {
      canvas.drawImageRect(
        fillImage!,
        Rect.fromLTWH(0, 0, fillImage!.width.toDouble(), fillImage!.height.toDouble()),
        fittedDst,
        Paint(),
      );
    }

    // 3) Freehand user strokes
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = stroke.strokeWidth
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points[0],
          stroke.strokeWidth / 2,
          paint..style = PaintingStyle.fill,
        );
      } else {
        final path = Path();
        path.moveTo(stroke.points[0].dx, stroke.points[0].dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // 4) Outline image on top with BlendMode.multiply:
    //    • Black pixels (0,0,0) × any color = black → outline stays sharp
    //    • White pixels (1,1,1) × any color = color → colors shine through
    if (outlineImage != null) {
      canvas.drawImageRect(
        outlineImage!,
        Rect.fromLTWH(0, 0, outlineImage!.width.toDouble(), outlineImage!.height.toDouble()),
        fittedDst,
        Paint()..blendMode = BlendMode.multiply,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}

class ColoringBoardScreen extends StatefulWidget {
  const ColoringBoardScreen({super.key});

  @override
  State<ColoringBoardScreen> createState() => _ColoringBoardScreenState();
}

class _ColoringBoardScreenState extends State<ColoringBoardScreen> {
  int _activeColorIndex = 4; // Default to Mint Green
  String _activeTool = 'brush'; // bucket, brush, eraser
  String _brushSize = 'medium'; // small, medium, large
  double _strokeWidth = 8.0;

  final List<DrawingStroke> _strokes = [];
  final List<DrawingAction> _history = [];
  final List<DrawingAction> _redoHistory = [];

  List<DrawingStroke> _strokesBeforeEraser = [];
  final Map<int, int> _erasedPixelsInDrag = {};

  bool _isUpdatingFillImage = false;
  bool _hasPendingFillUpdate = false;

  Color _canvasBgColor = Colors.white;

  ui.Image? _outlineImage;
  ui.Image? _fillImage;
  Uint8List? _wallMask;
  Uint32List? _fillColorMap;
  Uint8List? _fillRgbaBytes;
  bool _isLoadingImage = true;

  final List<Map<String, dynamic>> _palette = [
    {'color': const Color(0xFFFFB5C5), 'name': 'Hồng phấn'},
    {'color': const Color(0xFFFF4D6D), 'name': 'Hồng dâu'},
    {'color': const Color(0xFFFF8500), 'name': 'Cam tươi'},
    {'color': const Color(0xFFFFD166), 'name': 'Vàng nắng'},
    {'color': const Color(0xFF06D6A0), 'name': 'Xanh bạc hà'},
    {'color': const Color(0xFF2EC4B6), 'name': 'Xanh ngọc bích'},
    {'color': const Color(0xFF38BDF8), 'name': 'Lam da trời'},
    {'color': const Color(0xFF00668A), 'name': 'Lam biển'},
    {'color': const Color(0xFF7BD0FF), 'name': 'Xanh ngọc'},
    {'color': const Color(0xFFAB8FFE), 'name': 'Tím lavender'},
    {'color': const Color(0xFF674BB5), 'name': 'Tím đậm'},
    {'color': const Color(0xFF795900), 'name': 'Nâu đất'},
    {'color': const Color(0xFFFFFFFF), 'name': 'Trắng tinh'},
    {'color': const Color(0xFF1B1C19), 'name': 'Đen tuyền'},
  ];

  Color get _currentColor => _palette[_activeColorIndex]['color'] as Color;
  String get _currentColorName => _palette[_activeColorIndex]['name'] as String;

  static Rect calculateFittedRect(Size size, double imgW, double imgH) {
    const padding = 12.0;
    final destRect = Rect.fromLTWH(
      padding,
      padding,
      (size.width - padding * 2).clamp(1.0, double.infinity),
      (size.height - padding * 2).clamp(1.0, double.infinity),
    );
    final srcAspect = imgW / imgH;
    final dstAspect = destRect.width / destRect.height;
    if (srcAspect > dstAspect) {
      final h = destRect.width / srcAspect;
      return Rect.fromLTWH(
        destRect.left,
        destRect.top + (destRect.height - h) / 2,
        destRect.width,
        h,
      );
    } else {
      final w = destRect.height * srcAspect;
      return Rect.fromLTWH(
        destRect.left + (destRect.width - w) / 2,
        destRect.top,
        w,
        destRect.height,
      );
    }
  }

  void _onSizeSelected(String size) {
    AudioService().playTap();
    setState(() {
      _brushSize = size;
      if (size == 'small') {
        _strokeWidth = 4.0;
      } else if (size == 'medium') {
        _strokeWidth = 8.0;
      } else {
        _strokeWidth = 16.0;
      }
    });
  }

  void _requestUpdateFillImage() {
    if (_isUpdatingFillImage) {
      _hasPendingFillUpdate = true;
      return;
    }
    _isUpdatingFillImage = true;
    _hasPendingFillUpdate = false;
    _updateFillImage().then((_) {
      _isUpdatingFillImage = false;
      if (_hasPendingFillUpdate) {
        _requestUpdateFillImage();
      }
    });
  }

  Future<void> _handleEraserTap(Offset localPos, Size canvasSize) async {
    if (_wallMask == null || _fillColorMap == null || _fillRgbaBytes == null) return;

    final fittedDst = calculateFittedRect(canvasSize, 1024, 1024);
    final prevBg = _canvasBgColor;

    int seedX = 10;
    int seedY = 10;
    final bool tappedOutside = !fittedDst.contains(localPos);

    if (tappedOutside) {
      seedX = 10;
      seedY = 10;
    } else {
      final normX = (localPos.dx - fittedDst.left) / fittedDst.width;
      final normY = (localPos.dy - fittedDst.top) / fittedDst.height;
      final imgX = (normX * 1024).toInt().clamp(0, 1023);
      final imgY = (normY * 1024).toInt().clamp(0, 1023);
      seedX = imgX;
      seedY = imgY;
    }

    final startIdx = seedY * 1024 + seedX;
    final targetColor = _fillColorMap![startIdx];

    // If tapped on a bucket-filled region or outside in a colored background, clear the region!
    if (targetColor != 0 || (tappedOutside && _canvasBgColor != Colors.white)) {
      AudioService().playEraser();
      final strokesBefore = _strokes.map((s) => s.clone()).toList();
      final clearedMap = <int, int>{};

      if (targetColor != 0) {
        final stack = Int32List(1024 * 1024);
        int sp = 0;
        stack[sp++] = startIdx;
        clearedMap[startIdx] = targetColor;
        _fillColorMap![startIdx] = 0;

        final bStart = startIdx << 2;
        _fillRgbaBytes![bStart] = 0;
        _fillRgbaBytes![bStart + 1] = 0;
        _fillRgbaBytes![bStart + 2] = 0;
        _fillRgbaBytes![bStart + 3] = 0;

        bool touchesBorder = tappedOutside;
        while (sp > 0) {
          final pos = stack[--sp];
          final px = pos & 1023;
          final py = pos >> 10;

          if (px == 0 || px == 1023 || py == 0 || py == 1023) {
            touchesBorder = true;
          }

          // Left
          if (px > 0) {
            final n = pos - 1;
            if (_wallMask![n] == 0 && _fillColorMap![n] == targetColor) {
              clearedMap[n] = targetColor;
              _fillColorMap![n] = 0;
              final idx = n << 2;
              _fillRgbaBytes![idx] = 0;
              _fillRgbaBytes![idx + 1] = 0;
              _fillRgbaBytes![idx + 2] = 0;
              _fillRgbaBytes![idx + 3] = 0;
              stack[sp++] = n;
            }
          }
          // Right
          if (px < 1023) {
            final n = pos + 1;
            if (_wallMask![n] == 0 && _fillColorMap![n] == targetColor) {
              clearedMap[n] = targetColor;
              _fillColorMap![n] = 0;
              final idx = n << 2;
              _fillRgbaBytes![idx] = 0;
              _fillRgbaBytes![idx + 1] = 0;
              _fillRgbaBytes![idx + 2] = 0;
              _fillRgbaBytes![idx + 3] = 0;
              stack[sp++] = n;
            }
          }
          // Up
          if (py > 0) {
            final n = pos - 1024;
            if (_wallMask![n] == 0 && _fillColorMap![n] == targetColor) {
              clearedMap[n] = targetColor;
              _fillColorMap![n] = 0;
              final idx = n << 2;
              _fillRgbaBytes![idx] = 0;
              _fillRgbaBytes![idx + 1] = 0;
              _fillRgbaBytes![idx + 2] = 0;
              _fillRgbaBytes![idx + 3] = 0;
              stack[sp++] = n;
            }
          }
          // Down
          if (py < 1023) {
            final n = pos + 1024;
            if (_wallMask![n] == 0 && _fillColorMap![n] == targetColor) {
              clearedMap[n] = targetColor;
              _fillColorMap![n] = 0;
              final idx = n << 2;
              _fillRgbaBytes![idx] = 0;
              _fillRgbaBytes![idx + 1] = 0;
              _fillRgbaBytes![idx + 2] = 0;
              _fillRgbaBytes![idx + 3] = 0;
              stack[sp++] = n;
            }
          }
        }

        if (touchesBorder) {
          _canvasBgColor = Colors.white;
        }
      } else {
        _canvasBgColor = Colors.white;
      }

      await _updateFillImage();

      _history.add(EraseAction(
        previousStrokes: strokesBefore,
        newStrokes: _strokes.map((s) => s.clone()).toList(),
        clearedPixels: clearedMap,
        previousBgColor: prevBg,
        newBgColor: _canvasBgColor,
      ));
      _redoHistory.clear();
      setState(() {});
    } else {
      // Tapped on empty area or stroke: circular erase
      final strokesBefore = _strokes.map((s) => s.clone()).toList();
      _erasedPixelsInDrag.clear();
      _eraseAt(localPos, canvasSize);
      _history.add(EraseAction(
        previousStrokes: strokesBefore,
        newStrokes: _strokes.map((s) => s.clone()).toList(),
        clearedPixels: Map.from(_erasedPixelsInDrag),
        previousBgColor: prevBg,
        newBgColor: _canvasBgColor,
      ));
      _erasedPixelsInDrag.clear();
      _redoHistory.clear();
    }
  }

  void _eraseAt(Offset pos, Size canvasSize) {
    double radius = 18.0;
    if (_brushSize == 'small') {
      radius = 12.0;
    } else if (_brushSize == 'large') {
      radius = 32.0;
    }

    final rSq = radius * radius;
    final updated = <DrawingStroke>[];
    bool anyStrokeChanged = false;

    // 1. Erase vector brush strokes
    for (final stroke in _strokes) {
      final currentSegment = <Offset>[];
      for (final pt in stroke.points) {
        final dx = pt.dx - pos.dx;
        final dy = pt.dy - pos.dy;
        if (dx * dx + dy * dy <= rSq) {
          anyStrokeChanged = true;
          if (currentSegment.isNotEmpty) {
            updated.add(DrawingStroke(
              points: List<Offset>.from(currentSegment),
              color: stroke.color,
              strokeWidth: stroke.strokeWidth,
            ));
            currentSegment.clear();
          }
        } else {
          currentSegment.add(pt);
        }
      }
      if (currentSegment.isNotEmpty) {
        updated.add(DrawingStroke(
          points: List<Offset>.from(currentSegment),
          color: stroke.color,
          strokeWidth: stroke.strokeWidth,
        ));
      }
    }

    if (anyStrokeChanged) {
      _strokes
        ..clear()
        ..addAll(updated);
    }

    // 2. Erase filled pixels under the eraser circle
    bool anyFillChanged = false;
    if (_fillColorMap != null && _fillRgbaBytes != null) {
      final fittedDst = calculateFittedRect(canvasSize, 1024, 1024);
      if (fittedDst.contains(pos)) {
        final normX = (pos.dx - fittedDst.left) / fittedDst.width;
        final normY = (pos.dy - fittedDst.top) / fittedDst.height;
        final imgX = (normX * 1024).toInt().clamp(0, 1023);
        final imgY = (normY * 1024).toInt().clamp(0, 1023);
        final imgR = ((radius / fittedDst.width) * 1024).toInt().clamp(4, 80);
        final imgRSq = imgR * imgR;

        for (int dy = -imgR; dy <= imgR; dy++) {
          final py = imgY + dy;
          if (py < 0 || py >= 1024) continue;
          for (int dx = -imgR; dx <= imgR; dx++) {
            if (dx * dx + dy * dy > imgRSq) continue;
            final px = imgX + dx;
            if (px < 0 || px >= 1024) continue;
            final idx = py * 1024 + px;
            if (_fillColorMap![idx] != 0) {
              _erasedPixelsInDrag[idx] = _fillColorMap![idx];
              _fillColorMap![idx] = 0;
              final bIdx = idx << 2;
              _fillRgbaBytes![bIdx] = 0;
              _fillRgbaBytes![bIdx + 1] = 0;
              _fillRgbaBytes![bIdx + 2] = 0;
              _fillRgbaBytes![bIdx + 3] = 0;
              anyFillChanged = true;
            }
          }
        }
      }
    }

    if (anyFillChanged) {
      _requestUpdateFillImage();
    }

    if (anyStrokeChanged || anyFillChanged) {
      AudioService().playEraser();
      setState(() {});
    }
  }

  void _undo() async {
    if (_history.isEmpty) return;
    AudioService().playUndo();

    final action = _history.removeLast();
    _redoHistory.add(action);

    if (action is StrokeAction) {
      setState(() {
        _strokes.remove(action.stroke);
      });
    } else if (action is EraseAction) {
      setState(() {
        _strokes
          ..clear()
          ..addAll(action.previousStrokes.map((s) => s.clone()));
        _canvasBgColor = action.previousBgColor;
      });
      if (action.clearedPixels.isNotEmpty && _fillColorMap != null && _fillRgbaBytes != null) {
        action.clearedPixels.forEach((idx, prevCol) {
          _fillColorMap![idx] = prevCol;
          final c = Color(prevCol);
          final bIdx = idx << 2;
          _fillRgbaBytes![bIdx] = (c.r * 255.0).round().clamp(0, 255);
          _fillRgbaBytes![bIdx + 1] = (c.g * 255.0).round().clamp(0, 255);
          _fillRgbaBytes![bIdx + 2] = (c.b * 255.0).round().clamp(0, 255);
          _fillRgbaBytes![bIdx + 3] = (c.a * 255.0).round().clamp(0, 255);
        });
        await _updateFillImage();
      }
    } else if (action is FillAction && _fillColorMap != null && _fillRgbaBytes != null) {
      final prevCol = action.previousColor;
      final isTransparent = prevCol == 0;
      final c = Color(prevCol);
      final r = isTransparent ? 0 : (c.r * 255.0).round().clamp(0, 255);
      final g = isTransparent ? 0 : (c.g * 255.0).round().clamp(0, 255);
      final b = isTransparent ? 0 : (c.b * 255.0).round().clamp(0, 255);
      final a = isTransparent ? 0 : (c.a * 255.0).round().clamp(0, 255);

      for (final idx in action.indices) {
        _fillColorMap![idx] = prevCol;
        final bIdx = idx << 2;
        _fillRgbaBytes![bIdx] = r;
        _fillRgbaBytes![bIdx + 1] = g;
        _fillRgbaBytes![bIdx + 2] = b;
        _fillRgbaBytes![bIdx + 3] = a;
      }
      _strokes
        ..clear()
        ..addAll(action.previousStrokes.map((s) => s.clone()));
      _canvasBgColor = action.previousBgColor;
      await _updateFillImage();
    }
  }

  void _redo() async {
    if (_redoHistory.isEmpty) return;
    AudioService().playRedo();

    final action = _redoHistory.removeLast();
    _history.add(action);

    if (action is StrokeAction) {
      setState(() {
        _strokes.add(action.stroke);
      });
    } else if (action is EraseAction) {
      setState(() {
        _strokes
          ..clear()
          ..addAll(action.newStrokes.map((s) => s.clone()));
        _canvasBgColor = action.newBgColor;
      });
      if (action.clearedPixels.isNotEmpty && _fillColorMap != null && _fillRgbaBytes != null) {
        action.clearedPixels.forEach((idx, _) {
          _fillColorMap![idx] = 0;
          final bIdx = idx << 2;
          _fillRgbaBytes![bIdx] = 0;
          _fillRgbaBytes![bIdx + 1] = 0;
          _fillRgbaBytes![bIdx + 2] = 0;
          _fillRgbaBytes![bIdx + 3] = 0;
        });
        await _updateFillImage();
      }
    } else if (action is FillAction && _fillColorMap != null && _fillRgbaBytes != null) {
      final newCol = action.newColor;
      final c = Color(newCol);
      final r = (c.r * 255.0).round().clamp(0, 255);
      final g = (c.g * 255.0).round().clamp(0, 255);
      final b = (c.b * 255.0).round().clamp(0, 255);
      final a = (c.a * 255.0).round().clamp(0, 255);

      for (final idx in action.indices) {
        _fillColorMap![idx] = newCol;
        final bIdx = idx << 2;
        _fillRgbaBytes![bIdx] = r;
        _fillRgbaBytes![bIdx + 1] = g;
        _fillRgbaBytes![bIdx + 2] = b;
        _fillRgbaBytes![bIdx + 3] = a;
      }
      _strokes
        ..clear()
        ..addAll(action.newStrokes.map((s) => s.clone()));
      _canvasBgColor = action.newBgColor;
      await _updateFillImage();
    }
  }

  void _saveArt() {
    AudioService().playSave();
    AppSettingsService().addStars(1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.tr('savedSuccess')),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _outlineImage?.dispose();
    _fillImage?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_outlineImage == null) {
      _loadOutlineImage();
    }
  }

  Future<void> _loadOutlineImage() async {
    try {
      final data = await rootBundle.load('assets/images/kitten_outline.jpg');
      final bytes = data.buffer.asUint8List();

      // Decode ui.Image for canvas painting
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final loadedUiImage = frame.image;

      // Decode image in pure Dart to extract pixel luminance for flood fill
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final w = decoded.width;
        final h = decoded.height;
        final mask = Uint8List(w * h);
        for (int y = 0; y < h; y++) {
          for (int x = 0; x < w; x++) {
            final p = decoded.getPixel(x, y);
            final lum = (p.r * 299 + p.g * 587 + p.b * 114) ~/ 1000;
            if (lum < 160) {
              mask[y * w + x] = 1; // Black outline boundary
            }
          }
        }
        _wallMask = mask;
        _fillColorMap = Uint32List(w * h);
        _fillRgbaBytes = Uint8List(w * h * 4);
      }

      if (mounted) {
        setState(() {
          _outlineImage = loadedUiImage;
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load outline image: $e');
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }

  Future<void> _updateFillImage() async {
    if (_fillRgbaBytes == null) return;
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      Uint8List.fromList(_fillRgbaBytes!),
      1024,
      1024,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final img = await completer.future;
    if (mounted) {
      setState(() {
        _fillImage = img;
      });
    }
  }

  Future<void> _handleBucketTap(Offset localPos, Size canvasSize) async {
    if (_wallMask == null || _fillColorMap == null || _fillRgbaBytes == null) return;

    final fittedDst = calculateFittedRect(canvasSize, 1024, 1024);
    final prevBg = _canvasBgColor;

    int seedX = 10;
    int seedY = 10;
    final bool tappedOutside = !fittedDst.contains(localPos);

    if (tappedOutside) {
      // Tapped outside fitted image: target is the open background!
      seedX = 10;
      seedY = 10;
    } else {
      final normX = (localPos.dx - fittedDst.left) / fittedDst.width;
      final normY = (localPos.dy - fittedDst.top) / fittedDst.height;
      final imgX = (normX * 1024).toInt().clamp(0, 1023);
      final imgY = (normY * 1024).toInt().clamp(0, 1023);
      seedX = imgX;
      seedY = imgY;
    }

    // If tapped directly on a black boundary line, search adjacent pixels for the region
    if (_wallMask![seedY * 1024 + seedX] == 1) {
      bool found = false;
      for (int r = 1; r <= 8; r++) {
        for (int dy = -r; dy <= r; dy++) {
          for (int dx = -r; dx <= r; dx++) {
            final nx = (seedX + dx).clamp(0, 1023);
            final ny = (seedY + dy).clamp(0, 1023);
            if (_wallMask![ny * 1024 + nx] == 0) {
              seedX = nx;
              seedY = ny;
              found = true;
              break;
            }
          }
          if (found) break;
        }
        if (found) break;
      }
      if (!found) return; // Completely surrounded by black line
    }

    final startIdx = seedY * 1024 + seedX;
    final targetColor = _fillColorMap![startIdx];
    final color = _currentColor;
    final newColorVal = color.toARGB32();

    if (targetColor == newColorVal) {
      if (tappedOutside || seedX == 10) {
        if (_canvasBgColor != color) {
          setState(() {
            _canvasBgColor = color;
          });
        }
      }
      return;
    }

    // Snapshot strokes before fill
    final strokesBefore = _strokes.map((s) => s.clone()).toList();

    // Stack-based 4-way flood fill
    final stack = Int32List(1024 * 1024);
    int sp = 0;
    stack[sp++] = startIdx;
    _fillColorMap![startIdx] = newColorVal;

    final changedIndices = <int>[startIdx];
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);
    final a = (color.a * 255.0).round().clamp(0, 255);

    final bStart = startIdx << 2;
    _fillRgbaBytes![bStart] = r;
    _fillRgbaBytes![bStart + 1] = g;
    _fillRgbaBytes![bStart + 2] = b;
    _fillRgbaBytes![bStart + 3] = a;

    bool touchesBorder = tappedOutside;

    while (sp > 0) {
      final pos = stack[--sp];
      final px = pos & 1023;
      final py = pos >> 10;

      if (px == 0 || px == 1023 || py == 0 || py == 1023) {
        touchesBorder = true;
      }

      // Left
      if (px > 0) {
        final n = pos - 1;
        if (_wallMask![n] == 0 && _fillColorMap![n] == targetColor) {
          _fillColorMap![n] = newColorVal;
          final idx = n << 2;
          _fillRgbaBytes![idx] = r;
          _fillRgbaBytes![idx + 1] = g;
          _fillRgbaBytes![idx + 2] = b;
          _fillRgbaBytes![idx + 3] = a;
          changedIndices.add(n);
          stack[sp++] = n;
        }
      }
      // Right
      if (px < 1023) {
        final n = pos + 1;
        if (_wallMask![n] == 0 && _fillColorMap![n] == targetColor) {
          _fillColorMap![n] = newColorVal;
          final idx = n << 2;
          _fillRgbaBytes![idx] = r;
          _fillRgbaBytes![idx + 1] = g;
          _fillRgbaBytes![idx + 2] = b;
          _fillRgbaBytes![idx + 3] = a;
          changedIndices.add(n);
          stack[sp++] = n;
        }
      }
      // Up
      if (py > 0) {
        final n = pos - 1024;
        if (_wallMask![n] == 0 && _fillColorMap![n] == targetColor) {
          _fillColorMap![n] = newColorVal;
          final idx = n << 2;
          _fillRgbaBytes![idx] = r;
          _fillRgbaBytes![idx + 1] = g;
          _fillRgbaBytes![idx + 2] = b;
          _fillRgbaBytes![idx + 3] = a;
          changedIndices.add(n);
          stack[sp++] = n;
        }
      }
      // Down
      if (py < 1023) {
        final n = pos + 1024;
        if (_wallMask![n] == 0 && _fillColorMap![n] == targetColor) {
          _fillColorMap![n] = newColorVal;
          final idx = n << 2;
          _fillRgbaBytes![idx] = r;
          _fillRgbaBytes![idx + 1] = g;
          _fillRgbaBytes![idx + 2] = b;
          _fillRgbaBytes![idx + 3] = a;
          changedIndices.add(n);
          stack[sp++] = n;
        }
      }
    }

    // Clear any existing brush strokes inside this filled region so the region is completely solid
    final changedSet = changedIndices.toSet();
    final updatedStrokes = <DrawingStroke>[];

    for (final stroke in _strokes) {
      final currentSegment = <Offset>[];
      for (final pt in stroke.points) {
        bool insideRegion = false;
        if (fittedDst.contains(pt)) {
          final nx = (pt.dx - fittedDst.left) / fittedDst.width;
          final ny = (pt.dy - fittedDst.top) / fittedDst.height;
          final px = (nx * 1024).toInt().clamp(0, 1023);
          final py = (ny * 1024).toInt().clamp(0, 1023);
          if (changedSet.contains(py * 1024 + px)) {
            insideRegion = true;
          }
        } else if (touchesBorder) {
          // If background was filled, also clear strokes in the margin!
          insideRegion = true;
        }

        if (insideRegion) {
          if (currentSegment.isNotEmpty) {
            updatedStrokes.add(DrawingStroke(
              points: List<Offset>.from(currentSegment),
              color: stroke.color,
              strokeWidth: stroke.strokeWidth,
            ));
            currentSegment.clear();
          }
        } else {
          currentSegment.add(pt);
        }
      }
      if (currentSegment.isNotEmpty) {
        updatedStrokes.add(DrawingStroke(
          points: List<Offset>.from(currentSegment),
          color: stroke.color,
          strokeWidth: stroke.strokeWidth,
        ));
      }
    }

    _strokes
      ..clear()
      ..addAll(updatedStrokes);

    if (touchesBorder) {
      _canvasBgColor = color;
    }

    await _updateFillImage();
    AudioService().playBucketFill();

    final action = FillAction(
      indices: Int32List.fromList(changedIndices),
      previousColor: targetColor,
      newColor: newColorVal,
      previousStrokes: strokesBefore,
      newStrokes: _strokes.map((s) => s.clone()).toList(),
      previousBgColor: prevBg,
      newBgColor: _canvasBgColor,
    );
    _history.add(action);
    _redoHistory.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.palette, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.tr('interactiveBoard'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.pastelYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.goldDark, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${settings.starsCount}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Banner Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('🐱', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.tr('kittenPainter'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              AppStrings.tr('creativeColoring'),
                              style: const TextStyle(color: Colors.black54, fontSize: 11),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      settings.musicEnabled ? Icons.music_note : Icons.music_off,
                      color: settings.musicEnabled ? AppColors.secondaryDark : Colors.grey,
                    ),
                    onPressed: () {
                      AudioService().playTap();
                      settings.setMusicEnabled(!settings.musicEnabled);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    AudioService().playFanfare();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CelebrationScreen(),
                      ),
                    );
                  },
                  icon: const Text('🎉', style: TextStyle(fontSize: 14)),
                  label: Text(
                    AppStrings.tr('done'),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pastelYellow,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                )
              ],
            ),
          ),

          // Tool Dock
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildToolBtn('brush', Icons.auto_fix_high, AppStrings.tr('brush')),
                      const SizedBox(width: 8),
                      _buildToolBtn('bucket', Icons.format_color_fill, AppStrings.tr('bucket')),
                      const SizedBox(width: 8),
                      _buildToolBtn('eraser', Icons.cleaning_services, AppStrings.tr('eraser')),
                    ],
                  ),
                  Row(
                    children: [
                      _buildActionBtn(Icons.undo, AppColors.surfaceLight, Colors.black54, _undo),
                      const SizedBox(width: 8),
                      _buildActionBtn(Icons.redo, AppColors.surfaceLight, Colors.black54, _redo),
                      const SizedBox(width: 8),
                      _buildActionBtn(Icons.bookmark_add, AppColors.lavender, AppColors.secondaryDark, _saveArt),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Interactive Canvas Area (Centered square drawing pad with AspectRatio 1.0)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _canvasBgColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

                          return Stack(
                            children: [
                              // CustomPaint handles: canvas background → bucket fills → strokes → kitten outline (multiply)
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: DrawingPainter(
                                    strokes: _strokes,
                                    fillImage: _fillImage,
                                    outlineImage: _outlineImage,
                                    canvasBgColor: _canvasBgColor,
                                  ),
                                ),
                              ),

                              // Loading spinner while kitten outline is being decoded
                              if (_isLoadingImage)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),

                              // Touch input detector for painting & bucket fill & eraser
                              Positioned.fill(
                                child: GestureDetector(
                                  onTapDown: (details) {
                                    if (_activeTool == 'bucket') {
                                      _handleBucketTap(details.localPosition, canvasSize);
                                    } else if (_activeTool == 'eraser') {
                                      _handleEraserTap(details.localPosition, canvasSize);
                                    } else {
                                      AudioService().playBrushStroke();
                                      final stroke = DrawingStroke(
                                        points: [details.localPosition],
                                        color: _currentColor,
                                        strokeWidth: _strokeWidth,
                                      );
                                      setState(() {
                                        _strokes.add(stroke);
                                        _history.add(StrokeAction(stroke));
                                        _redoHistory.clear();
                                      });
                                    }
                                  },
                                  onPanStart: (details) {
                                    if (_activeTool == 'eraser') {
                                      _strokesBeforeEraser = _strokes.map((s) => s.clone()).toList();
                                      _erasedPixelsInDrag.clear();
                                      _eraseAt(details.localPosition, canvasSize);
                                    } else if (_activeTool == 'brush') {
                                      AudioService().playBrushStroke();
                                      final stroke = DrawingStroke(
                                        points: [details.localPosition],
                                        color: _currentColor,
                                        strokeWidth: _strokeWidth,
                                      );
                                      setState(() {
                                        _strokes.add(stroke);
                                        _history.add(StrokeAction(stroke));
                                        _redoHistory.clear();
                                      });
                                    }
                                  },
                                  onPanUpdate: (details) {
                                    if (_activeTool == 'eraser') {
                                      _eraseAt(details.localPosition, canvasSize);
                                    } else if (_activeTool == 'brush' && _strokes.isNotEmpty) {
                                      AudioService().playBrushStroke();
                                      setState(() {
                                        _strokes.last.points.add(details.localPosition);
                                      });
                                    }
                                  },
                                  onPanEnd: (details) {
                                    if (_activeTool == 'eraser') {
                                      _history.add(EraseAction(
                                        previousStrokes: _strokesBeforeEraser,
                                        newStrokes: _strokes.map((s) => s.clone()).toList(),
                                        clearedPixels: Map.from(_erasedPixelsInDrag),
                                        previousBgColor: _canvasBgColor,
                                        newBgColor: _canvasBgColor,
                                      ));
                                      _erasedPixelsInDrag.clear();
                                      _redoHistory.clear();
                                    }
                                  },
                                ),
                              ),

                              // Badge
                              Positioned(
                                top: 16,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.pastelYellow,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.stars, size: 16, color: AppColors.goldDark),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppStrings.tr('youngArtist'),
                                        style: const TextStyle(
                                          color: AppColors.goldDark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Controls (Dynamic Color name, Brush Size selector & Palette)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _currentColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black26),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _currentColorName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          _buildSizeBtn(AppStrings.tr('small'), 'small'),
                          _buildSizeBtn(AppStrings.tr('medium'), 'medium'),
                          _buildSizeBtn(AppStrings.tr('large'), 'large'),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _palette.length,
                    itemBuilder: (context, index) {
                      final isActive = index == _activeColorIndex;
                      final itemColor = _palette[index]['color'] as Color;
                      return GestureDetector(
                        onTap: () {
                          AudioService().playColorSelect();
                          setState(() {
                            _activeColorIndex = index;
                            if (_activeTool == 'eraser') {
                              _activeTool = 'brush';
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          width: isActive ? 56 : 48,
                          height: isActive ? 56 : 48,
                          decoration: BoxDecoration(
                            color: itemColor,
                            shape: BoxShape.circle,
                            border: isActive
                                ? Border.all(color: AppColors.primary, width: 3)
                                : Border.all(color: Colors.black12, width: 1),
                            boxShadow: isActive
                                ? [const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))]
                                : null,
                          ),
                          child: isActive
                              ? Center(
                                  child: Icon(
                                    Icons.star,
                                    color: itemColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
                                    size: 24,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildToolBtn(String id, IconData icon, String label) {
    final isActive = _activeTool == id;
    return GestureDetector(
      onTap: () {
        AudioService().playPop();
        setState(() {
          _activeTool = id;
        });
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : const Color(0xFFEAE8E2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive ? [const BoxShadow(color: AppColors.primaryDark, offset: Offset(0, 4))] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.black87, size: 24),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(0, 4))],
        ),
        child: Icon(icon, color: iconColor),
      ),
    );
  }

  Widget _buildSizeBtn(String label, String sizeKey) {
    final isActive = _brushSize == sizeKey;
    return GestureDetector(
      onTap: () => _onSizeSelected(sizeKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
