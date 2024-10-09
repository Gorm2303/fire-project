import 'package:flutter/material.dart';

class TextFieldWrapper extends StatelessWidget {
  final List<Widget> children;

  const TextFieldWrapper({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,  // Fixed width of 350
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),  // Apply padding
        child: Column(
          children: children,  // Pass the list of children to the Column
        ),
      ),
    );
  }
}
