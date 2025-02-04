import 'package:flutter/material.dart';

class ProfileEntry extends StatelessWidget {
  const ProfileEntry(
      {super.key, required this.displayText, required this.displayIcon});

  final String displayText;
  final IconData displayIcon;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      const SizedBox(
        width: 120,
      ),
      Icon(displayIcon),
      const SizedBox(
        width: 30,
      ),
      Text(
        displayText,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    ]);
  }
}
