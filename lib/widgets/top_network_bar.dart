import 'package:flutter/material.dart';

class NetworkStatusBar {
  static OverlayEntry? _overlayEntry;

  // 싱글톤 패턴을 위한 private 생성자
  NetworkStatusBar._();

  // 상수 값들을 static const로 분리
  static const double defaultTopPosition = 50.0;
  static const double defaultVerticalPadding = 60.0;
  static const double defaultHorizontalPadding = 10.0;
  static const double defaultFontSize = 16.0;

  static void show(
    BuildContext context, {
    String message = "인터넷 연결 안됨",
    double topPosition = defaultTopPosition,
  }) {
    hide(); // 기존 오버레이가 있다면 제거

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => _NetworkStatusBarView(
        message: message,
        topPosition: topPosition,
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _NetworkStatusBarView extends StatelessWidget {
  final String message;
  final double topPosition;

  const _NetworkStatusBarView({
    super.key,
    required this.message,
    required this.topPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topPosition,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: NetworkStatusBar.defaultVerticalPadding,
              horizontal: NetworkStatusBar.defaultHorizontalPadding,
            ),
            child: Container(
              color: Colors.red.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 20.0,
              ),
              child: Center(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: NetworkStatusBar.defaultFontSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
