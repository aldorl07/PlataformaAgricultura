// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

Future<Map<String, dynamic>?> captureWebImage(BuildContext context) async {
  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const WebCameraDialog(),
  );
}

class WebCameraDialog extends StatefulWidget {
  const WebCameraDialog({super.key});

  @override
  State<WebCameraDialog> createState() => _WebCameraDialogState();
}

class _WebCameraDialogState extends State<WebCameraDialog> {
  html.VideoElement? _videoElement;
  html.MediaStream? _localStream;
  String _viewId = '';
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _viewId = 'webcam-view-${DateTime.now().millisecondsSinceEpoch}';
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        throw Exception("MediaDevices no está disponible en este navegador (verifique que está en HTTPS o localhost).");
      }
      final stream = await mediaDevices.getUserMedia({'video': true});
      _localStream = stream;
      
      _videoElement = html.VideoElement()
        ..srcObject = stream
        ..autoplay = true
        ..setAttribute('playsinline', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) => _videoElement!);
      
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo acceder a la cámara de la laptop. Asegúrese de dar permisos de cámara al navegador.\nDetalles: $e';
      });
    }
  }

  void _capture() {
    if (_videoElement == null) return;
    
    final width = _videoElement!.videoWidth > 0 ? _videoElement!.videoWidth : 640;
    final height = _videoElement!.videoHeight > 0 ? _videoElement!.videoHeight : 480;
    
    final canvas = html.CanvasElement(width: width, height: height);
    canvas.context2D.drawImageScaled(_videoElement!, 0, 0, width, height);
    
    final dataUrl = canvas.toDataUrl('image/jpeg', 0.85);
    final base64String = dataUrl.split(',')[1];
    final bytes = html.window.atob(base64String).codeUnits;
    final uint8list = Uint8List.fromList(bytes);
    
    _disposeCamera();
    Navigator.of(context).pop({
      'bytes': uint8list,
      'name': 'webcam_${DateTime.now().millisecondsSinceEpoch}.jpg',
    });
  }

  void _disposeCamera() {
    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        track.stop();
      }
    }
    if (_videoElement != null) {
      _videoElement!.srcObject = null;
    }
  }

  @override
  void dispose() {
    _disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Capturar Foto'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: _error != null
            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center))
            : !_initialized
                ? const Center(child: CircularProgressIndicator())
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: HtmlElementView(viewType: _viewId),
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (_initialized)
          ElevatedButton.icon(
            icon: const Icon(Icons.camera),
            label: const Text('Capturar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
            ),
            onPressed: _capture,
          ),
      ],
    );
  }
}
