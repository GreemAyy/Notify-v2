import 'package:flutter/material.dart';

TextTheme _textTheme = const TextTheme(
    bodyMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
    bodyLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
);
Color _primaryColor = const Color.fromARGB(255, 0, 140, 255);

ThemeData themeDefault = ThemeData(
  colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: _primaryColor,
      secondary: _primaryColor,
      surfaceTint: Colors.transparent
  ),
  brightness: Brightness.light,
  primaryColor: _primaryColor,
  dialogBackgroundColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  textTheme: _textTheme,
  fontFamily: 'Montserrat',
  appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.black,
      backgroundColor: Colors.white
  )
);

ThemeData themeDark = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primaryColor,
    secondary: _primaryColor,
    brightness: Brightness.dark,
    surfaceTint: Colors.transparent
  ),
  primaryColor: _primaryColor,
  fontFamily: 'Montserrat',
  textTheme: _textTheme,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.white
  )
);

