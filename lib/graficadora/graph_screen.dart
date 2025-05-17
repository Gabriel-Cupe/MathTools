import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'function_editor.dart';
import 'graph_painter.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final List<String> _functions = [];
  final List<Color> _lineColors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.amber,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.pinkAccent,
  ];

  double _visibleXMin = -10;
  double _visibleXMax = 10;
  double _visibleYMin = -10;
  double _visibleYMax = 10;
  double _scale = 1.0;
  Offset? _lastFocalPoint;
  bool _showEditor = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Graficadora',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.rotate_left,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.blue
                  : Colors.white,
            ),
            onPressed: _resetView,
            tooltip: 'Resetear vista',
          ),
          IconButton(
            icon: Icon(
              Iconsax.graph,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.blue
                  : Colors.white,
            ),
            onPressed: _showFunctionsList,
            tooltip: 'Funciones',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: theme.scaffoldBackgroundColor,
            child: GestureDetector(
              onScaleStart: (details) {
                _lastFocalPoint = details.localFocalPoint;
              },
              onScaleUpdate: (details) {
                if (_lastFocalPoint != null) {
                  final delta = details.localFocalPoint - _lastFocalPoint!;
                  final scaleX = (_visibleXMax - _visibleXMin) / MediaQuery.of(context).size.width;
                  final scaleY = (_visibleYMax - _visibleYMin) / MediaQuery.of(context).size.height;

                  setState(() {
                    _visibleXMin -= delta.dx * scaleX;
                    _visibleXMax -= delta.dx * scaleX;
                    _visibleYMin += delta.dy * scaleY;
                    _visibleYMax += delta.dy * scaleY;
                  });
                }

                if (details.scale != 1.0) {
                  final newScale = _scale * details.scale;
                  if (newScale > 0.1 && newScale < 10) {
                    setState(() {
                      _scale = newScale;
                      final centerX = (_visibleXMin + _visibleXMax) / 2;
                      final centerY = (_visibleYMin + _visibleYMax) / 2;
                      final rangeX = (_visibleXMax - _visibleXMin) / details.scale;
                      final rangeY = (_visibleYMax - _visibleYMin) / details.scale;

                      _visibleXMin = centerX - rangeX / 2;
                      _visibleXMax = centerX + rangeX / 2;
                      _visibleYMin = centerY - rangeY / 2;
                      _visibleYMax = centerY + rangeY / 2;
                    });
                  }
                }

                _lastFocalPoint = details.localFocalPoint;
              },
              onScaleEnd: (_) {
                _lastFocalPoint = null;
              },
              onDoubleTap: _resetView,
              child: CustomPaint(
                painter: FunctionGraphPainter(
                  functions: _functions,
                  xMin: _visibleXMin,
                  xMax: _visibleXMax,
                  yMin: _visibleYMin,
                  yMax: _visibleYMax,
                  lineColors: _lineColors,
                  scale: _scale,
                  isDark: isDark,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          if (_showEditor)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: FunctionEditor(
                onAddFunction: (function) {
                  setState(() {
                    _functions.add(function);
                    _showEditor = false;
                  });
                },
                onCancel: () => setState(() => _showEditor = false),
                isDark: isDark,
              ),
            ),
          // Botones de zoom en la esquina inferior izquierda
if (!_showEditor)
  Positioned(
    left: 16,
    bottom: 16,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'zoomIn',
          mini: true,
          backgroundColor: isDark ? Colors.white10 : Colors.blue.shade600,
          onPressed: _zoomIn,
          child: Icon(Icons.add, color: isDark ? Colors.blue : Colors.white),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'zoomOut',
          mini: true,
          backgroundColor: isDark ? Colors.white10 : Colors.blue.shade600,
          onPressed: _zoomOut,
          child: Icon(Icons.remove, color: isDark ? Colors.blue : Colors.white),
        ),
      ],
    ),
  ),

        ],
      ),
      floatingActionButton: _showEditor
          ? null
          : Container(
              margin: const EdgeInsets.only(bottom: 16, right: 16),
              child: GestureDetector(
                onTap: () => setState(() => _showEditor = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.blue.shade600
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.blue.withOpacity(0.3)
                            : Colors.black.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.add,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Agregar',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _zoomIn() {
    setState(() {
      final centerX = (_visibleXMin + _visibleXMax) / 2;
      final centerY = (_visibleYMin + _visibleYMax) / 2;
      final rangeX = (_visibleXMax - _visibleXMin) * 0.8;
      final rangeY = (_visibleYMax - _visibleYMin) * 0.8;

      _visibleXMin = centerX - rangeX / 2;
      _visibleXMax = centerX + rangeX / 2;
      _visibleYMin = centerY - rangeY / 2;
      _visibleYMax = centerY + rangeY / 2;
    });
  }

  void _zoomOut() {
    setState(() {
      final centerX = (_visibleXMin + _visibleXMax) / 2;
      final centerY = (_visibleYMin + _visibleYMax) / 2;
      final rangeX = (_visibleXMax - _visibleXMin) * 1.25;
      final rangeY = (_visibleYMax - _visibleYMin) * 1.25;

      _visibleXMin = centerX - rangeX / 2;
      _visibleXMax = centerX + rangeX / 2;
      _visibleYMin = centerY - rangeY / 2;
      _visibleYMax = centerY + rangeY / 2;
    });
  }

  void _resetView() {
    setState(() {
      _visibleXMin = -10;
      _visibleXMax = 10;
      _visibleYMin = -10;
      _visibleYMax = 10;
      _scale = 1.0;
    });
  }

  void _showFunctionsList() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.dialogBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Funciones graficadas',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _functions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _lineColors[index % _lineColors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        _functions[index],
                        style: GoogleFonts.poppins(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Iconsax.trash, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            _functions.removeAt(index);
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary,
                  side: BorderSide(
                    color: theme.colorScheme.secondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cerrar',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}