import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
        primary: Colors.grey.shade800,
        secondary: Colors.grey.shade700,
    inversePrimary: Colors.grey.shade500,
  ),
    // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey.shade300,
    displayColor: Colors.white,
  )
);