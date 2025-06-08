import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:kalai/services/upload_service.dart';

class CameraScreen extends StatefulWidget {
  final String type; // 'barcode' or 'food_item'
  final Function(bool success) onCaptureComplete;

  const CameraScreen({
    Key? key,
    required this.type,
    required this.onCaptureComplete,
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  final UploadService _uploadService = UploadService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      print('Initializing camera...');
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        print('No cameras available');
        return;
      }

      // Use the first camera (usually the rear camera)
      final camera = _cameras!.first;
      print('Selected camera: ${camera.name}');

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      print('Initializing camera controller...');
      await _controller!.initialize();
      print('Camera controller initialized');

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      print('Camera not ready or already capturing');
      return;
    }

    try {
      setState(() {
        _isCapturing = true;
      });

      print('Taking picture...');
      final XFile photo = await _controller!.takePicture();
      print('Picture taken: ${photo.path}');

      // Create a File object from the photo path
      final File imageFile = File(photo.path);
      print('Image file created at: ${imageFile.path}');

      // Show uploading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading image...')),
        );
      }

      // Upload the image
      Map<String, dynamic> response;
      if (widget.type == 'barcode') {
        print('Uploading barcode image...');
        response = await _uploadService.uploadBarcodeImage(imageFile);
      } else {
        print('Uploading food image...');
        response = await _uploadService.uploadFoodImage(imageFile);
      }
      print('Upload response: $response');

      if (mounted) {
        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.type == 'barcode' ? 'Barcode' : 'Food item'} uploaded successfully!')),
          );
          widget.onCaptureComplete(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload ${widget.type}: ${response['message']}')),
          );
          widget.onCaptureComplete(false);
        }
      }
    } catch (e) {
      print('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: $e')),
        );
        widget.onCaptureComplete(false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen camera preview
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize!.height,
                height: _controller!.value.previewSize!.width,
                child: CameraPreview(_controller!),
              ),
            ),
          ),
          // Camera controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Close button
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                // Capture button
                GestureDetector(
                  onTap: _isCapturing ? null : _takePicture,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: _isCapturing ? Colors.grey : Colors.white.withOpacity(0.3),
                    ),
                    child: _isCapturing
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.camera, color: Colors.white, size: 30),
                  ),
                ),
                // Placeholder for symmetry
                const SizedBox(width: 70),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 