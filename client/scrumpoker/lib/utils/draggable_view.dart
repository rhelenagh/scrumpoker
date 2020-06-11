// From https://raw.githubusercontent.com/rxlabz/flutter_dropcity/37f0591a92a9c2bd2a11b584f3e7d0be6739de48/lib/dropcity/draggable_view.dart
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class DragAvatarBorder extends StatelessWidget {

  final Color color;
  final double scale;
  final double opacity;
  final Widget child;
  final Size size;

  DragAvatarBorder(this.child,
    {this.color, this.scale: 1.0, this.opacity: 1.0, @required this.size});

  @override
  Widget build(BuildContext context)  =>
    new Opacity(
      opacity: opacity,
      child: new Container(
        transform: new Matrix4.identity()..scale(scale),
        width: size.width,
        height: size.height,
        color: color ?? Colors.grey.shade400,
        child: new Center(child: child),
      ));
}