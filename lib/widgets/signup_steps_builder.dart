import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_providers.dart';

class SignupStepsBuilder {
  static List<Step> buildSteps(
      WidgetRef ref,
      bool obscurePassword,
      TextEditingController emailController,
      TextEditingController passwordController,
      TextEditingController nameController,
      ) {
    return [
      _buildStep(
        title: 'Email',
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        isActive: ref.watch(signupStepProvider) >= 0,
        isEditing: ref.watch(signupStepProvider) == 0,
      ),
      _buildStep(
        title: 'Password',
        content: TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => ref.read(obscurePasswordProvider.notifier).state = !obscurePassword,
            ),
          ),
          obscureText: obscurePassword,
        ),
        isActive: ref.watch(signupStepProvider) >= 1,
        isEditing: ref.watch(signupStepProvider) == 1,
      ),
      _buildStep(
        title: 'User Name',
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          keyboardType: TextInputType.text,
        ),
        isActive: ref.watch(signupStepProvider) >= 2,
        isEditing: ref.watch(signupStepProvider) == 2,
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
}
