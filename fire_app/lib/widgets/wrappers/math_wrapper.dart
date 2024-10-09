import 'package:flutter/material.dart';

class MathWrapper extends StatelessWidget {
  final double fontSize; // Font size for Math.tex
  final double rightBoundaryMargin; // Margin for panning beyond the boundary
  final List<Widget> children;

  const MathWrapper({
    super.key,
    this.fontSize = 16, // Default font size
    required this.rightBoundaryMargin,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Create a Container that respects the maximum width of the parent widget
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: InteractiveViewer(
            boundaryMargin: EdgeInsets.only(right: rightBoundaryMargin),
            panEnabled: true, // Enable panning
            scaleEnabled: false, // Disable zooming, only allow panning
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        );
      },
    );
  }
}
