import 'dart:async';
import 'package:notify/Navigation.dart';
import 'package:notify/http/users.http.dart';
import 'package:flutter/material.dart';
import 'package:notify/screens/Auth.screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../methods/work_with_user.dart';
import '../store/store.dart';

class InitScreen extends StatefulWidget{
  const InitScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StateInitScreen();
}

class _StateInitScreen extends State<InitScreen>{
  double opacity = 0.5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    init();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
     if(_timer!=null) setState(() => opacity = opacity < 1 ? 1 : 0.75);
    });
  }
  
  ThemeMode getThemeMode(String? theme){
    ThemeMode mode;
    switch(theme){
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
        break;
    }
    return mode;
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    final hash = prefs.getString('hash');
    final localeCode = prefs.getString('locale');
    final themeMode = prefs.getString('theme_mode');
    final access = await UsersHttp.checkUserAccess(id ?? 0, hash ?? '');
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    store.mapMultiSet({
      "locale":localeCode!=null ? Locale(localeCode) : locale,
      "theme_mode":getThemeMode(themeMode)
    });
    
    if(localeCode==null) prefs.setString('locale', locale.languageCode);
    if(!access) clearUser();
    if(id==null||hash==null||!access){
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
    }else{
        final userInfo = (await UsersHttp.getSingle(id))!;
        store.mapMultiSet({
          "id":id,
          "hash":hash
        });
        if(userInfo.name.length>=2){
          rxPickedIndex.value = 0;
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }else{
          rxFocusEmitter.value = 2;
          Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
        }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: opacity,
                child: const Text(
                    'Notify',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 70,
                        fontWeight: FontWeight.w600
                    )
                )
            )
          ]
        )
      )
    );
  }
}

