import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  const Badge({
    required this.child,
    required this.value,
    this.color,
    this.top,
    this.left,
    this.bottom,
    this.right,
  });

  final Widget child;
  final String value;
  final Color? color;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: right ?? 8,
          top: top ?? 8,
          left: left,
          bottom: bottom,
          child: Container(
            padding: EdgeInsets.all(2.0),
            // color: Theme.of(context).accentColor,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: color ?? Theme.of(context).colorScheme.secondary,
            ),
            constraints: BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        )
      ],
    );
  }
}
