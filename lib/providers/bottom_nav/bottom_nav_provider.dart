import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavIndexState {
  final int index;

  BottomNavIndexState({required this.index});
}

final bottomNavIndexProvider = StateNotifierProvider<BottomNavIndexNotifier, BottomNavIndexState>((ref) {
  return BottomNavIndexNotifier();
});

class BottomNavIndexNotifier extends StateNotifier<BottomNavIndexState> {
  BottomNavIndexNotifier() : super(BottomNavIndexState(index: 0));

  void setIndex(int index) {
    state = BottomNavIndexState(index: index);
  }

  void resetIndex() {
    state = BottomNavIndexState(index: 0);
  }
}
