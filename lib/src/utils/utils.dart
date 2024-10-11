import 'package:flutter/material.dart';

bool isNumber(String value) {
  if (value.isEmpty) {
    return false;
  }
  return num.tryParse(value) != null;
}

SnackBar buildSnackbar(String message, {Color color = Colors.green}) {
  return SnackBar(
    content: Text(message),
    duration: const Duration(milliseconds: 1500),
    backgroundColor: color,
  );
}
