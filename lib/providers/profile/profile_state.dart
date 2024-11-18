import '../../data/models/usermodel.dart';

class ProfileState {
  final bool isLoading;
  final UserModel? user;
  final String? error;

  ProfileState({this.isLoading = false, this.user, this.error});
}
