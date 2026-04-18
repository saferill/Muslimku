import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  void showAppSnack(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
