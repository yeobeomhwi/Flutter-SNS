import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_providers.dart';
import '../widgets/signup_steps_builder.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(signupStepProvider);
    final obscurePassword = ref.watch(obscurePasswordProvider);
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final nameController = ref.watch(nameControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Stepper(
        elevation: 3,
        currentStep: currentStep,
        onStepContinue: () => ref.read(signupStepProvider.notifier).onStepContinue(),
        onStepCancel: () => ref.read(signupStepProvider.notifier).onStepCancel(),
        controlsBuilder: (context, _) => _controlsBuilder(context, ref, currentStep),
        type: StepperType.vertical,
        steps: SignupStepsBuilder.buildSteps(ref, obscurePassword, emailController, passwordController, nameController),
      ),
    );
  }

  Widget _controlsBuilder(BuildContext context, WidgetRef ref, int currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          currentStep != 0
              ? OutlinedButton(
            onPressed: () => ref.read(signupStepProvider.notifier).onStepCancel(),
            child: const Text('뒤로가기'),
          )
              : Container(),
          currentStep != 2
              ? ElevatedButton(
            onPressed: () => ref.read(signupStepProvider.notifier).onStepContinue(),
            child: const Text('다음으로'),
          )
              : ElevatedButton(
            onPressed: () {
              print('submit');
              print(ref.read(emailControllerProvider).text);
              print(ref.read(passwordControllerProvider).text);
              print(ref.read(nameControllerProvider).text);
            },
            child: const Text('회원가입'),
          ),
        ],
      ),
    );
  }
}
