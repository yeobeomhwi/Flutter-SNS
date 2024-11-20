import 'package:flutter/material.dart';

class TopNetworkBar extends StatefulWidget {
  final String message;
  final double topPosition;

  const TopNetworkBar({
    Key? key,
    required this.message,
    this.topPosition = 50.0,
  }) : super(key: key);

  @override
  _TopNetworkBarState createState() => _TopNetworkBarState();

  static OverlayEntry? _overlayEntry;

  static void on(BuildContext context, {double topPosition = 50.0}) {
    final overlay = Overlay.of(context);
    if (overlay != null) {
      off();

      _overlayEntry = OverlayEntry(
        builder: (context) => TopNetworkBar(
          message: "인터넷 연결 안됨",
          topPosition: topPosition,
        ),
      );

      overlay.insert(_overlayEntry!);
    }
  }


  static void off() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }
}

class _TopNetworkBarState extends State<TopNetworkBar> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.topPosition,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical:60,horizontal: 10),
          child: Container(
            color: Colors.red.withOpacity(0.8),
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Center(
              child: Text(
                widget.message,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
