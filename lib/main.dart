import 'package:notify/app_settings/routes.dart';
import 'package:notify/app_settings/theme.dart';
import 'package:notify/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'generated/l10n.dart';

void main() => runApp(const InitApp());

class InitApp extends StatefulWidget {
  const InitApp({super.key});

  @override
  State<InitApp> createState() => _StateInitApp();
}

class _StateInitApp extends State<InitApp> {
  var themeMode = store.get<ThemeMode>('theme_mode')!;
  var currentLocale = store.get<Locale>('locale')!;

  @override
  void initState() {
    super.initState();
    store.watch<ThemeMode>('theme_mode', (mode) async {
      setState(() => themeMode = mode);
      (await SharedPreferences.getInstance()).setString('theme_mode', mode.name);
    });
    store.watch<Locale>('locale', (locale) async {
      setState(() => currentLocale = locale);
      (await SharedPreferences.getInstance()).setString('locale', locale.languageCode);
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
      locale: currentLocale,
      theme: themeDefault,
      darkTheme: themeDark,
      themeMode: themeMode,
      initialRoute: initialRoute,
      // routes: routes,
      onGenerateRoute: generateRoute
    );
  }
}