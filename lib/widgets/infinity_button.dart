import 'package:flutter/material.dart';

class InfinityButton extends StatelessWidget {
  final Function() onPressed;
  final String title;
  final Color backgroundColor;
  final TextStyle textStyle;

  const InfinityButton(
      {super.key,
        required this.onPressed,
        required this.title,
        this.backgroundColor = Colors.black,
        this.textStyle = const TextStyle(color: Colors.white)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(backgroundColor),
          ),
          onPressed: onPressed,
          child: Text(
            title,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}
