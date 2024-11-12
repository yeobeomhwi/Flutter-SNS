import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final pickedImagesProvider = StateNotifierProvider<PickedImagesNotifier, List<XFile>>((ref) {
  return PickedImagesNotifier();
});

class PickedImagesNotifier extends StateNotifier<List<XFile>> {
  PickedImagesNotifier() : super([]);

  void addImage(XFile image) {
    state = [...state, image];
  }

  void addImages(List<XFile> images) {
    state = [...state, ...images];
  }

  void removeImage(XFile image) {
    state = state.where((e) => e.path != image.path).toList();
  }

  void clearImages() {
    state = [];
  }
}