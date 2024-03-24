import 'package:notify/app_settings/routes.dart';
import 'package:notify/app_settings/theme.dart';
import 'package:notify/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';

void main() => runApp(const MyApp());


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _StateMyApp();
}

class _StateMyApp extends State<MyApp> {
  var themeMode = store.get<ThemeMode>('theme_mode')!;

  @override
  void initState() {
    super.initState();
    store.watch<ThemeMode>('theme_mode', (mode) {
      setState(() => themeMode = mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      theme: themeDefault,
      darkTheme: themeDark,
      themeMode: themeMode,
      initialRoute: initialRoute,
      // routes: routes,
      onGenerateRoute: myOnGenerateRoute
    );
  }
}