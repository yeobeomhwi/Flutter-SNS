import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TopNetworkBar extends StatefulWidget {
  final String message;
  final double topPosition;

  const TopNetworkBar({
    Key? key,
    required this.message,
    this.topPosition = 50.0, // Default top position is 50px from top
  }) : super(key: key);

  @override
  _TopNetworkBarState createState() => _TopNetworkBarState();

  static OverlayEntry? _overlayEntry; // Holds the OverlayEntry instance

  // Method to display the TopNetworkBar
  static void on(BuildContext context, {double topPosition = 50.0}) {
    final overlay = Overlay.of(context); // Get the overlay using context
    if (overlay != null) {
      // If an entry is already present, remove it first before adding a new one
      off();

      _overlayEntry = OverlayEntry(
        builder: (context) => TopNetworkBar(
          message: "인터넷 연결 안됨",
          topPosition: topPosition,
        ),
      );

      overlay.insert(_overlayEntry!); // Insert the overlay
    }
  }

  // Method to hide the TopNetworkBar
  static void off() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove(); // Removes the OverlayEntry
      _overlayEntry = null; // Reset the OverlayEntry to null
    }
  }
}

class _TopNetworkBarState extends State<TopNetworkBar> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.topPosition, // Position from the top
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Text(
            widget.message,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
