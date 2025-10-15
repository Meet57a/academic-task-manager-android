import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.black87,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    margin: const EdgeInsets.all(16),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
