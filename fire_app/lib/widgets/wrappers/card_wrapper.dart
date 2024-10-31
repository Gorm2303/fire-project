import 'package:flutter/material.dart';

class CardWrapper extends StatelessWidget {
  final List<Widget> children;
  final String title;
  final EdgeInsetsGeometry contentPadding;
  final Color lightColor;
  final Color darkColor;

  const CardWrapper({
    super.key,
    required this.children,
    required this.title,
    this.contentPadding = const EdgeInsets.all(0),
    this.lightColor = Colors.white,
    this.darkColor = const Color(0xFF424242), // Default dark grey
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? darkColor : lightColor;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Center(
      child: Card(
        color: cardColor, // Set the card color based on the theme
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
              // Title for this section with adaptive color
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              Divider(color: isDarkMode ? Colors.grey[600] : Colors.grey[300]),
              // Dynamically add all the passed children
              Padding(
                padding: contentPadding,
                child: Column(
                  children: children,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
