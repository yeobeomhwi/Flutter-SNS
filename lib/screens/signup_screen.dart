import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  int _currentStep = 0;
  bool _obscurePassword = true; // 비밀번호 가리기 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Stepper(
        elevation: 3,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: _controlsBuilder,
        type: StepperType.vertical,
        steps: _buildSteps(),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      _buildStep(
        title: 'Email',
        content: TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        isActive: _currentStep >= 0,
        isEditing: _currentStep == 0,
      ),
      _buildStep(
        title: 'Password',
        content: TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ),
          obscureText: _obscurePassword, // 아이콘 클릭 시 비밀번호 숨기기/보이기
        ),
        isActive: _currentStep >= 1,
        isEditing: _currentStep == 1,
      ),
      _buildStep(
        title: 'User Name',
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          keyboardType: TextInputType.text,
        ),
        isActive: _currentStep >= 2,
        isEditing: _currentStep == 2,
      ),
    ];
  }

  Step _buildStep({
    required String title,
    required Widget content,
    required bool isActive,
    required bool isEditing,
  }) {
    return Step(
      title: Text(title),
      content: content,
      isActive: isActive,
      state: isEditing
          ? StepState.editing
          : isActive
          ? StepState.complete
          : StepState.disabled,
    );
  }

  Widget _controlsBuilder(BuildContext context, _) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _currentStep != 0
              ? OutlinedButton(
            onPressed: _.onStepCancel,
            child: const Text('뒤로가기'),
          )
              : Container(),
          _currentStep != 2
              ? ElevatedButton(
            onPressed: _.onStepContinue,
            child: const Text('다음으로'),
          )
              : ElevatedButton(
            onPressed: () {
              print('submit');
              print(_emailController.text);
              print(_passwordController.text);
              print(_nameController.text);
            },
            child: const Text('회원가입'),
          ),
        ],
      ),
    );
  }

  void _onStepCancel() {
    if (_currentStep <= 0) return;
    setState(() {
      _currentStep -= 1;
    });
  }

  void _onStepContinue() {
    if (_currentStep >= 2) return;
    setState(() {
      _currentStep += 1;
    });
  }

  // 비밀번호 표시/숨기기 토글 함수
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
