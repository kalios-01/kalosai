import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Ensures camera permission; returns true if granted, false otherwise.
Future<bool> ensureCameraPermission(BuildContext context) async {
  print('Checking camera permission...');
  final cameraStatus = await Permission.camera.status;
  print('Initial camera status: $cameraStatus');

  if (!cameraStatus.isGranted) {
    print('Camera permission not granted, requesting...');
    final cameraResult = await Permission.camera.request();
    print('Camera permission request result: $cameraResult');
    
    if (!cameraResult.isGranted) {
      print('Camera permission denied');
      if (cameraStatus.isPermanentlyDenied || cameraStatus.isRestricted) {
        print('Camera permission permanently denied or restricted');
        await _showPermissionDialog(context);
      }
      return false;
    }
  }

  print('Camera permission granted');
  return true;
}

Future<void> _showPermissionDialog(BuildContext context) async {
  print('Showing camera permission dialog');
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Camera Permission Required'),
      content: const Text(
        'Kalos Ai needs camera access to take pictures of your food. '
        'Please grant permission from settings.',
      ),
      actions: [
        TextButton(
          child: const Text('Open Settings'),
          onPressed: () {
            print('Opening app settings...');
            openAppSettings();
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
 