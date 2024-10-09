import 'package:flutter/material.dart';

class CardWrapper extends StatelessWidget {
  final List<Widget> children;
  final String title;

  const CardWrapper({super.key, required this.children, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: const Color.fromARGB(176, 255, 255, 255),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Title for this section
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,  // Center the title
              ),
              const Divider(),
              // Dynamically add all the passed children
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
