import 'package:flutter/material.dart';

class GradientIcon extends StatelessWidget {
  const GradientIcon(this.icon, this.size, this.gradient, {Key? key})
      : super(key: key);

  final IconData icon;
  final double size;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      child: Container(
        alignment: Alignment.center,
        width: size ,
        height: size ,
        child: Icon(
          icon,
          size: size,
          color: Colors.white,
        ),
      ),
      shaderCallback: (Rect bounds) {
        final Rect rect = Rect.fromLTRB(0, 0, size * 1.25, size * 1.25);
        return gradient.createShader(rect);
      },
    );
  }
}