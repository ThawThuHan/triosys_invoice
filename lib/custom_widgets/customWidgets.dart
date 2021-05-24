import "package:flutter/material.dart";

class BuildLabelText extends StatelessWidget {
  const BuildLabelText({
    Key key,
    @required this.label,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
