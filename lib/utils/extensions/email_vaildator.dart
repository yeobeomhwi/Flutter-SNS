extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'
    ).hasMatch(this);
  }
}


extension NameValidator on String {
  bool isValidName() {
    return RegExp(r"^[a-zA-Z가-힣]{3,}$").hasMatch(this);
  }
}
