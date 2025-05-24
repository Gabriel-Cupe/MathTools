import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class ImageViewer extends StatefulWidget {
  final String imageUrl;
  final double initialScale;
  final bool showZoomControls;
  
  const ImageViewer({
    super.key,
    required this.imageUrl,
    this.initialScale = 1.0,
    this.showZoomControls = true,
  });

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late TransformationController _transformationController;
  late TapGestureRecognizer _doubleTapRecognizer;
  double _scale = 1.0;
  final double _minScale = 0.8;
  final double _maxScale = 4.0;
  Offset _offset = Offset.zero;
  Offset? _startOffset;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _doubleTapRecognizer = TapGestureRecognizer()
      ..onTap = _handleDoubleTap;
    _scale = widget.initialScale;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _doubleTapRecognizer.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    setState(() {
      if (_scale != 1.0) {
        _scale = 1.0;
        _offset = Offset.zero;
      } else {
        _scale = 2.0;
      }
      _updateTransformation();
    });
  }

  void _updateTransformation() {
    _transformationController.value = Matrix4.identity()
      ..translate(_offset.dx, _offset.dy)
      ..scale(_scale);
  }

  void _zoomIn() {
    setState(() {
      _scale = (_scale + 0.2).clamp(_minScale, _maxScale);
      _updateTransformation();
    });
  }

  void _zoomOut() {
    setState(() {
      _scale = (_scale - 0.2).clamp(_minScale, _maxScale);
      _updateTransformation();
    });
  }

  void _showFullScreen() {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => Scaffold(
        backgroundColor: Colors.black.withOpacity(0.8),
        body: Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Hero(
              tag: widget.imageUrl,
              child: Image.network(widget.imageUrl),
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return
     Stack(
      clipBehavior: Clip.none,
      children: [
        // Imagen interactiva
        GestureDetector(
          onScaleStart: (details) {
            if (widget.showZoomControls) {
              _startOffset = details.localFocalPoint;
            }
          },
          onScaleUpdate: (details) {
            if (widget.showZoomControls) {
              setState(() {
                _scale = (_scale * details.scale).clamp(_minScale, _maxScale);
                if (_startOffset != null) {
                  final offsetChange = details.localFocalPoint - _startOffset!;
                  _offset += offsetChange;
                  _startOffset = details.localFocalPoint;
                }
                _updateTransformation();
              });
            }
          },
          onDoubleTap: widget.showZoomControls ? _handleDoubleTap : null,
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: widget.showZoomControls ? _minScale : 1.0,
            maxScale: widget.showZoomControls ? _maxScale : 1.0,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: GestureDetector(
              onTap: _showFullScreen,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
        
        // Controles de zoom (solo si showZoomControls es true)
        if (widget.showZoomControls) ...[
Positioned(
  bottom: 12,
  right: 12,

            child: Material(
              color: Colors.transparent,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    mini: true,
                    heroTag: '${widget.imageUrl}-zoomout',
                    onPressed: _zoomOut,
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    heroTag: '${widget.imageUrl}-zoomin',
                    onPressed: _zoomIn,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  
  }
}