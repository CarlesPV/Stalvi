import 'dart:ui';
import 'package:flutter/material.dart';

/// Wraps the application and applies a blur effect when the app is in the
/// background or inactive, protecting sensitive data in the task switcher.
class LifecycleBlurWrapper extends StatefulWidget {
  final Widget child;

  const LifecycleBlurWrapper({super.key, required this.child});

  @override
  State<LifecycleBlurWrapper> createState() => _LifecycleBlurWrapperState();
}

class _LifecycleBlurWrapperState extends State<LifecycleBlurWrapper>
    with WidgetsBindingObserver {
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _showOverlay = state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused ||
          state == AppLifecycleState.hidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_showOverlay)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          ),
      ],
    );
  }
}
