import 'package:flutter/material.dart';

ScaffoldFeatureController successSnackBar(BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green.shade300,
      duration: Duration(seconds: 4),
    ),
  );
}

ScaffoldFeatureController dangerSnackBar(BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent.shade100,
      duration: Duration(seconds: 4),
    ),
  );
}
