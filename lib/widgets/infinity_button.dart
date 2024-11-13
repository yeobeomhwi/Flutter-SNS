import 'package:flutter/material.dart';

class InfinityButton extends StatelessWidget {
  final Function() onPressed;
  final String title;

  const InfinityButton(
      {super.key, required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(title),
        ),
      ),
    );
  }
}
