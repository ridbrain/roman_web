import 'package:flutter/material.dart';

class RomanLogo extends StatelessWidget {
  const RomanLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          "Roman.",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Delivery",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
