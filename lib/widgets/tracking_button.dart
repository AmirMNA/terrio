import 'package:flutter/material.dart';

class TrackingButton extends StatelessWidget {
  final VoidCallback onFinish;
  final bool isTracking;
  const TrackingButton({super.key, required this.onFinish, required this.isTracking});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onFinish,
      icon: const Icon(Icons.check),
      label: const Text('Finish Capture'),
      backgroundColor: Colors.greenAccent,
    );
  }
}