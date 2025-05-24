import 'package:flutter/material.dart';

class ResolutionGuard extends StatelessWidget {
  final Widget child;
  final double minWidth;
  final double minHeight;
  final String message;

  const ResolutionGuard({
    super.key,
    required this.child,
    this.minWidth = 375,
    this.minHeight = 600,
    this.message = "이 화면은 최소 360x580 이상에서 이용해주세요 🙏",
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < minWidth ||
            constraints.maxHeight < minHeight) {
          return Scaffold(
            body: Center(child: Text(message, textAlign: TextAlign.center)),
          );
        }
        return child;
      },
    );
  }
}
