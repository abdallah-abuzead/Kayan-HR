import 'package:flutter/material.dart';

class ValidationError extends StatelessWidget {
  ValidationError({required this.errorMessage, required this.visible});
  final String errorMessage;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 5),
      child: Visibility(
        visible: visible,
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.red.shade900, fontSize: 12),
        ),
      ),
    );
  }
}
