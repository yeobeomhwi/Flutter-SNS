import 'package:app_team2/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _currentStep = 0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  final String _defaultProfileImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/app-team2-2.firebasestorage.app/o/Default-Profile.png?alt=media&token=7da8bc98-ff57-491a-81a7-113b4a25cc62';

  Future<void> registerUser() async {
    String? emailError = validateEmail(_emailController.text);
    String? passwordError = validatePassword(_passwordController.text);

    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError)),
      );
      return;
    }

    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String result = await FirebaseService().registerUser(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
      _defaultProfileImageUrl,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );

    if (result == '회원가입이 완료되었습니다.') {
      await Future.delayed(const Duration(seconds: 2));
      GoRouter.of(context).push('/Login');
    }

    setState(() {
      _isLoading = false;
    });
  }

  String? validateEmail(String email) {
    if (email.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    if (!email.contains('@')) {
      return '유효한 이메일을 입력하세요.';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    if (password.length < 6) {
      return '비밀번호는 최소 6자 이상이어야 합니다.';
    }
    return null;
  }

  static List<Step> buildSteps(
      TextEditingController emailController,
      TextEditingController passwordController,
      TextEditingController nameController,
      int current) {
    return [
      _buildStep(
        title: 'Email',
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        isActive: current >= 0,
        isEditing: current == 0,
      ),
      _buildStep(
        title: 'Password',
        content: TextField(
          controller: passwordController,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        isActive: current >= 1,
        isEditing: current == 1,
      ),
      _buildStep(
        title: 'User Name',
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          keyboardType: TextInputType.text,
        ),
        isActive: current >= 2,
        isEditing: current == 2,
      ),
    ];
  }

  static Step _buildStep({
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() {
              _currentStep++;
            });
          } else {
            registerUser();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep--;
            });
          }
        },
        steps: buildSteps(
          _emailController,
          _passwordController,
          _nameController,
          _currentStep,
        ),
        controlsBuilder: (context, _) =>
            _controlsBuilder(context, _currentStep),
      ),
    );
  }

  Widget _controlsBuilder(BuildContext context, int currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          currentStep != 0
              ? OutlinedButton(
            onPressed: () {
              setState(() {
                _currentStep--;
              });
            },
            child: const Text('뒤로가기'),
          )
              : Container(),
          currentStep != 2
              ? ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep++;
              });
            },
            child: const Text('다음으로'),
          )
              : ElevatedButton(
            onPressed: _isLoading ? null : () {
              registerUser();
            },
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('회원가입'),
          ),
        ],
      ),
    );
  }
}
